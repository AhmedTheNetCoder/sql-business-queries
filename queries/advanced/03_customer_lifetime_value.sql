-- =============================================
-- Query: Customer Lifetime Value (CLV) Analysis
-- Category: Advanced Analytics
-- Difficulty: Advanced
--
-- Business Question:
-- What is the lifetime value of our customers?
-- How can we predict future customer value?
--
-- Use Case:
-- Customer acquisition budgeting, retention investment,
-- customer prioritization, and marketing ROI.
-- =============================================

-- Basic CLV calculation
SELECT
    c.customer_id,
    c.company_name,
    c.customer_type,
    MIN(o.order_date) AS first_order,
    MAX(o.order_date) AS last_order,
    ROUND(JULIANDAY(MAX(o.order_date)) - JULIANDAY(MIN(o.order_date)), 0) AS customer_tenure_days,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(o.total_amount), 2) AS lifetime_value,
    ROUND(AVG(o.total_amount), 2) AS avg_order_value,
    ROUND(SUM(o.total_amount) / NULLIF(ROUND((JULIANDAY(MAX(o.order_date)) - JULIANDAY(MIN(o.order_date))) / 30, 1), 0), 2) AS monthly_value
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status = 'Completed'
GROUP BY c.customer_id, c.company_name, c.customer_type
ORDER BY lifetime_value DESC;

-- =============================================
-- Expected Output:
-- | company_name      | customer_type | total_orders | lifetime_value | avg_order_value |
-- |-------------------|---------------|--------------|----------------|-----------------|
-- | PDO               | Enterprise    | 24           | 125,430.00     | 5,226.25        |
-- | Oman National Bank| Enterprise    | 18           | 98,750.00      | 5,486.11        |
-- =============================================

-- CLV by customer segment
SELECT
    c.customer_type,
    COUNT(DISTINCT c.customer_id) AS customers,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(o.total_amount), 2) AS total_revenue,
    ROUND(AVG(o.total_amount), 2) AS avg_order_value,
    ROUND(SUM(o.total_amount) / COUNT(DISTINCT c.customer_id), 2) AS avg_ltv,
    ROUND(COUNT(o.order_id) * 1.0 / COUNT(DISTINCT c.customer_id), 2) AS avg_orders_per_customer
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status = 'Completed'
GROUP BY c.customer_type
ORDER BY avg_ltv DESC;

-- CLV distribution tiers
WITH customer_ltv AS (
    SELECT
        c.customer_id,
        c.company_name,
        c.customer_type,
        SUM(o.total_amount) AS lifetime_value
    FROM customers c
    INNER JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.status = 'Completed'
    GROUP BY c.customer_id, c.company_name, c.customer_type
)
SELECT
    CASE
        WHEN lifetime_value >= 50000 THEN 'Platinum (50K+)'
        WHEN lifetime_value >= 20000 THEN 'Gold (20K-50K)'
        WHEN lifetime_value >= 10000 THEN 'Silver (10K-20K)'
        WHEN lifetime_value >= 5000 THEN 'Bronze (5K-10K)'
        ELSE 'Standard (<5K)'
    END AS ltv_tier,
    COUNT(*) AS customer_count,
    ROUND(SUM(lifetime_value), 2) AS tier_total_value,
    ROUND(AVG(lifetime_value), 2) AS avg_ltv,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customer_ltv), 2) AS pct_of_customers,
    ROUND(SUM(lifetime_value) * 100.0 / (SELECT SUM(lifetime_value) FROM customer_ltv), 2) AS pct_of_revenue
FROM customer_ltv
GROUP BY ltv_tier
ORDER BY avg_ltv DESC;

