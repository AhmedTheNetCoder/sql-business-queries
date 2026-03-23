-- =============================================
-- Query: Product Returns Analysis
-- Category: Operations Analytics
-- Difficulty: Intermediate
--
-- Business Question:
-- What are the patterns in product returns?
-- Which products have high return rates?
--
-- Use Case:
-- Quality control, product improvement,
-- and customer satisfaction analysis.
-- NOTE: This query assumes a returns/refunds table
-- or uses cancelled orders as a proxy for returns.
-- =============================================

-- Cancelled orders as returns proxy
SELECT
    strftime('%Y-%m', order_date) AS month,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) AS cancellations,
    ROUND(SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS cancellation_rate,
    ROUND(SUM(CASE WHEN status = 'Cancelled' THEN total_amount ELSE 0 END), 2) AS cancelled_value
FROM orders
GROUP BY strftime('%Y-%m', order_date)
ORDER BY month DESC
LIMIT 12;

-- =============================================
-- Expected Output:
-- | month   | total_orders | cancellations | cancellation_rate | cancelled_value |
-- |---------|--------------|---------------|-------------------|-----------------|
-- | 2024-02 | 48           | 5             | 10.42             | 4,230.00        |
-- | 2024-01 | 55           | 3             | 5.45              | 2,150.00        |
-- =============================================

-- Product-level cancellation analysis
SELECT
    p.product_id,
    p.product_name,
    p.category,
    COUNT(DISTINCT o.order_id) AS total_orders_with_product,
    SUM(CASE WHEN o.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
    ROUND(SUM(CASE WHEN o.status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 /
          NULLIF(COUNT(DISTINCT o.order_id), 0), 2) AS cancellation_rate,
    SUM(oi.quantity) AS total_units_ordered,
    SUM(CASE WHEN o.status = 'Cancelled' THEN oi.quantity ELSE 0 END) AS units_in_cancelled
FROM products p
INNER JOIN order_items oi ON p.product_id = oi.product_id
INNER JOIN orders o ON oi.order_id = o.order_id
GROUP BY p.product_id, p.product_name, p.category
HAVING COUNT(DISTINCT o.order_id) >= 5
ORDER BY cancellation_rate DESC;

-- Category cancellation summary
SELECT
    p.category,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(CASE WHEN o.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancellations,
    ROUND(SUM(CASE WHEN o.status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 / COUNT(DISTINCT o.order_id), 2) AS cancellation_rate,
    ROUND(SUM(CASE WHEN o.status = 'Cancelled' THEN oi.line_total ELSE 0 END), 2) AS cancelled_value
FROM products p
INNER JOIN order_items oi ON p.product_id = oi.product_id
INNER JOIN orders o ON oi.order_id = o.order_id
GROUP BY p.category
ORDER BY cancellation_rate DESC;

-- Customer cancellation patterns
SELECT
    c.customer_id,
    c.company_name,
    c.customer_type,
    COUNT(o.order_id) AS total_orders,
    SUM(CASE WHEN o.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancellations,
    ROUND(SUM(CASE WHEN o.status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS cancellation_rate,
    ROUND(SUM(CASE WHEN o.status = 'Cancelled' THEN o.total_amount ELSE 0 END), 2) AS total_cancelled_value
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.company_name, c.customer_type
HAVING COUNT(*) >= 3 AND SUM(CASE WHEN o.status = 'Cancelled' THEN 1 ELSE 0 END) > 0
ORDER BY cancellation_rate DESC;

-- High-value cancellations
SELECT
    o.order_id,
    o.order_number,
    c.company_name AS customer,
    o.order_date,
    o.total_amount,
    COUNT(oi.order_item_id) AS item_count,
    'Investigation Required' AS status
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Cancelled'
    AND o.total_amount > 2000
GROUP BY o.order_id, o.order_number, c.company_name, o.order_date, o.total_amount
ORDER BY o.total_amount DESC
LIMIT 20;

-- Supplier quality (based on product cancellation rates)
SELECT
    s.supplier_id,
    s.supplier_name,
    s.rating,
    COUNT(DISTINCT o.order_id) AS orders_with_supplier_products,
    SUM(CASE WHEN o.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancellations,
    ROUND(SUM(CASE WHEN o.status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 /
          NULLIF(COUNT(DISTINCT o.order_id), 0), 2) AS cancellation_rate,
    CASE
        WHEN s.rating >= 4.5 AND
             SUM(CASE WHEN o.status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 /
             NULLIF(COUNT(DISTINCT o.order_id), 0) < 5 THEN 'Excellent'
        WHEN s.rating >= 4.0 THEN 'Good'
        ELSE 'Needs Attention'
    END AS quality_assessment
FROM suppliers s
INNER JOIN products p ON s.supplier_id = p.supplier_id
INNER JOIN order_items oi ON p.product_id = oi.product_id
INNER JOIN orders o ON oi.order_id = o.order_id
GROUP BY s.supplier_id, s.supplier_name, s.rating
ORDER BY cancellation_rate DESC;

-- Weekly cancellation trend
SELECT
    strftime('%Y-W%W', order_date) AS week,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) AS cancellations,
    ROUND(SUM(CASE WHEN status = 'Cancelled' THEN total_amount ELSE 0 END), 2) AS cancelled_value
FROM orders
WHERE order_date >= DATE('now', '-12 weeks')
GROUP BY strftime('%Y-W%W', order_date)
ORDER BY week DESC;
