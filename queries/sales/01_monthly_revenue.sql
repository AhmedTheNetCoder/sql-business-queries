-- =============================================
-- Query: Monthly Revenue Analysis
-- Category: Sales Analytics
-- Difficulty: Beginner
--
-- Business Question:
-- What is our total revenue for each month, and how does it compare
-- to the previous month?
--
-- Use Case:
-- Finance and sales teams need to track monthly revenue trends
-- to identify growth patterns and seasonal variations.
-- =============================================

-- Basic monthly revenue
SELECT
    strftime('%Y-%m', order_date) AS month,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers,
    ROUND(SUM(total_amount), 2) AS total_revenue,
    ROUND(AVG(total_amount), 2) AS avg_order_value
FROM orders
WHERE status IN ('Completed', 'Delivered')
GROUP BY strftime('%Y-%m', order_date)
ORDER BY month DESC;

-- =============================================
-- Expected Output:
-- | month   | total_orders | unique_customers | total_revenue | avg_order_value |
-- |---------|--------------|------------------|---------------|-----------------|
-- | 2024-03 | 4            | 4                | 48,778.75     | 12,194.69       |
-- | 2024-02 | 5            | 5                | 38,838.50     | 7,767.70        |
-- | 2024-01 | 5            | 5                | 64,766.00     | 12,953.20       |
-- =============================================

-- Advanced: With month-over-month growth
WITH monthly_revenue AS (
    SELECT
        strftime('%Y-%m', order_date) AS month,
        SUM(total_amount) AS revenue
    FROM orders
    WHERE status IN ('Completed', 'Delivered')
    GROUP BY strftime('%Y-%m', order_date)
)
SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(LAG(revenue) OVER (ORDER BY month), 2) AS prev_month_revenue,
    ROUND(
        CASE
            WHEN LAG(revenue) OVER (ORDER BY month) IS NOT NULL
            THEN ((revenue - LAG(revenue) OVER (ORDER BY month)) /
                  LAG(revenue) OVER (ORDER BY month)) * 100
            ELSE NULL
        END,
    2) AS growth_percent
FROM monthly_revenue
ORDER BY month DESC;
