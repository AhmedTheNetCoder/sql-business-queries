-- =============================================
-- Query: Revenue Forecast Base Data
-- Category: Finance Analytics
-- Difficulty: Intermediate
--
-- Business Question:
-- What data do we need for revenue forecasting?
-- What are the historical patterns we can use?
--
-- Use Case:
-- Financial planning, budgeting, investor reporting,
-- and growth projections.
-- =============================================

-- Historical monthly revenue
SELECT
    strftime('%Y-%m', order_date) AS month,
    COUNT(*) AS order_count,
    COUNT(DISTINCT customer_id) AS unique_customers,
    ROUND(SUM(total_amount), 2) AS revenue,
    ROUND(AVG(total_amount), 2) AS avg_order_value,
    ROUND(SUM(total_amount) / COUNT(DISTINCT customer_id), 2) AS revenue_per_customer
FROM orders
WHERE status = 'Completed'
GROUP BY strftime('%Y-%m', order_date)
ORDER BY month;

-- =============================================
-- Expected Output:
-- | month   | order_count | unique_customers | revenue    | avg_order_value |
-- |---------|-------------|------------------|------------|-----------------|
-- | 2023-01 | 5           | 5                | 21,361.25  | 4,272.25        |
-- | 2023-02 | 5           | 5                | 18,923.50  | 3,784.70        |
-- =============================================

-- Seasonal index calculation
WITH monthly_revenue AS (
    SELECT
        CAST(strftime('%m', order_date) AS INTEGER) AS month_num,
        SUM(total_amount) AS revenue
    FROM orders
    WHERE status = 'Completed'
    GROUP BY strftime('%Y-%m', order_date)
),
monthly_avg AS (
    SELECT
        month_num,
        AVG(revenue) AS avg_revenue
    FROM monthly_revenue
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
    ROUND(ma.avg_revenue, 2) AS avg_monthly_revenue,
    ROUND(ma.avg_revenue / oa.grand_avg, 4) AS seasonal_index
FROM monthly_avg ma
CROSS JOIN overall_avg oa
ORDER BY ma.month_num;

-- Growth rate calculation
WITH monthly_revenue AS (
    SELECT
        strftime('%Y-%m', order_date) AS month,
        SUM(total_amount) AS revenue
    FROM orders
    WHERE status = 'Completed'
    GROUP BY strftime('%Y-%m', order_date)
)
SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(LAG(revenue) OVER (ORDER BY month), 2) AS prev_month,
    ROUND((revenue - LAG(revenue) OVER (ORDER BY month)) / LAG(revenue) OVER (ORDER BY month) * 100, 2) AS mom_growth,
    ROUND(AVG(revenue) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS three_month_avg
FROM monthly_revenue
ORDER BY month DESC
LIMIT 12;

-- Customer acquisition trend
SELECT
    strftime('%Y-%m', first_order) AS cohort_month,
    COUNT(*) AS new_customers,
    ROUND(SUM(total_spend), 2) AS cohort_revenue,
    ROUND(AVG(total_spend), 2) AS avg_customer_value
FROM (
    SELECT
        customer_id,
        MIN(order_date) AS first_order,
        SUM(total_amount) AS total_spend
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id
)
GROUP BY strftime('%Y-%m', first_order)
ORDER BY cohort_month DESC;

-- Revenue by customer segment
SELECT
    c.customer_type,
    strftime('%Y', o.order_date) AS year,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT o.customer_id) AS customers,
    ROUND(SUM(o.total_amount), 2) AS revenue,
    ROUND(AVG(o.total_amount), 2) AS avg_order_value
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
WHERE o.status = 'Completed'
GROUP BY c.customer_type, strftime('%Y', o.order_date)
ORDER BY year DESC, revenue DESC;

-- Product category revenue trends (for product-level forecasting)
SELECT
    p.category,
    strftime('%Y-%m', o.order_date) AS month,
    ROUND(SUM(oi.line_total), 2) AS category_revenue,
    SUM(oi.quantity) AS units_sold
FROM orders o
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN products p ON oi.product_id = p.product_id
WHERE o.status = 'Completed'
GROUP BY p.category, strftime('%Y-%m', o.order_date)
ORDER BY p.category, month DESC;

-- Simple linear trend data for forecasting
WITH numbered_months AS (
    SELECT
        strftime('%Y-%m', order_date) AS month,
        SUM(total_amount) AS revenue,
        ROW_NUMBER() OVER (ORDER BY strftime('%Y-%m', order_date)) AS month_number
    FROM orders
    WHERE status = 'Completed'
    GROUP BY strftime('%Y-%m', order_date)
)
SELECT
    month,
    month_number,
    ROUND(revenue, 2) AS revenue,
    -- These values can be used for linear regression in external tools
    ROUND(AVG(revenue) OVER (), 2) AS avg_revenue,
    ROUND(AVG(month_number) OVER (), 2) AS avg_month_number
FROM numbered_months
ORDER BY month;
