-- =============================================
-- Query: Churn Prediction Data Preparation
-- Category: Advanced Analytics
-- Difficulty: Advanced
--
-- Business Question:
-- Which customers are at risk of churning?
-- What signals indicate potential churn?
--
-- Use Case:
-- Customer retention, proactive outreach,
-- win-back campaigns, and churn reduction.
-- =============================================

-- Customer churn indicators
WITH customer_activity AS (
    SELECT
        c.customer_id,
        c.company_name,
        c.customer_type,
        MIN(o.order_date) AS first_order,
        MAX(o.order_date) AS last_order,
        COUNT(o.order_id) AS total_orders,
        SUM(o.total_amount) AS total_revenue,
        AVG(o.total_amount) AS avg_order_value,
        JULIANDAY('now') - JULIANDAY(MAX(o.order_date)) AS days_since_last_order,
        JULIANDAY(MAX(o.order_date)) - JULIANDAY(MIN(o.order_date)) AS customer_tenure_days
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id AND o.status = 'Completed'
    GROUP BY c.customer_id, c.company_name, c.customer_type
)
SELECT
    customer_id,
    company_name,
    customer_type,
    total_orders,
    ROUND(total_revenue, 2) AS lifetime_value,
    ROUND(avg_order_value, 2) AS aov,
    ROUND(days_since_last_order, 0) AS days_inactive,
    ROUND(customer_tenure_days, 0) AS tenure_days,
    CASE
        WHEN days_since_last_order IS NULL THEN 'Never Purchased'
        WHEN days_since_last_order <= 30 THEN 'Active'
        WHEN days_since_last_order <= 60 THEN 'At Risk'
        WHEN days_since_last_order <= 90 THEN 'High Risk'
        ELSE 'Churned'
    END AS churn_status,
    CASE
        WHEN days_since_last_order > 90 THEN 'Send win-back offer'
        WHEN days_since_last_order > 60 THEN 'Proactive outreach call'
        WHEN days_since_last_order > 30 THEN 'Send engagement email'
        ELSE 'Continue normal engagement'
    END AS recommended_action
FROM customer_activity
ORDER BY days_since_last_order DESC NULLS FIRST;

-- =============================================
-- Expected Output:
-- | company_name      | lifetime_value | days_inactive | churn_status |
-- |-------------------|----------------|---------------|--------------|
-- | Gulf Trading      | 15,230.00      | 125           | Churned      |
-- | Oman Cement       | 42,500.00      | 75            | High Risk    |
-- =============================================

