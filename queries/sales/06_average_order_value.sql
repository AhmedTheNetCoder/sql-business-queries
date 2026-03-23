-- =============================================
-- Query: Average Order Value (AOV) Analysis
-- Category: Sales Analytics
-- Difficulty: Beginner
--
-- Business Question:
-- What is our average order value and how does it vary by segment?
-- Are customers spending more or less over time?
--
-- Use Case:
-- Marketing teams use AOV to measure campaign effectiveness.
-- Sales teams use it to identify upselling opportunities.
-- =============================================

-- Overall AOV metrics
SELECT
    COUNT(*) AS total_orders,
    ROUND(SUM(total_amount), 2) AS total_revenue,
    ROUND(AVG(total_amount), 2) AS average_order_value,
    ROUND(MIN(total_amount), 2) AS min_order_value,
    ROUND(MAX(total_amount), 2) AS max_order_value,
    ROUND(AVG(total_amount) - (SELECT AVG(total_amount) FROM orders WHERE status = 'Completed'), 2) AS aov_vs_avg
FROM orders
WHERE status = 'Completed';

-- =============================================
-- Expected Output:
-- | total_orders | total_revenue | average_order_value | min_order_value | max_order_value |
-- |--------------|---------------|---------------------|-----------------|-----------------|
-- | 75           | 435,850.00    | 5,811.33            | 407.00          | 32,170.00       |
-- =============================================

-- AOV by customer type
SELECT
    c.customer_type,
    COUNT(DISTINCT o.order_id) AS order_count,
    COUNT(DISTINCT o.customer_id) AS customer_count,
    ROUND(SUM(o.total_amount), 2) AS total_revenue,
    ROUND(AVG(o.total_amount), 2) AS avg_order_value,
    ROUND(SUM(o.total_amount) / COUNT(DISTINCT o.customer_id), 2) AS revenue_per_customer
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
WHERE o.status = 'Completed'
GROUP BY c.customer_type
ORDER BY avg_order_value DESC;

-- AOV trend over time
SELECT
    strftime('%Y-%m', order_date) AS month,
    COUNT(*) AS order_count,
    ROUND(AVG(total_amount), 2) AS avg_order_value,
    ROUND(AVG(total_amount) -
          LAG(AVG(total_amount)) OVER (ORDER BY strftime('%Y-%m', order_date)), 2) AS aov_change
FROM orders
WHERE status = 'Completed'
GROUP BY strftime('%Y-%m', order_date)
ORDER BY month DESC
LIMIT 12;

-- AOV by shipping mode
SELECT
    ship_mode,
    COUNT(*) AS order_count,
    ROUND(AVG(total_amount), 2) AS avg_order_value,
    ROUND(AVG(shipping_cost), 2) AS avg_shipping_cost,
    ROUND(AVG(shipping_cost) / AVG(total_amount) * 100, 2) AS shipping_percent_of_order
FROM orders
WHERE status = 'Completed'
GROUP BY ship_mode
ORDER BY avg_order_value DESC;

-- Order value distribution (for histogram)
SELECT
    CASE
        WHEN total_amount < 1000 THEN '< 1,000'
        WHEN total_amount < 2500 THEN '1,000 - 2,499'
        WHEN total_amount < 5000 THEN '2,500 - 4,999'
        WHEN total_amount < 10000 THEN '5,000 - 9,999'
        WHEN total_amount < 20000 THEN '10,000 - 19,999'
        ELSE '20,000+'
    END AS order_value_range,
    COUNT(*) AS order_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders WHERE status = 'Completed'), 2) AS percentage
FROM orders
WHERE status = 'Completed'
GROUP BY order_value_range
ORDER BY MIN(total_amount);
