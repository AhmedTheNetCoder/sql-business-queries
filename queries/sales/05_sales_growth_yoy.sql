-- =============================================
-- Query: Year-over-Year Sales Growth
-- Category: Sales Analytics
-- Difficulty: Intermediate
--
-- Business Question:
-- How does our sales performance compare to the same period last year?
-- Are we growing or declining?
--
-- Use Case:
-- Executive dashboards and board reports require YoY comparisons
-- to understand business trajectory.
-- =============================================

-- Monthly YoY comparison
WITH monthly_sales AS (
    SELECT
        strftime('%Y', order_date) AS year,
        strftime('%m', order_date) AS month,
        strftime('%Y-%m', order_date) AS year_month,
        SUM(total_amount) AS revenue,
        COUNT(DISTINCT order_id) AS order_count,
        COUNT(DISTINCT customer_id) AS customer_count
    FROM orders
    WHERE status = 'Completed'
    GROUP BY strftime('%Y', order_date), strftime('%m', order_date)
)
SELECT
    curr.year_month AS current_period,
    ROUND(curr.revenue, 2) AS current_revenue,
    prev.year_month AS previous_period,
    ROUND(prev.revenue, 2) AS previous_revenue,
    ROUND(curr.revenue - prev.revenue, 2) AS revenue_change,
    ROUND(
        CASE
            WHEN prev.revenue > 0
            THEN ((curr.revenue - prev.revenue) / prev.revenue) * 100
            ELSE NULL
        END,
    2) AS growth_percent,
    curr.order_count AS current_orders,
    prev.order_count AS previous_orders
FROM monthly_sales curr
LEFT JOIN monthly_sales prev
    ON curr.month = prev.month
    AND CAST(curr.year AS INTEGER) = CAST(prev.year AS INTEGER) + 1
WHERE curr.year = strftime('%Y', 'now')
    OR curr.year = strftime('%Y', 'now', '-1 year')
ORDER BY curr.year_month DESC;

-- =============================================
-- Expected Output:
-- | current_period | current_revenue | previous_period | previous_revenue | growth_percent |
-- |----------------|-----------------|-----------------|------------------|----------------|
-- | 2024-03        | 48,778.75       | 2023-03         | 38,234.50        | 27.58          |
-- | 2024-02        | 38,838.50       | 2023-02         | 32,156.25        | 20.78          |
-- =============================================

-- Quarterly YoY comparison
WITH quarterly_sales AS (
    SELECT
        strftime('%Y', order_date) AS year,
        CASE
            WHEN CAST(strftime('%m', order_date) AS INTEGER) BETWEEN 1 AND 3 THEN 'Q1'
            WHEN CAST(strftime('%m', order_date) AS INTEGER) BETWEEN 4 AND 6 THEN 'Q2'
            WHEN CAST(strftime('%m', order_date) AS INTEGER) BETWEEN 7 AND 9 THEN 'Q3'
            ELSE 'Q4'
        END AS quarter,
        SUM(total_amount) AS revenue
    FROM orders
    WHERE status = 'Completed'
    GROUP BY strftime('%Y', order_date), quarter
)
SELECT
    curr.year || '-' || curr.quarter AS current_quarter,
    ROUND(curr.revenue, 2) AS current_revenue,
    prev.year || '-' || prev.quarter AS previous_quarter,
    ROUND(prev.revenue, 2) AS previous_revenue,
    ROUND(
        CASE
            WHEN prev.revenue > 0
            THEN ((curr.revenue - prev.revenue) / prev.revenue) * 100
            ELSE NULL
        END,
    2) AS yoy_growth_percent
FROM quarterly_sales curr
LEFT JOIN quarterly_sales prev
    ON curr.quarter = prev.quarter
    AND CAST(curr.year AS INTEGER) = CAST(prev.year AS INTEGER) + 1
ORDER BY curr.year DESC, curr.quarter DESC;

-- Cumulative YTD comparison
WITH daily_sales AS (
    SELECT
        order_date,
        strftime('%Y', order_date) AS year,
        strftime('%j', order_date) AS day_of_year,
        total_amount
    FROM orders
    WHERE status = 'Completed'
)
SELECT
    year,
    ROUND(SUM(total_amount), 2) AS ytd_revenue,
    COUNT(*) AS ytd_orders
FROM daily_sales
WHERE CAST(day_of_year AS INTEGER) <= CAST(strftime('%j', 'now') AS INTEGER)
GROUP BY year
ORDER BY year DESC;
