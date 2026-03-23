-- =============================================
-- Query: Seasonal Sales Patterns
-- Category: Sales Analytics
-- Difficulty: Intermediate
--
-- Business Question:
-- What are our seasonal sales patterns? When are peak and
-- slow periods? How should we plan inventory and promotions?
--
-- Use Case:
-- Demand forecasting, inventory planning, marketing calendar
-- optimization, and staffing decisions.
-- =============================================

-- Monthly seasonality (average across years)
SELECT
    CAST(strftime('%m', order_date) AS INTEGER) AS month_number,
    CASE CAST(strftime('%m', order_date) AS INTEGER)
        WHEN 1 THEN 'January'
        WHEN 2 THEN 'February'
        WHEN 3 THEN 'March'
        WHEN 4 THEN 'April'
        WHEN 5 THEN 'May'
        WHEN 6 THEN 'June'
        WHEN 7 THEN 'July'
        WHEN 8 THEN 'August'
        WHEN 9 THEN 'September'
        WHEN 10 THEN 'October'
        WHEN 11 THEN 'November'
        WHEN 12 THEN 'December'
    END AS month_name,
    COUNT(*) AS total_orders,
    ROUND(AVG(total_amount), 2) AS avg_order_value,
    ROUND(SUM(total_amount), 2) AS total_revenue,
    ROUND(SUM(total_amount) * 100.0 /
          (SELECT SUM(total_amount) FROM orders WHERE status = 'Completed'), 2) AS revenue_share
FROM orders
WHERE status = 'Completed'
GROUP BY month_number, month_name
ORDER BY month_number;

-- =============================================
-- Expected Output:
-- | month_name | total_orders | avg_order_value | total_revenue | revenue_share |
-- |------------|--------------|-----------------|---------------|---------------|
-- | January    | 8            | 8,245.50        | 65,964.00     | 15.13         |
-- | February   | 6            | 5,890.25        | 35,341.50     | 8.11          |
-- | November   | 10           | 9,125.00        | 91,250.00     | 20.94         |
-- | December   | 9            | 7,845.00        | 70,605.00     | 16.20         |
-- =============================================

-- Quarterly analysis
SELECT
    strftime('%Y', order_date) AS year,
    CASE
        WHEN CAST(strftime('%m', order_date) AS INTEGER) BETWEEN 1 AND 3 THEN 'Q1'
        WHEN CAST(strftime('%m', order_date) AS INTEGER) BETWEEN 4 AND 6 THEN 'Q2'
        WHEN CAST(strftime('%m', order_date) AS INTEGER) BETWEEN 7 AND 9 THEN 'Q3'
        ELSE 'Q4'
    END AS quarter,
    COUNT(*) AS orders,
    ROUND(SUM(total_amount), 2) AS revenue,
    ROUND(AVG(total_amount), 2) AS avg_order_value
FROM orders
WHERE status = 'Completed'
GROUP BY year, quarter
ORDER BY year DESC, quarter;

-- Identify peak periods (above average months)
WITH monthly_avg AS (
    SELECT AVG(monthly_revenue) AS avg_monthly_revenue
    FROM (
        SELECT SUM(total_amount) AS monthly_revenue
        FROM orders
        WHERE status = 'Completed'
        GROUP BY strftime('%Y-%m', order_date)
    )
)
SELECT
    strftime('%Y-%m', order_date) AS month,
    ROUND(SUM(total_amount), 2) AS revenue,
    ROUND((SELECT avg_monthly_revenue FROM monthly_avg), 2) AS avg_monthly,
    CASE
        WHEN SUM(total_amount) >= (SELECT avg_monthly_revenue * 1.2 FROM monthly_avg) THEN 'Peak'
        WHEN SUM(total_amount) <= (SELECT avg_monthly_revenue * 0.8 FROM monthly_avg) THEN 'Slow'
        ELSE 'Normal'
    END AS period_type
FROM orders
WHERE status = 'Completed'
GROUP BY strftime('%Y-%m', order_date)
ORDER BY month DESC;

-- Category seasonality - which products sell when
SELECT
    CASE CAST(strftime('%m', o.order_date) AS INTEGER)
        WHEN 1 THEN 'Jan' WHEN 2 THEN 'Feb' WHEN 3 THEN 'Mar'
        WHEN 4 THEN 'Apr' WHEN 5 THEN 'May' WHEN 6 THEN 'Jun'
        WHEN 7 THEN 'Jul' WHEN 8 THEN 'Aug' WHEN 9 THEN 'Sep'
        WHEN 10 THEN 'Oct' WHEN 11 THEN 'Nov' WHEN 12 THEN 'Dec'
    END AS month,
    p.category,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.line_total), 2) AS revenue
FROM orders o
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN products p ON oi.product_id = p.product_id
WHERE o.status = 'Completed'
GROUP BY CAST(strftime('%m', o.order_date) AS INTEGER), p.category
ORDER BY CAST(strftime('%m', o.order_date) AS INTEGER), revenue DESC;

-- Holiday period analysis (Eid, National Day, etc.)
-- Note: Dates would need to be adjusted for actual Omani holidays
SELECT
    CASE
        WHEN strftime('%m-%d', order_date) BETWEEN '11-15' AND '11-25' THEN 'National Day Period'
        WHEN strftime('%m-%d', order_date) BETWEEN '12-20' AND '12-31' THEN 'Year End'
        WHEN strftime('%m', order_date) IN ('01', '02') THEN 'Q1 Start'
        ELSE 'Regular Period'
    END AS period,
    COUNT(*) AS orders,
    ROUND(SUM(total_amount), 2) AS revenue,
    ROUND(AVG(total_amount), 2) AS avg_order_value
FROM orders
WHERE status = 'Completed'
GROUP BY period
ORDER BY revenue DESC;
