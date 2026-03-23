-- =============================================
-- Query: Pareto Analysis (80/20 Rule)
-- Category: Advanced Analytics
-- Difficulty: Advanced
--
-- Business Question:
-- Which 20% of customers/products drive 80% of results?
-- Where should we focus our efforts?
--
-- Use Case:
-- Resource prioritization, focus strategies,
-- inventory optimization, and customer prioritization.
-- =============================================

-- Customer Pareto analysis
WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.company_name,
        c.customer_type,
        SUM(o.total_amount) AS total_revenue,
        COUNT(o.order_id) AS order_count
    FROM customers c
    INNER JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.status = 'Completed'
    GROUP BY c.customer_id, c.company_name, c.customer_type
),
ranked_customers AS (
    SELECT
        *,
        SUM(total_revenue) OVER (ORDER BY total_revenue DESC) AS cumulative_revenue,
        SUM(total_revenue) OVER () AS grand_total,
        ROW_NUMBER() OVER (ORDER BY total_revenue DESC) AS rank_num,
        COUNT(*) OVER () AS total_customers
    FROM customer_revenue
)
SELECT
    customer_id,
    company_name,
    customer_type,
    ROUND(total_revenue, 2) AS revenue,
    order_count,
    rank_num,
    ROUND(cumulative_revenue * 100.0 / grand_total, 2) AS cumulative_pct,
    CASE
        WHEN cumulative_revenue <= grand_total * 0.8 THEN 'Top 80%'
        ELSE 'Bottom 20%'
    END AS pareto_group,
    ROUND(rank_num * 100.0 / total_customers, 2) AS customer_percentile
FROM ranked_customers
ORDER BY total_revenue DESC;

-- =============================================
-- Expected Output:
-- | company_name      | revenue    | rank_num | cumulative_pct | pareto_group |
-- |-------------------|------------|----------|----------------|--------------|
-- | PDO               | 125,430.00 | 1        | 25.50          | Top 80%      |
-- | Oman National Bank| 98,750.00  | 2        | 45.60          | Top 80%      |
-- =============================================

-- Product Pareto analysis
WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        COALESCE(SUM(oi.line_total), 0) AS total_revenue,
        COALESCE(SUM(oi.quantity), 0) AS units_sold
    FROM products p
    LEFT JOIN order_items oi ON p.product_id = oi.product_id
    LEFT JOIN orders o ON oi.order_id = o.order_id AND o.status = 'Completed'
    WHERE p.is_active = 1
    GROUP BY p.product_id, p.product_name, p.category
),
ranked_products AS (
    SELECT
        *,
        SUM(total_revenue) OVER (ORDER BY total_revenue DESC) AS cumulative_revenue,
        SUM(total_revenue) OVER () AS grand_total,
        ROW_NUMBER() OVER (ORDER BY total_revenue DESC) AS rank_num,
        COUNT(*) OVER () AS total_products
    FROM product_revenue
    WHERE total_revenue > 0
)
SELECT
    product_name,
    category,
    ROUND(total_revenue, 2) AS revenue,
    units_sold,
    rank_num,
    ROUND(cumulative_revenue * 100.0 / grand_total, 2) AS cumulative_pct,
    CASE
        WHEN cumulative_revenue <= grand_total * 0.8 THEN 'A-Class (Top 80%)'
        WHEN cumulative_revenue <= grand_total * 0.95 THEN 'B-Class (Next 15%)'
        ELSE 'C-Class (Bottom 5%)'
    END AS abc_class
FROM ranked_products
ORDER BY total_revenue DESC;

-- Pareto summary statistics
WITH customer_pareto AS (
    SELECT
        customer_id,
        SUM(total_amount) AS revenue,
        SUM(SUM(total_amount)) OVER (ORDER BY SUM(total_amount) DESC) AS cumulative,
        SUM(SUM(total_amount)) OVER () AS total
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id
)
SELECT
    'Customers' AS entity_type,
    COUNT(CASE WHEN cumulative <= total * 0.8 THEN 1 END) AS top_performers,
    COUNT(*) AS total_count,
    ROUND(COUNT(CASE WHEN cumulative <= total * 0.8 THEN 1 END) * 100.0 / COUNT(*), 2) AS top_pct,
    ROUND(MAX(total) * 0.8, 2) AS revenue_from_top,
    ROUND(MAX(total), 2) AS total_revenue
