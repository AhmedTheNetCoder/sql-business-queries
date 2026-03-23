-- =============================================
-- Query: Top Customers by Lifetime Revenue
-- Category: Sales Analytics
-- Difficulty: Beginner
--
-- Business Question:
-- Who are our most valuable customers based on total purchase history?
-- What is their buying pattern and frequency?
--
-- Use Case:
-- Identify VIP customers for loyalty programs, personalized
-- marketing, and retention efforts.
-- =============================================

-- Top 20 customers by lifetime value
SELECT
    c.customer_id,
    c.customer_name,
    c.customer_type,
    c.city,
    c.region,
    COUNT(DISTINCT o.order_id) AS total_orders,
    MIN(o.order_date) AS first_order,
    MAX(o.order_date) AS last_order,
    ROUND(JULIANDAY(MAX(o.order_date)) - JULIANDAY(MIN(o.order_date)), 0) AS customer_tenure_days,
    ROUND(SUM(o.total_amount), 2) AS lifetime_value,
    ROUND(AVG(o.total_amount), 2) AS avg_order_value,
    ROUND(JULIANDAY('now') - JULIANDAY(MAX(o.order_date)), 0) AS days_since_last_order
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status = 'Completed'
GROUP BY c.customer_id, c.customer_name, c.customer_type, c.city, c.region
ORDER BY lifetime_value DESC
LIMIT 20;

-- =============================================
-- Expected Output:
-- | customer_id | customer_name | customer_type | lifetime_value | avg_order_value | total_orders |
-- |-------------|---------------|---------------|----------------|-----------------|--------------|
-- | 25          | PDO           | Business      | 125,430.00     | 25,086.00       | 5            |
-- | 24          | Oman Air      | Business      | 98,200.00      | 19,640.00       | 5            |
-- | 9           | Royal Oman    | Government    | 85,150.00      | 17,030.00       | 5            |
-- =============================================

-- Customer segmentation by value tier
WITH customer_values AS (
    SELECT
        c.customer_id,
        c.customer_name,
        c.customer_type,
        SUM(o.total_amount) AS lifetime_value
    FROM customers c
    INNER JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.status = 'Completed'
    GROUP BY c.customer_id, c.customer_name, c.customer_type
)
SELECT
    CASE
        WHEN lifetime_value >= 50000 THEN 'Platinum'
        WHEN lifetime_value >= 20000 THEN 'Gold'
        WHEN lifetime_value >= 5000 THEN 'Silver'
        ELSE 'Bronze'
    END AS value_tier,
    COUNT(*) AS customer_count,
    ROUND(SUM(lifetime_value), 2) AS total_revenue,
    ROUND(AVG(lifetime_value), 2) AS avg_customer_value
FROM customer_values
GROUP BY value_tier
ORDER BY avg_customer_value DESC;
