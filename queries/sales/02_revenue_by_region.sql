-- =============================================
-- Query: Revenue by Region Analysis
-- Category: Sales Analytics
-- Difficulty: Beginner
--
-- Business Question:
-- How does revenue performance vary across different regions?
-- Which regions are underperforming or overperforming?
--
-- Use Case:
-- Regional managers need to compare performance across territories
-- to allocate resources and set regional targets.
-- =============================================

-- Revenue breakdown by region
SELECT
    region,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers,
    ROUND(SUM(total_amount), 2) AS total_revenue,
    ROUND(AVG(total_amount), 2) AS avg_order_value,
    ROUND(SUM(total_amount) * 100.0 / (SELECT SUM(total_amount) FROM orders WHERE status = 'Completed'), 2) AS revenue_share_percent
FROM orders
WHERE status = 'Completed'
GROUP BY region
ORDER BY total_revenue DESC;

-- =============================================
-- Expected Output:
-- | region        | total_orders | unique_customers | total_revenue | avg_order_value | revenue_share_percent |
-- |---------------|--------------|------------------|---------------|-----------------|----------------------|
-- | Muscat        | 45           | 12               | 285,430.00    | 6,342.89        | 65.50                |
-- | Al Batinah    | 12           | 3                | 75,200.00     | 6,266.67        | 17.25                |
-- | Dhofar        | 10           | 4                | 45,800.00     | 4,580.00        | 10.51                |
-- =============================================

-- Region performance with year-over-year comparison
WITH regional_yearly AS (
    SELECT
        region,
        strftime('%Y', order_date) AS year,
        SUM(total_amount) AS revenue
    FROM orders
    WHERE status = 'Completed'
    GROUP BY region, strftime('%Y', order_date)
)
SELECT
    r1.region,
    ROUND(r1.revenue, 2) AS current_year_revenue,
    ROUND(r2.revenue, 2) AS previous_year_revenue,
    ROUND(
        CASE
            WHEN r2.revenue IS NOT NULL AND r2.revenue > 0
            THEN ((r1.revenue - r2.revenue) / r2.revenue) * 100
            ELSE NULL
        END,
    2) AS yoy_growth_percent
FROM regional_yearly r1
LEFT JOIN regional_yearly r2
    ON r1.region = r2.region
    AND CAST(r1.year AS INTEGER) = CAST(r2.year AS INTEGER) + 1
WHERE r1.year = strftime('%Y', 'now')
ORDER BY r1.revenue DESC;
