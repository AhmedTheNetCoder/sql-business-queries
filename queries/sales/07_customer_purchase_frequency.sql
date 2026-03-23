-- =============================================
-- Query: Customer Purchase Frequency Analysis
-- Category: Sales Analytics
-- Difficulty: Intermediate
--
-- Business Question:
-- How often do customers make purchases? Who are our most
-- frequent buyers vs one-time customers?
--
-- Use Case:
-- Identify customer loyalty patterns, optimize retention
-- strategies, and predict repeat purchase behavior.
-- =============================================

-- Purchase frequency by customer
SELECT
    c.customer_id,
    c.customer_name,
    c.customer_type,
    COUNT(o.order_id) AS total_orders,
    MIN(o.order_date) AS first_purchase,
    MAX(o.order_date) AS last_purchase,
    ROUND(JULIANDAY(MAX(o.order_date)) - JULIANDAY(MIN(o.order_date)), 0) AS days_as_customer,
    CASE
        WHEN COUNT(o.order_id) > 1
        THEN ROUND((JULIANDAY(MAX(o.order_date)) - JULIANDAY(MIN(o.order_date))) / (COUNT(o.order_id) - 1), 1)
        ELSE NULL
    END AS avg_days_between_orders,
    ROUND(SUM(o.total_amount), 2) AS lifetime_value
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status = 'Completed'
GROUP BY c.customer_id, c.customer_name, c.customer_type
ORDER BY total_orders DESC;

-- =============================================
-- Expected Output:
-- | customer_name | customer_type | total_orders | avg_days_between_orders | lifetime_value |
-- |---------------|---------------|--------------|-------------------------|----------------|
-- | PDO           | Business      | 8            | 45.5                    | 152,430.00     |
-- | Oman Air      | Business      | 7            | 52.3                    | 128,500.00     |
-- =============================================

-- Customer frequency segmentation
WITH customer_orders AS (
    SELECT
        c.customer_id,
        c.customer_name,
        c.customer_type,
        COUNT(o.order_id) AS order_count,
        SUM(o.total_amount) AS total_spent
    FROM customers c
    INNER JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.status = 'Completed'
    GROUP BY c.customer_id, c.customer_name, c.customer_type
)
SELECT
    CASE
        WHEN order_count = 1 THEN 'One-time'
        WHEN order_count BETWEEN 2 AND 3 THEN 'Occasional'
        WHEN order_count BETWEEN 4 AND 6 THEN 'Regular'
        ELSE 'Loyal'
    END AS frequency_segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(order_count), 1) AS avg_orders,
    ROUND(SUM(total_spent), 2) AS segment_revenue,
    ROUND(AVG(total_spent), 2) AS avg_customer_value
FROM customer_orders
GROUP BY frequency_segment
ORDER BY avg_orders DESC;

-- Repeat purchase rate
SELECT
    COUNT(DISTINCT CASE WHEN order_count > 1 THEN customer_id END) AS repeat_customers,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(
        COUNT(DISTINCT CASE WHEN order_count > 1 THEN customer_id END) * 100.0 /
        COUNT(DISTINCT customer_id),
    2) AS repeat_purchase_rate
FROM (
    SELECT
        customer_id,
        COUNT(*) AS order_count
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id
);

-- Time to second purchase
WITH first_second_orders AS (
    SELECT
        customer_id,
        order_date,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS order_number
    FROM orders
    WHERE status = 'Completed'
)
SELECT
    ROUND(AVG(days_to_second), 1) AS avg_days_to_second_purchase,
    MIN(days_to_second) AS min_days,
    MAX(days_to_second) AS max_days
FROM (
    SELECT
        f1.customer_id,
        JULIANDAY(f2.order_date) - JULIANDAY(f1.order_date) AS days_to_second
    FROM first_second_orders f1
    INNER JOIN first_second_orders f2
        ON f1.customer_id = f2.customer_id
        AND f1.order_number = 1
        AND f2.order_number = 2
);
