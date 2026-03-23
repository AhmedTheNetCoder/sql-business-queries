-- =============================================
-- Query: RFM Customer Segmentation
-- Category: Advanced Analytics
-- Difficulty: Advanced
--
-- Business Question:
-- How can we segment customers based on their
-- Recency, Frequency, and Monetary value?
--
-- Use Case:
-- Customer segmentation, targeted marketing,
-- personalization, and customer prioritization.
-- =============================================

-- RFM score calculation
WITH customer_rfm AS (
    SELECT
        customer_id,
        JULIANDAY('now') - JULIANDAY(MAX(order_date)) AS recency_days,
        COUNT(*) AS frequency,
        SUM(total_amount) AS monetary
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT
        customer_id,
        recency_days,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
    FROM customer_rfm
)
SELECT
    customer_id,
    ROUND(recency_days, 0) AS days_since_last_order,
    frequency AS order_count,
    ROUND(monetary, 2) AS total_spend,
    r_score,
    f_score,
    m_score,
    r_score || f_score || m_score AS rfm_segment,
    (r_score + f_score + m_score) AS rfm_total_score
FROM rfm_scores
ORDER BY rfm_total_score DESC, monetary DESC;

-- =============================================
-- Expected Output:
-- | customer_id | days_since_last_order | order_count | total_spend | rfm_segment |
-- |-------------|----------------------|-------------|-------------|-------------|
-- | 105         | 15                   | 12          | 45,230.00   | 555         |
-- | 112         | 45                   | 8           | 28,150.00   | 454         |
-- =============================================

-- Customer segments with labels
WITH customer_rfm AS (
    SELECT
        customer_id,
        JULIANDAY('now') - JULIANDAY(MAX(order_date)) AS recency_days,
        COUNT(*) AS frequency,
        SUM(total_amount) AS monetary
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT
        customer_id,
        recency_days,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
    FROM customer_rfm
)
SELECT
    rs.*,
    CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 4 THEN 'Loyal Customers'
        WHEN r_score >= 4 AND f_score <= 2 AND m_score <= 2 THEN 'New Customers'
        WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Potential Loyalists'
        WHEN r_score <= 2 AND f_score >= 4 AND m_score >= 4 THEN 'At Risk'
        WHEN r_score <= 2 AND f_score >= 3 AND m_score >= 3 THEN 'Need Attention'
        WHEN r_score <= 2 AND f_score <= 2 AND m_score >= 3 THEN 'Hibernating'
        WHEN r_score <= 2 AND f_score <= 2 AND m_score <= 2 THEN 'Lost'
        ELSE 'Others'
    END AS customer_segment
FROM rfm_scores rs
ORDER BY r_score DESC, f_score DESC, m_score DESC;

-- Segment summary statistics
WITH customer_rfm AS (
    SELECT
        customer_id,
        JULIANDAY('now') - JULIANDAY(MAX(order_date)) AS recency_days,
        COUNT(*) AS frequency,
        SUM(total_amount) AS monetary
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT
        customer_id,
        recency_days,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
    FROM customer_rfm
),
segmented AS (
    SELECT
        *,
        CASE
            WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 4 THEN 'Loyal Customers'
            WHEN r_score >= 4 AND f_score <= 2 AND m_score <= 2 THEN 'New Customers'
            WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Potential Loyalists'
            WHEN r_score <= 2 AND f_score >= 4 AND m_score >= 4 THEN 'At Risk'
            WHEN r_score <= 2 AND f_score >= 3 AND m_score >= 3 THEN 'Need Attention'
            WHEN r_score <= 2 AND f_score <= 2 AND m_score >= 3 THEN 'Hibernating'
            WHEN r_score <= 2 AND f_score <= 2 AND m_score <= 2 THEN 'Lost'
            ELSE 'Others'
        END AS customer_segment
    FROM rfm_scores
)
SELECT
    customer_segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(recency_days), 0) AS avg_days_since_order,
    ROUND(AVG(frequency), 1) AS avg_orders,
    ROUND(AVG(monetary), 2) AS avg_revenue,
    ROUND(SUM(monetary), 2) AS total_revenue,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM segmented), 2) AS pct_of_customers
FROM segmented
GROUP BY customer_segment
ORDER BY total_revenue DESC;

-- Customer details with RFM and recommendations
WITH customer_rfm AS (
    SELECT
        o.customer_id,
        c.company_name,
        c.customer_type,
        JULIANDAY('now') - JULIANDAY(MAX(o.order_date)) AS recency_days,
        COUNT(*) AS frequency,
        SUM(o.total_amount) AS monetary
    FROM orders o
    INNER JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.status = 'Completed'
    GROUP BY o.customer_id, c.company_name, c.customer_type
),
rfm_scores AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
    FROM customer_rfm
)
SELECT
    customer_id,
    company_name,
    customer_type,
    ROUND(recency_days, 0) AS days_inactive,
    frequency AS orders,
    ROUND(monetary, 2) AS total_revenue,
    r_score || f_score || m_score AS rfm_code,
    CASE
        WHEN r_score >= 4 AND f_score >= 4 THEN 'Offer loyalty rewards and early access'
        WHEN r_score >= 4 AND f_score <= 2 THEN 'Onboard with welcome series'
        WHEN r_score <= 2 AND f_score >= 3 THEN 'Send win-back campaign urgently'
        WHEN r_score <= 2 AND m_score >= 3 THEN 'Offer incentive to reactivate'
        ELSE 'Standard engagement'
    END AS recommended_action
FROM rfm_scores
ORDER BY monetary DESC;

-- RFM distribution analysis
WITH customer_rfm AS (
    SELECT
        customer_id,
        JULIANDAY('now') - JULIANDAY(MAX(order_date)) AS recency_days,
        COUNT(*) AS frequency,
        SUM(total_amount) AS monetary
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id
)
SELECT
    'Recency (days)' AS metric,
    ROUND(MIN(recency_days), 0) AS min_val,
    ROUND(AVG(recency_days), 0) AS avg_val,
    ROUND(MAX(recency_days), 0) AS max_val
FROM customer_rfm

UNION ALL

SELECT
    'Frequency (orders)' AS metric,
    MIN(frequency) AS min_val,
    ROUND(AVG(frequency), 1) AS avg_val,
    MAX(frequency) AS max_val
FROM customer_rfm

UNION ALL

SELECT
    'Monetary (OMR)' AS metric,
    ROUND(MIN(monetary), 2) AS min_val,
    ROUND(AVG(monetary), 2) AS avg_val,
    ROUND(MAX(monetary), 2) AS max_val
FROM customer_rfm;