FROM customer_pareto

UNION ALL

SELECT
    'Products' AS entity_type,
    COUNT(CASE WHEN cumulative <= total * 0.8 THEN 1 END) AS top_performers,
    COUNT(*) AS total_count,
    ROUND(COUNT(CASE WHEN cumulative <= total * 0.8 THEN 1 END) * 100.0 / COUNT(*), 2) AS top_pct,
    ROUND(MAX(total) * 0.8, 2) AS revenue_from_top,
    ROUND(MAX(total), 2) AS total_revenue
FROM (
    SELECT
        oi.product_id,
        SUM(oi.line_total) AS revenue,
        SUM(SUM(oi.line_total)) OVER (ORDER BY SUM(oi.line_total) DESC) AS cumulative,
        SUM(SUM(oi.line_total)) OVER () AS total
    FROM order_items oi
    INNER JOIN orders o ON oi.order_id = o.order_id
    WHERE o.status = 'Completed'
    GROUP BY oi.product_id
);

-- Category Pareto analysis
WITH category_revenue AS (
    SELECT
        p.category,
        SUM(oi.line_total) AS total_revenue,
        SUM(oi.quantity) AS units_sold,
        COUNT(DISTINCT p.product_id) AS product_count
    FROM products p
    INNER JOIN order_items oi ON p.product_id = oi.product_id
    INNER JOIN orders o ON oi.order_id = o.order_id
    WHERE o.status = 'Completed'
    GROUP BY p.category
),
ranked_categories AS (
    SELECT
        *,
        SUM(total_revenue) OVER (ORDER BY total_revenue DESC) AS cumulative_revenue,
        SUM(total_revenue) OVER () AS grand_total
    FROM category_revenue
)
SELECT
    category,
    ROUND(total_revenue, 2) AS revenue,
    units_sold,
    product_count,
    ROUND(total_revenue * 100.0 / grand_total, 2) AS pct_of_revenue,
    ROUND(cumulative_revenue * 100.0 / grand_total, 2) AS cumulative_pct
FROM ranked_categories
ORDER BY total_revenue DESC;

-- Region Pareto analysis
WITH region_revenue AS (
    SELECT
        r.region_name,
        COUNT(DISTINCT c.customer_id) AS customer_count,
        COUNT(o.order_id) AS order_count,
        SUM(o.total_amount) AS total_revenue
    FROM regions r
    INNER JOIN customers c ON r.region_id = c.region_id
    INNER JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.status = 'Completed'
    GROUP BY r.region_name
),
ranked_regions AS (
    SELECT
        *,
        SUM(total_revenue) OVER (ORDER BY total_revenue DESC) AS cumulative_revenue,
        SUM(total_revenue) OVER () AS grand_total
    FROM region_revenue
)
SELECT
    region_name,
    customer_count,
    order_count,
    ROUND(total_revenue, 2) AS revenue,
    ROUND(total_revenue * 100.0 / grand_total, 2) AS pct_of_revenue,
    ROUND(cumulative_revenue * 100.0 / grand_total, 2) AS cumulative_pct,
    CASE
        WHEN cumulative_revenue <= grand_total * 0.8 THEN 'Focus Region'
        ELSE 'Secondary Region'
    END AS priority
FROM ranked_regions
ORDER BY total_revenue DESC;

-- Actionable Pareto insights
WITH top_customers AS (
    SELECT customer_id
    FROM (
        SELECT
            customer_id,
            SUM(SUM(total_amount)) OVER (ORDER BY SUM(total_amount) DESC) AS cumulative,
            SUM(SUM(total_amount)) OVER () AS total
        FROM orders
        WHERE status = 'Completed'
        GROUP BY customer_id
    )
    WHERE cumulative <= total * 0.8
)
SELECT
    'VIP Customer Program' AS recommendation,
    COUNT(*) AS target_customers,
    ROUND(SUM(o.total_amount), 2) AS revenue_at_stake,
    'Implement loyalty rewards for top customers' AS action
FROM orders o
WHERE o.customer_id IN (SELECT customer_id FROM top_customers)
    AND o.status = 'Completed';
