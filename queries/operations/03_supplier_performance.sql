-- =============================================
-- Query: Supplier Performance Analysis
-- Category: Operations Analytics
-- Difficulty: Intermediate
--
-- Business Question:
-- How well are our suppliers performing?
-- Which suppliers should we prioritize?
--
-- Use Case:
-- Vendor management, procurement optimization,
-- and supply chain reliability.
-- =============================================

-- Supplier performance scorecard
SELECT
    s.supplier_id,
    s.supplier_name,
    s.rating,
    s.payment_terms,
    COUNT(DISTINCT p.product_id) AS products_supplied,
    SUM(p.stock_quantity) AS total_stock,
    ROUND(AVG((p.unit_price - p.unit_cost) / p.unit_price * 100), 2) AS avg_margin_pct,
    CASE
        WHEN s.rating >= 4.5 THEN 'Preferred'
        WHEN s.rating >= 4.0 THEN 'Approved'
        WHEN s.rating >= 3.5 THEN 'Conditional'
        ELSE 'Under Review'
    END AS supplier_status
FROM suppliers s
INNER JOIN products p ON s.supplier_id = p.supplier_id
WHERE s.is_active = 1
GROUP BY s.supplier_id, s.supplier_name, s.rating, s.payment_terms
ORDER BY s.rating DESC;

-- =============================================
-- Expected Output:
-- | supplier_name        | rating | products_supplied | avg_margin_pct | supplier_status |
-- |----------------------|--------|-------------------|----------------|-----------------|
-- | Gulf Electronics LLC | 4.8    | 12                | 35.50          | Preferred       |
-- | Quality Furniture    | 4.2    | 8                 | 42.30          | Approved        |
-- =============================================

-- Supplier revenue contribution
SELECT
    s.supplier_id,
    s.supplier_name,
    ROUND(SUM(oi.line_total), 2) AS total_revenue,
    ROUND(SUM(oi.quantity * p.unit_cost), 2) AS total_cost,
    ROUND(SUM(oi.line_total) - SUM(oi.quantity * p.unit_cost), 2) AS gross_profit,
    ROUND(SUM(oi.line_total) * 100.0 /
          (SELECT SUM(line_total) FROM order_items oi2
           INNER JOIN orders o2 ON oi2.order_id = o2.order_id
           WHERE o2.status = 'Completed'), 2) AS revenue_share_pct
FROM suppliers s
INNER JOIN products p ON s.supplier_id = p.supplier_id
INNER JOIN order_items oi ON p.product_id = oi.product_id
INNER JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY s.supplier_id, s.supplier_name
ORDER BY total_revenue DESC;

-- Supplier product quality (based on margin and sales volume)
SELECT
    s.supplier_name,
    p.product_name,
    p.category,
    ROUND((p.unit_price - p.unit_cost) / p.unit_price * 100, 2) AS margin_pct,
    COALESCE(SUM(oi.quantity), 0) AS units_sold,
    ROUND(COALESCE(SUM(oi.line_total), 0), 2) AS revenue,
    CASE
        WHEN (p.unit_price - p.unit_cost) / p.unit_price >= 0.35 AND COALESCE(SUM(oi.quantity), 0) > 20 THEN 'Star Product'
        WHEN (p.unit_price - p.unit_cost) / p.unit_price >= 0.25 THEN 'Good Performer'
        WHEN COALESCE(SUM(oi.quantity), 0) > 50 THEN 'Volume Driver'
        ELSE 'Standard'
    END AS product_classification
FROM suppliers s
INNER JOIN products p ON s.supplier_id = p.supplier_id
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id AND o.status = 'Completed'
WHERE p.is_active = 1
GROUP BY s.supplier_name, p.product_name, p.category, p.unit_price, p.unit_cost
ORDER BY s.supplier_name, revenue DESC;

-- Supplier risk assessment
WITH supplier_metrics AS (
    SELECT
        s.supplier_id,
        s.supplier_name,
        s.rating,
        COUNT(DISTINCT p.product_id) AS product_count,
        SUM(CASE WHEN p.stock_quantity <= p.reorder_level THEN 1 ELSE 0 END) AS low_stock_items,
        COALESCE(SUM(oi.line_total), 0) AS revenue_contribution
    FROM suppliers s
    INNER JOIN products p ON s.supplier_id = p.supplier_id
    LEFT JOIN order_items oi ON p.product_id = oi.product_id
    LEFT JOIN orders o ON oi.order_id = o.order_id AND o.status = 'Completed'
    WHERE s.is_active = 1
    GROUP BY s.supplier_id, s.supplier_name, s.rating
)
SELECT
    supplier_name,
    rating,
    product_count,
    low_stock_items,
    ROUND(revenue_contribution, 2) AS revenue,
    CASE
        WHEN rating < 3.5 THEN 'Quality Risk'
        WHEN low_stock_items > product_count * 0.5 THEN 'Supply Risk'
        WHEN revenue_contribution > (SELECT SUM(revenue_contribution) * 0.3 FROM supplier_metrics) THEN 'Concentration Risk'
        ELSE 'Low Risk'
    END AS risk_assessment
FROM supplier_metrics
ORDER BY revenue_contribution DESC;

-- Supplier by category coverage
SELECT
    p.category,
    COUNT(DISTINCT s.supplier_id) AS supplier_count,
    GROUP_CONCAT(DISTINCT s.supplier_name) AS suppliers,
    COUNT(DISTINCT p.product_id) AS product_count,
    ROUND(AVG(s.rating), 2) AS avg_supplier_rating
FROM products p
INNER JOIN suppliers s ON p.supplier_id = s.supplier_id
WHERE p.is_active = 1
GROUP BY p.category
ORDER BY product_count DESC;

-- Supplier contact directory
SELECT
    supplier_id,
    supplier_name,
    contact_name,
    email,
    phone,
    city,
    country,
    payment_terms || ' days' AS payment_terms,
    rating,
    CASE WHEN is_active = 1 THEN 'Active' ELSE 'Inactive' END AS status
FROM suppliers
ORDER BY rating DESC, supplier_name;