-- Churn summary by segment
WITH customer_activity AS (
    SELECT
        c.customer_id,
        c.customer_type,
        MAX(o.order_date) AS last_order,
        JULIANDAY('now') - JULIANDAY(MAX(o.order_date)) AS days_since_last
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id AND o.status = 'Completed'
    GROUP BY c.customer_id, c.customer_type
)
SELECT
    customer_type,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN days_since_last <= 30 OR days_since_last IS NULL THEN 1 ELSE 0 END) AS active,
    SUM(CASE WHEN days_since_last > 30 AND days_since_last <= 60 THEN 1 ELSE 0 END) AS at_risk,
    SUM(CASE WHEN days_since_last > 60 AND days_since_last <= 90 THEN 1 ELSE 0 END) AS high_risk,
    SUM(CASE WHEN days_since_last > 90 THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN days_since_last > 90 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate
FROM customer_activity
GROUP BY customer_type
ORDER BY churn_rate DESC;

-- Feature engineering for churn prediction
WITH order_features AS (
    SELECT
        o.customer_id,
        COUNT(*) AS order_count,
        SUM(o.total_amount) AS total_spend,
        AVG(o.total_amount) AS avg_order_value,
        MAX(o.total_amount) AS max_order,
        MIN(o.total_amount) AS min_order,
        JULIANDAY(MAX(o.order_date)) - JULIANDAY(MIN(o.order_date)) AS active_period_days,
        COUNT(DISTINCT strftime('%Y-%m', o.order_date)) AS active_months
    FROM orders o
    WHERE o.status = 'Completed'
    GROUP BY o.customer_id
),
recency AS (
    SELECT
        customer_id,
        JULIANDAY('now') - JULIANDAY(MAX(order_date)) AS days_since_last
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    c.company_name,
    c.customer_type,
    COALESCE(of.order_count, 0) AS order_count,
    ROUND(COALESCE(of.total_spend, 0), 2) AS total_spend,
    ROUND(COALESCE(of.avg_order_value, 0), 2) AS avg_order_value,
    ROUND(COALESCE(r.days_since_last, 999), 0) AS days_since_last_order,
    COALESCE(of.active_months, 0) AS active_months,
    ROUND(COALESCE(of.order_count * 1.0 / NULLIF(of.active_months, 0), 0), 2) AS orders_per_month,
    -- Churn probability score (simplified)
    ROUND(
        CASE
            WHEN r.days_since_last IS NULL THEN 100
            WHEN r.days_since_last > 90 THEN 90
            WHEN r.days_since_last > 60 THEN 70
            WHEN r.days_since_last > 30 THEN 40
            ELSE 10
        END -
        CASE
            WHEN of.order_count >= 10 THEN 20
            WHEN of.order_count >= 5 THEN 10
            ELSE 0
        END, 0
    ) AS churn_risk_score
FROM customers c
LEFT JOIN order_features of ON c.customer_id = of.customer_id
LEFT JOIN recency r ON c.customer_id = r.customer_id
ORDER BY churn_risk_score DESC;

-- Order frequency decline detection
WITH monthly_orders AS (
    SELECT
        customer_id,
        strftime('%Y-%m', order_date) AS month,
        COUNT(*) AS orders,
        SUM(total_amount) AS revenue
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id, strftime('%Y-%m', order_date)
),
customer_trend AS (
    SELECT
        customer_id,
        month,
        orders,
        revenue,
        LAG(orders) OVER (PARTITION BY customer_id ORDER BY month) AS prev_orders,
        LAG(revenue) OVER (PARTITION BY customer_id ORDER BY month) AS prev_revenue
    FROM monthly_orders
)
SELECT
    ct.customer_id,
    c.company_name,
    ct.month,
    ct.orders AS current_orders,
    ct.prev_orders,
    ct.orders - COALESCE(ct.prev_orders, ct.orders) AS order_change,
    CASE
        WHEN ct.orders < COALESCE(ct.prev_orders, ct.orders) THEN 'Declining'
        WHEN ct.orders > COALESCE(ct.prev_orders, ct.orders) THEN 'Growing'
        ELSE 'Stable'
    END AS trend
FROM customer_trend ct
INNER JOIN customers c ON ct.customer_id = c.customer_id
WHERE ct.prev_orders IS NOT NULL
ORDER BY ct.customer_id, ct.month DESC;

-- High-value customers at churn risk
WITH customer_metrics AS (
    SELECT
        c.customer_id,
        c.company_name,
        c.customer_type,
        c.email,
        SUM(o.total_amount) AS lifetime_value,
        JULIANDAY('now') - JULIANDAY(MAX(o.order_date)) AS days_inactive
    FROM customers c
    INNER JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.status = 'Completed'
    GROUP BY c.customer_id, c.company_name, c.customer_type, c.email
)
SELECT
    customer_id,
    company_name,
    customer_type,
    email,
    ROUND(lifetime_value, 2) AS ltv,
    ROUND(days_inactive, 0) AS days_since_last_order,
    'Urgent: High-value customer at risk' AS alert,
    CASE
        WHEN days_inactive > 60 THEN 'Executive outreach required'
        ELSE 'Priority re-engagement campaign'
    END AS action
FROM customer_metrics
WHERE lifetime_value > 10000
    AND days_inactive > 30
ORDER BY lifetime_value DESC;

-- Monthly churn trend
WITH monthly_active AS (
    SELECT
        strftime('%Y-%m', order_date) AS month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM orders
    WHERE status = 'Completed'
    GROUP BY strftime('%Y-%m', order_date)
)
SELECT
    ma1.month,
    ma1.active_customers,
    LAG(ma1.active_customers) OVER (ORDER BY ma1.month) AS prev_month_active,
    ma1.active_customers - LAG(ma1.active_customers) OVER (ORDER BY ma1.month) AS customer_change
FROM monthly_active ma1
ORDER BY ma1.month DESC
LIMIT 12;