-- Predictive CLV components
WITH customer_metrics AS (
    SELECT
        c.customer_id,
        c.company_name,
        COUNT(o.order_id) AS order_count,
        SUM(o.total_amount) AS total_revenue,
        AVG(o.total_amount) AS avg_order_value,
        JULIANDAY(MAX(o.order_date)) - JULIANDAY(MIN(o.order_date)) AS tenure_days,
        COUNT(o.order_id) * 1.0 / NULLIF((JULIANDAY(MAX(o.order_date)) - JULIANDAY(MIN(o.order_date))) / 30, 0) AS purchase_frequency
    FROM customers c
    INNER JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.status = 'Completed'
    GROUP BY c.customer_id, c.company_name
    HAVING COUNT(o.order_id) >= 2
)
SELECT
    customer_id,
    company_name,
    order_count,
    ROUND(total_revenue, 2) AS historical_ltv,
    ROUND(avg_order_value, 2) AS aov,
    ROUND(purchase_frequency, 2) AS monthly_frequency,
    ROUND(tenure_days / 365.0, 1) AS tenure_years,
    -- Simple projected 3-year LTV: AOV * monthly_frequency * 36 months
    ROUND(avg_order_value * purchase_frequency * 36, 2) AS projected_3yr_ltv
FROM customer_metrics
ORDER BY projected_3yr_ltv DESC;

-- CLV by acquisition channel (region as proxy)
SELECT
    r.region_name AS acquisition_region,
    COUNT(DISTINCT c.customer_id) AS customers,
    ROUND(SUM(o.total_amount), 2) AS total_ltv,
    ROUND(SUM(o.total_amount) / COUNT(DISTINCT c.customer_id), 2) AS avg_ltv,
    COUNT(o.order_id) AS total_orders,
    ROUND(COUNT(o.order_id) * 1.0 / COUNT(DISTINCT c.customer_id), 2) AS avg_orders
FROM customers c
INNER JOIN regions r ON c.region_id = r.region_id
INNER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status = 'Completed'
GROUP BY r.region_name
ORDER BY avg_ltv DESC;

-- Top 20 highest LTV customers
WITH customer_ltv AS (
    SELECT
        c.customer_id,
        c.company_name,
        c.customer_type,
        c.email,
        r.region_name,
        SUM(o.total_amount) AS lifetime_value,
        COUNT(o.order_id) AS order_count,
        MIN(o.order_date) AS first_order,
        MAX(o.order_date) AS last_order
    FROM customers c
    INNER JOIN regions r ON c.region_id = r.region_id
    INNER JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.status = 'Completed'
    GROUP BY c.customer_id, c.company_name, c.customer_type, c.email, r.region_name
)
SELECT
    customer_id,
    company_name,
    customer_type,
    region_name,
    ROUND(lifetime_value, 2) AS ltv,
    order_count,
    first_order,
    last_order,
    ROUND(JULIANDAY('now') - JULIANDAY(last_order), 0) AS days_since_last_order,
    CASE
        WHEN JULIANDAY('now') - JULIANDAY(last_order) <= 30 THEN 'Active'
        WHEN JULIANDAY('now') - JULIANDAY(last_order) <= 90 THEN 'At Risk'
        ELSE 'Churned'
    END AS customer_status
FROM customer_ltv
ORDER BY lifetime_value DESC
LIMIT 20;

-- CLV growth over time
WITH monthly_ltv AS (
    SELECT
        strftime('%Y-%m', o.order_date) AS month,
        COUNT(DISTINCT o.customer_id) AS active_customers,
        SUM(o.total_amount) AS monthly_revenue
    FROM orders o
    WHERE o.status = 'Completed'
    GROUP BY strftime('%Y-%m', o.order_date)
)
SELECT
    month,
    active_customers,
    ROUND(monthly_revenue, 2) AS revenue,
    ROUND(monthly_revenue / active_customers, 2) AS revenue_per_customer,
    ROUND(SUM(monthly_revenue) OVER (ORDER BY month), 2) AS cumulative_revenue
FROM monthly_ltv
ORDER BY month DESC
LIMIT 12;
