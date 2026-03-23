-- =============================================
-- Query: Vendor Payment Analysis
-- Category: Finance Analytics
-- Difficulty: Beginner
--
-- Business Question:
-- How much do we spend with each vendor? Are we
-- taking advantage of payment terms?
--
-- Use Case:
-- Vendor relationship management, payment optimization,
-- and accounts payable management.
-- =============================================

-- Vendor spending summary
SELECT
    s.supplier_id,
    s.supplier_name,
    s.payment_terms,
    s.rating,
    COUNT(DISTINCT p.product_id) AS products_supplied,
    COALESCE(SUM(oi.quantity), 0) AS total_units_purchased,
    ROUND(COALESCE(SUM(oi.quantity * p.unit_cost), 0), 2) AS total_spend,
    ROUND(COALESCE(AVG(oi.quantity * p.unit_cost), 0), 2) AS avg_order_value
FROM suppliers s
LEFT JOIN products p ON s.supplier_id = p.supplier_id
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id AND o.status = 'Completed'
GROUP BY s.supplier_id, s.supplier_name, s.payment_terms, s.rating
ORDER BY total_spend DESC;

-- =============================================
-- Expected Output:
-- | supplier_name        | payment_terms | products_supplied | total_spend  |
-- |----------------------|---------------|-------------------|--------------|
-- | Gulf Electronics LLC | 30            | 8                 | 125,430.00   |
-- | Quality Furniture    | 45            | 5                 | 85,200.00    |
-- =============================================

-- Supplier payment terms analysis
SELECT
    payment_terms,
    COUNT(*) AS supplier_count,
    ROUND(SUM(total_spend), 2) AS combined_spend,
    ROUND(AVG(total_spend), 2) AS avg_spend_per_supplier
FROM (
    SELECT
        s.supplier_id,
        s.payment_terms,
        COALESCE(SUM(oi.quantity * p.unit_cost), 0) AS total_spend
    FROM suppliers s
    LEFT JOIN products p ON s.supplier_id = p.supplier_id
    LEFT JOIN order_items oi ON p.product_id = oi.product_id
    LEFT JOIN orders o ON oi.order_id = o.order_id AND o.status = 'Completed'
    GROUP BY s.supplier_id, s.payment_terms
)
GROUP BY payment_terms
ORDER BY payment_terms;

-- Supplier performance metrics
SELECT
    s.supplier_id,
    s.supplier_name,
    s.rating,
    COUNT(DISTINCT p.product_id) AS active_products,
    ROUND(AVG((p.unit_price - p.unit_cost) / p.unit_price * 100), 2) AS avg_margin_from_supplier,
    SUM(p.stock_quantity) AS total_stock_from_supplier,
    CASE
        WHEN s.rating >= 4.5 THEN 'Excellent'
        WHEN s.rating >= 4.0 THEN 'Good'
        WHEN s.rating >= 3.5 THEN 'Average'
        ELSE 'Needs Review'
    END AS performance_tier
FROM suppliers s
INNER JOIN products p ON s.supplier_id = p.supplier_id
WHERE p.is_active = 1
GROUP BY s.supplier_id, s.supplier_name, s.rating
ORDER BY s.rating DESC;

-- Spending trend by supplier
SELECT
    s.supplier_name,
    strftime('%Y-%m', o.order_date) AS month,
    ROUND(SUM(oi.quantity * p.unit_cost), 2) AS monthly_spend
FROM suppliers s
INNER JOIN products p ON s.supplier_id = p.supplier_id
INNER JOIN order_items oi ON p.product_id = oi.product_id
INNER JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY s.supplier_name, strftime('%Y-%m', o.order_date)
ORDER BY s.supplier_name, month DESC;

-- Supplier concentration risk
WITH supplier_spend AS (
    SELECT
        s.supplier_id,
        s.supplier_name,
        COALESCE(SUM(oi.quantity * p.unit_cost), 0) AS spend
    FROM suppliers s
    LEFT JOIN products p ON s.supplier_id = p.supplier_id
    LEFT JOIN order_items oi ON p.product_id = oi.product_id
    LEFT JOIN orders o ON oi.order_id = o.order_id AND o.status = 'Completed'
    GROUP BY s.supplier_id, s.supplier_name
)
SELECT
    supplier_name,
    ROUND(spend, 2) AS total_spend,
    ROUND(spend * 100.0 / (SELECT SUM(spend) FROM supplier_spend WHERE spend > 0), 2) AS spend_percent,
    CASE
        WHEN spend * 100.0 / (SELECT SUM(spend) FROM supplier_spend WHERE spend > 0) > 30 THEN 'High Dependency'
        WHEN spend * 100.0 / (SELECT SUM(spend) FROM supplier_spend WHERE spend > 0) > 15 THEN 'Moderate'
        ELSE 'Low Risk'
    END AS concentration_risk
FROM supplier_spend
WHERE spend > 0
ORDER BY spend DESC;

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
    is_active
FROM suppliers
ORDER BY supplier_name;
