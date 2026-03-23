-- =============================================
-- Query: Time Series Analysis
-- Category: Advanced Analytics
-- Difficulty: Advanced
--
-- Business Question:
-- What are the trends and patterns in our data over time?
-- How can we identify seasonality and anomalies?
--
-- Use Case:
-- Forecasting, trend identification, anomaly detection,
-- and business planning.
-- =============================================

-- Monthly revenue trend with moving averages
WITH monthly_revenue AS (
    SELECT
        strftime('%Y-%m', order_date) AS month,
        COUNT(*) AS orders,
        SUM(total_amount) AS revenue
    FROM orders
    WHERE status = 'Completed'
    GROUP BY strftime('%Y-%m', order_date)
)
SELECT
    month,
    orders,
    ROUND(revenue, 2) AS revenue,
    ROUND(AVG(revenue) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS ma_3_month,
    ROUND(AVG(revenue) OVER (ORDER BY month ROWS BETWEEN 5 PRECEDING AND CURRENT ROW), 2) AS ma_6_month,
    ROUND(revenue - LAG(revenue) OVER (ORDER BY month), 2) AS mom_change,
    ROUND((revenue - LAG(revenue) OVER (ORDER BY month)) * 100.0 / LAG(revenue) OVER (ORDER BY month), 2) AS mom_growth_pct
FROM monthly_revenue
ORDER BY month;

-- =============================================
-- Expected Output:
-- | month   | orders | revenue    | ma_3_month | mom_growth_pct |
-- |---------|--------|------------|------------|----------------|
-- | 2024-01 | 55     | 142,280.00 | 138,500.00 | 5.25           |
-- | 2024-02 | 48     | 125,430.00 | 135,200.00 | -11.84         |
-- =============================================

-- Day-of-week patterns
SELECT
    CASE CAST(strftime('%w', order_date) AS INTEGER)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END AS day_name,
    COUNT(*) AS total_orders,
    ROUND(SUM(total_amount), 2) AS total_revenue,
    ROUND(AVG(total_amount), 2) AS avg_order_value,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders WHERE status = 'Completed'), 2) AS pct_of_orders
FROM orders
WHERE status = 'Completed'
GROUP BY strftime('%w', order_date)
ORDER BY CAST(strftime('%w', order_date) AS INTEGER);

-- Monthly seasonality index
WITH monthly_data AS (
    SELECT
        CAST(strftime('%m', order_date) AS INTEGER) AS month_num,
        strftime('%Y', order_date) AS year,
        SUM(total_amount) AS revenue
    FROM orders
    WHERE status = 'Completed'
    GROUP BY strftime('%Y', order_date), strftime('%m', order_date)
),
monthly_avg AS (
    SELECT
        month_num,
        AVG(revenue) AS avg_revenue
    FROM monthly_data
    GROUP BY month_num
),
overall_avg AS (
    SELECT AVG(avg_revenue) AS grand_avg FROM monthly_avg
)
SELECT
    ma.month_num,
    CASE ma.month_num
        WHEN 1 THEN 'January' WHEN 2 THEN 'February' WHEN 3 THEN 'March'
        WHEN 4 THEN 'April' WHEN 5 THEN 'May' WHEN 6 THEN 'June'
        WHEN 7 THEN 'July' WHEN 8 THEN 'August' WHEN 9 THEN 'September'
        WHEN 10 THEN 'October' WHEN 11 THEN 'November' WHEN 12 THEN 'December'
    END AS month_name,
    ROUND(ma.avg_revenue, 2) AS avg_revenue,
    ROUND(ma.avg_revenue / oa.grand_avg, 4) AS seasonal_index,
    CASE
        WHEN ma.avg_revenue / oa.grand_avg > 1.1 THEN 'High Season'
        WHEN ma.avg_revenue / oa.grand_avg < 0.9 THEN 'Low Season'
        ELSE 'Normal'
    END AS season_type
FROM monthly_avg ma
CROSS JOIN overall_avg oa
ORDER BY ma.month_num;

-- Year-over-year comparison
WITH yearly_monthly AS (
    SELECT
        strftime('%Y', order_date) AS year,
        strftime('%m', order_date) AS month,
        COUNT(*) AS orders,
        SUM(total_amount) AS revenue
    FROM orders
    WHERE status = 'Completed'
    GROUP BY strftime('%Y', order_date), strftime('%m', order_date)
)
SELECT
    y1.year AS current_year,
    y1.month,
    y1.orders AS current_orders,
    ROUND(y1.revenue, 2) AS current_revenue,
    y2.orders AS prior_year_orders,
    ROUND(y2.revenue, 2) AS prior_year_revenue,
    y1.orders - COALESCE(y2.orders, 0) AS order_diff,
    ROUND((y1.revenue - COALESCE(y2.revenue, 0)) * 100.0 / NULLIF(y2.revenue, 0), 2) AS yoy_growth_pct
FROM yearly_monthly y1
LEFT JOIN yearly_monthly y2 ON y1.month = y2.month AND y1.year = CAST(y2.year AS INTEGER) + 1
ORDER BY y1.year DESC, y1.month DESC;

-- Weekly trend analysis
SELECT
    strftime('%Y-W%W', order_date) AS week,
    COUNT(*) AS orders,
    ROUND(SUM(total_amount), 2) AS revenue,
    COUNT(DISTINCT customer_id) AS unique_customers,
    ROUND(AVG(total_amount), 2) AS avg_order_value
FROM orders
WHERE status = 'Completed'
GROUP BY strftime('%Y-W%W', order_date)
ORDER BY week DESC
LIMIT 24;

-- Anomaly detection (orders outside 2 std deviations)
WITH daily_metrics AS (
    SELECT
        DATE(order_date) AS order_day,
        COUNT(*) AS daily_orders,
        SUM(total_amount) AS daily_revenue
    FROM orders
    WHERE status = 'Completed'
    GROUP BY DATE(order_date)
),
stats AS (
    SELECT
        AVG(daily_revenue) AS mean_revenue,
        AVG(daily_revenue * daily_revenue) - AVG(daily_revenue) * AVG(daily_revenue) AS variance
    FROM daily_metrics
)
SELECT
    dm.order_day,
    dm.daily_orders,
    ROUND(dm.daily_revenue, 2) AS revenue,
    ROUND(s.mean_revenue, 2) AS avg_daily_revenue,
    CASE
        WHEN dm.daily_revenue > s.mean_revenue + 2 * SQRT(s.variance) THEN 'Unusually High'
        WHEN dm.daily_revenue < s.mean_revenue - 2 * SQRT(s.variance) THEN 'Unusually Low'
        ELSE 'Normal'
    END AS anomaly_flag
FROM daily_metrics dm
CROSS JOIN stats s
WHERE dm.daily_revenue > s.mean_revenue + 2 * SQRT(s.variance)
   OR dm.daily_revenue < s.mean_revenue - 2 * SQRT(s.variance)
ORDER BY dm.order_day DESC;

-- Cumulative metrics over time
SELECT
    strftime('%Y-%m', order_date) AS month,
    COUNT(*) AS monthly_orders,
    ROUND(SUM(total_amount), 2) AS monthly_revenue,
    SUM(COUNT(*)) OVER (ORDER BY strftime('%Y-%m', order_date)) AS cumulative_orders,
    ROUND(SUM(SUM(total_amount)) OVER (ORDER BY strftime('%Y-%m', order_date)), 2) AS cumulative_revenue,
    COUNT(DISTINCT customer_id) AS new_customers_proxy
FROM orders
WHERE status = 'Completed'
GROUP BY strftime('%Y-%m', order_date)
ORDER BY month;
