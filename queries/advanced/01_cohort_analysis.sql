-- =============================================
-- Query: Customer Cohort Analysis
-- Category: Advanced Analytics
-- Difficulty: Advanced
--
-- Business Question:
-- How do customer cohorts behave over time?
-- What is the retention and revenue pattern by acquisition month?
--
-- Use Case:
-- Customer lifecycle analysis, marketing ROI,
-- retention strategies, and LTV prediction.
-- =============================================

-- Customer cohort definition
WITH customer_cohorts AS (
    SELECT
        customer_id,
        strftime('%Y-%m', MIN(order_date)) AS cohort_month,
        MIN(order_date) AS first_order_date
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id
),
customer_activities AS (
    SELECT
        o.customer_id,
        cc.cohort_month,
        strftime('%Y-%m', o.order_date) AS activity_month,
        (CAST(strftime('%Y', o.order_date) AS INTEGER) - CAST(strftime('%Y', cc.first_order_date) AS INTEGER)) * 12 +
        (CAST(strftime('%m', o.order_date) AS INTEGER) - CAST(strftime('%m', cc.first_order_date) AS INTEGER)) AS months_since_first
    FROM orders o
    INNER JOIN customer_cohorts cc ON o.customer_id = cc.customer_id
    WHERE o.status = 'Completed'
)
SELECT
    cohort_month,
    months_since_first,
    COUNT(DISTINCT customer_id) AS active_customers
FROM customer_activities
GROUP BY cohort_month, months_since_first
ORDER BY cohort_month, months_since_first;

-- =============================================
-- Expected Output:
-- | cohort_month | months_since_first | active_customers |
-- |--------------|---------------------|------------------|
-- | 2023-01      | 0                   | 15               |
-- | 2023-01      | 1                   | 8                |
-- | 2023-01      | 2                   | 6                |
-- =============================================

-- Cohort retention matrix
WITH customer_cohorts AS (
    SELECT
        customer_id,
        strftime('%Y-%m', MIN(order_date)) AS cohort_month
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id
),
cohort_size AS (
    SELECT cohort_month, COUNT(*) AS total_customers
    FROM customer_cohorts
    GROUP BY cohort_month
),
monthly_activity AS (
    SELECT
        cc.cohort_month,
        strftime('%Y-%m', o.order_date) AS activity_month,
        COUNT(DISTINCT o.customer_id) AS active_customers
    FROM orders o
    INNER JOIN customer_cohorts cc ON o.customer_id = cc.customer_id
    WHERE o.status = 'Completed'
    GROUP BY cc.cohort_month, strftime('%Y-%m', o.order_date)
)
SELECT
    ma.cohort_month,
    cs.total_customers AS cohort_size,
    ma.activity_month,
    ma.active_customers,
    ROUND(ma.active_customers * 100.0 / cs.total_customers, 2) AS retention_pct
FROM monthly_activity ma
INNER JOIN cohort_size cs ON ma.cohort_month = cs.cohort_month
ORDER BY ma.cohort_month, ma.activity_month;

-- Cohort revenue analysis
WITH customer_cohorts AS (
    SELECT
        customer_id,
        strftime('%Y-%m', MIN(order_date)) AS cohort_month
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id
)
SELECT
    cc.cohort_month,
    COUNT(DISTINCT cc.customer_id) AS cohort_size,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(o.total_amount), 2) AS total_revenue,
    ROUND(SUM(o.total_amount) / COUNT(DISTINCT cc.customer_id), 2) AS revenue_per_customer,
    ROUND(COUNT(o.order_id) * 1.0 / COUNT(DISTINCT cc.customer_id), 2) AS orders_per_customer
FROM customer_cohorts cc
INNER JOIN orders o ON cc.customer_id = o.customer_id AND o.status = 'Completed'
GROUP BY cc.cohort_month
ORDER BY cc.cohort_month;

-- Customer lifetime value by cohort
WITH customer_cohorts AS (
    SELECT
        customer_id,
        strftime('%Y-%m', MIN(order_date)) AS cohort_month
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id
),
customer_ltv AS (
    SELECT
        cc.customer_id,
        cc.cohort_month,
        SUM(o.total_amount) AS lifetime_value,
        COUNT(o.order_id) AS order_count,
        MAX(o.order_date) AS last_order
    FROM customer_cohorts cc
    INNER JOIN orders o ON cc.customer_id = o.customer_id AND o.status = 'Completed'
    GROUP BY cc.customer_id, cc.cohort_month
)
SELECT
    cohort_month,
    COUNT(*) AS customers,
    ROUND(AVG(lifetime_value), 2) AS avg_ltv,
    ROUND(MIN(lifetime_value), 2) AS min_ltv,
    ROUND(MAX(lifetime_value), 2) AS max_ltv,
    ROUND(AVG(order_count), 2) AS avg_orders
FROM customer_ltv
GROUP BY cohort_month
ORDER BY cohort_month;

-- First vs repeat purchase analysis by cohort
WITH customer_cohorts AS (
    SELECT
        customer_id,
        strftime('%Y-%m', MIN(order_date)) AS cohort_month
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id
),
customer_orders AS (
    SELECT
        cc.customer_id,
        cc.cohort_month,
        o.order_id,
        o.total_amount,
        ROW_NUMBER() OVER (PARTITION BY cc.customer_id ORDER BY o.order_date) AS order_number
    FROM customer_cohorts cc
    INNER JOIN orders o ON cc.customer_id = o.customer_id AND o.status = 'Completed'
)
SELECT
    cohort_month,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(CASE WHEN order_number = 1 THEN total_amount ELSE 0 END), 2) AS first_order_revenue,
    ROUND(SUM(CASE WHEN order_number > 1 THEN total_amount ELSE 0 END), 2) AS repeat_revenue,
    COUNT(CASE WHEN order_number > 1 THEN 1 END) AS repeat_orders,
    COUNT(DISTINCT CASE WHEN order_number > 1 THEN customer_id END) AS repeat_customers,
    ROUND(COUNT(DISTINCT CASE WHEN order_number > 1 THEN customer_id END) * 100.0 /
          COUNT(DISTINCT customer_id), 2) AS repeat_rate
FROM customer_orders
GROUP BY cohort_month
ORDER BY cohort_month;

-- Cohort churn analysis
WITH customer_cohorts AS (
    SELECT
        customer_id,
        strftime('%Y-%m', MIN(order_date)) AS cohort_month,
        strftime('%Y-%m', MAX(order_date)) AS last_active_month
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id
)
SELECT
    cohort_month,
    COUNT(*) AS cohort_size,
    SUM(CASE WHEN last_active_month = cohort_month THEN 1 ELSE 0 END) AS one_time_buyers,
    SUM(CASE WHEN last_active_month < strftime('%Y-%m', 'now', '-3 months') THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN last_active_month < strftime('%Y-%m', 'now', '-3 months') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate
FROM customer_cohorts
GROUP BY cohort_month
ORDER BY cohort_month;
