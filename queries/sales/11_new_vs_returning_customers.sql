-- =============================================
-- Query: New vs Returning Customer Analysis
-- Category: Sales Analytics
-- Difficulty: Intermediate
--
-- Business Question:
-- What proportion of revenue comes from new vs returning customers?
-- Are we acquiring enough new customers while retaining existing ones?
--
-- Use Case:
-- Marketing teams for acquisition vs retention budget allocation.
-- Growth analysis for investor reporting.
-- =============================================

-- Identify new vs returning for each order
WITH customer_orders AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_date,
        o.total_amount,
        ROW_NUMBER() OVER (PARTITION BY o.customer_id ORDER BY o.order_date) AS order_sequence
    FROM orders o
    WHERE o.status = 'Completed'
)
SELECT
    strftime('%Y-%m', order_date) AS month,
    COUNT(CASE WHEN order_sequence = 1 THEN 1 END) AS new_customer_orders,
    COUNT(CASE WHEN order_sequence > 1 THEN 1 END) AS returning_customer_orders,
    ROUND(SUM(CASE WHEN order_sequence = 1 THEN total_amount ELSE 0 END), 2) AS new_customer_revenue,
    ROUND(SUM(CASE WHEN order_sequence > 1 THEN total_amount ELSE 0 END), 2) AS returning_customer_revenue,
    ROUND(SUM(CASE WHEN order_sequence = 1 THEN total_amount ELSE 0 END) * 100.0 / SUM(total_amount), 2) AS new_revenue_percent
FROM customer_orders
GROUP BY strftime('%Y-%m', order_date)
ORDER BY month DESC
LIMIT 12;

-- =============================================
-- Expected Output:
-- | month   | new_customer_orders | returning_customer_orders | new_revenue_percent |
-- |---------|---------------------|---------------------------|---------------------|
-- | 2024-03 | 2                   | 6                         | 15.50               |
-- | 2024-02 | 1                   | 8                         | 8.25                |
-- =============================================

-- Customer cohort analysis - when did current customers first purchase?
SELECT
    strftime('%Y-%m', first_order) AS acquisition_cohort,
    COUNT(DISTINCT customer_id) AS customers_acquired,
    ROUND(SUM(lifetime_value), 2) AS cohort_lifetime_value,
    ROUND(AVG(lifetime_value), 2) AS avg_customer_value,
    ROUND(AVG(order_count), 1) AS avg_orders_per_customer
FROM (
    SELECT
        customer_id,
        MIN(order_date) AS first_order,
        COUNT(*) AS order_count,
        SUM(total_amount) AS lifetime_value
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id
)
GROUP BY strftime('%Y-%m', first_order)
ORDER BY acquisition_cohort DESC;

-- New customer acquisition trend
SELECT
    strftime('%Y-%m', first_order_date) AS month,
    COUNT(*) AS new_customers,
    LAG(COUNT(*)) OVER (ORDER BY strftime('%Y-%m', first_order_date)) AS prev_month_new,
    ROUND(
        (COUNT(*) - LAG(COUNT(*)) OVER (ORDER BY strftime('%Y-%m', first_order_date))) * 100.0 /
        LAG(COUNT(*)) OVER (ORDER BY strftime('%Y-%m', first_order_date)),
    2) AS growth_percent
FROM (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id
)
GROUP BY strftime('%Y-%m', first_order_date)
ORDER BY month DESC
LIMIT 12;

-- Customer retention: did they come back?
WITH first_orders AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date,
        strftime('%Y-%m', MIN(order_date)) AS cohort
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id
),
all_orders AS (
    SELECT
        o.customer_id,
        f.cohort,
        o.order_date,
        o.total_amount
    FROM orders o
    INNER JOIN first_orders f ON o.customer_id = f.customer_id
    WHERE o.status = 'Completed'
)
SELECT
    cohort,
    COUNT(DISTINCT customer_id) AS cohort_size,
    COUNT(DISTINCT CASE
        WHEN order_date > DATE(cohort || '-01', '+1 month')
             AND order_date <= DATE(cohort || '-01', '+2 month')
        THEN customer_id END) AS returned_month_1,
    ROUND(COUNT(DISTINCT CASE
        WHEN order_date > DATE(cohort || '-01', '+1 month')
             AND order_date <= DATE(cohort || '-01', '+2 month')
        THEN customer_id END) * 100.0 / COUNT(DISTINCT customer_id), 2) AS retention_month_1
FROM all_orders
GROUP BY cohort
HAVING cohort_size >= 2
ORDER BY cohort DESC
LIMIT 6;
