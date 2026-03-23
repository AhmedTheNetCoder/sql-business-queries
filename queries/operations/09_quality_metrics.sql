-- =============================================
-- Query: Quality Metrics Dashboard
-- Category: Operations Analytics
-- Difficulty: Intermediate
--
-- Business Question:
-- What are our key quality indicators?
-- Where should we focus improvement efforts?
--
-- Use Case:
-- Quality assurance, process improvement,
-- and operational excellence tracking.
-- =============================================

-- Order quality metrics
SELECT
    strftime('%Y-%m', order_date) AS month,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) AS successful_orders,
    ROUND(SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS success_rate,
    SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled,
    ROUND(SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS cancellation_rate
FROM orders
GROUP BY strftime('%Y-%m', order_date)
ORDER BY month DESC
LIMIT 12;

-- =============================================
-- Expected Output:
-- | month   | total_orders | success_rate | cancellation_rate |
-- |---------|--------------|--------------|-------------------|
-- | 2024-02 | 48           | 87.50        | 6.25              |
-- | 2024-01 | 55           | 92.73        | 3.64              |
-- =============================================

-- Product quality score (based on sales and returns)
SELECT
    p.product_id,
    p.product_name,
    p.category,
    s.supplier_name,
    s.rating AS supplier_rating,
    COUNT(DISTINCT CASE WHEN o.status = 'Completed' THEN o.order_id END) AS successful_orders,
    COUNT(DISTINCT CASE WHEN o.status = 'Cancelled' THEN o.order_id END) AS cancelled_orders,
    ROUND(
        COUNT(DISTINCT CASE WHEN o.status = 'Completed' THEN o.order_id END) * 100.0 /
        NULLIF(COUNT(DISTINCT o.order_id), 0), 2
    ) AS quality_score
FROM products p
INNER JOIN suppliers s ON p.supplier_id = s.supplier_id
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE p.is_active = 1
GROUP BY p.product_id, p.product_name, p.category, s.supplier_name, s.rating
HAVING COUNT(DISTINCT o.order_id) >= 5
ORDER BY quality_score ASC;

-- Supplier quality ranking
SELECT
    s.supplier_id,
    s.supplier_name,
    s.rating,
    COUNT(DISTINCT p.product_id) AS products,
    COUNT(DISTINCT CASE WHEN o.status = 'Completed' THEN o.order_id END) AS successful_orders,
    COUNT(DISTINCT CASE WHEN o.status = 'Cancelled' THEN o.order_id END) AS issues,
    ROUND(
        COUNT(DISTINCT CASE WHEN o.status = 'Completed' THEN o.order_id END) * 100.0 /
        NULLIF(COUNT(DISTINCT o.order_id), 0), 2
    ) AS fulfillment_quality,
    CASE
        WHEN s.rating >= 4.5 AND COUNT(DISTINCT CASE WHEN o.status = 'Cancelled' THEN o.order_id END) = 0 THEN 'Excellent'
        WHEN s.rating >= 4.0 THEN 'Good'
        WHEN s.rating >= 3.5 THEN 'Acceptable'
        ELSE 'Needs Improvement'
    END AS quality_tier
FROM suppliers s
INNER JOIN products p ON s.supplier_id = p.supplier_id
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id
GROUP BY s.supplier_id, s.supplier_name, s.rating
ORDER BY s.rating DESC, fulfillment_quality DESC;

-- Category quality comparison
SELECT
    p.category,
    COUNT(DISTINCT p.product_id) AS products,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(
        COUNT(DISTINCT CASE WHEN o.status = 'Completed' THEN o.order_id END) * 100.0 /
        NULLIF(COUNT(DISTINCT o.order_id), 0), 2
    ) AS success_rate,
    ROUND(AVG(s.rating), 2) AS avg_supplier_rating,
    ROUND(AVG((p.unit_price - p.unit_cost) / p.unit_price * 100), 2) AS avg_margin
FROM products p
INNER JOIN suppliers s ON p.supplier_id = s.supplier_id
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE p.is_active = 1
GROUP BY p.category
ORDER BY success_rate DESC;

-- Inventory quality (stock accuracy proxy)
SELECT
    p.category,
    COUNT(*) AS total_products,
    SUM(CASE WHEN p.stock_quantity = 0 THEN 1 ELSE 0 END) AS out_of_stock,
    SUM(CASE WHEN p.stock_quantity <= p.reorder_level AND p.stock_quantity > 0 THEN 1 ELSE 0 END) AS low_stock,
    SUM(CASE WHEN p.stock_quantity > p.reorder_level * 3 THEN 1 ELSE 0 END) AS overstocked,
    ROUND(SUM(CASE WHEN p.stock_quantity > p.reorder_level AND p.stock_quantity <= p.reorder_level * 3 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS optimal_stock_pct
FROM products p
WHERE p.is_active = 1
GROUP BY p.category
ORDER BY optimal_stock_pct DESC;

-- Employee performance quality
SELECT
    e.department,
    COUNT(DISTINCT e.employee_id) AS employees,
    COUNT(o.order_id) AS total_orders,
    SUM(CASE WHEN o.status = 'Completed' THEN 1 ELSE 0 END) AS completed,
    ROUND(SUM(CASE WHEN o.status = 'Completed' THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(o.order_id), 0), 2) AS success_rate,
    ROUND(SUM(o.total_amount) / NULLIF(COUNT(DISTINCT e.employee_id), 0), 2) AS revenue_per_employee
FROM employees e
LEFT JOIN orders o ON e.employee_id = o.employee_id
WHERE e.status = 'Active'
    AND e.department = 'Sales'
GROUP BY e.department;

-- Quality KPI summary
SELECT 'Order Success Rate' AS kpi,
    ROUND(SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS value,
    '%' AS unit,
    CASE WHEN SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) >= 90 THEN 'Good' ELSE 'Needs Attention' END AS status
FROM orders

UNION ALL

SELECT 'Avg Supplier Rating' AS kpi,
    ROUND(AVG(rating), 2) AS value,
    'rating' AS unit,
    CASE WHEN AVG(rating) >= 4.0 THEN 'Good' ELSE 'Needs Attention' END AS status
FROM suppliers
WHERE is_active = 1

UNION ALL

SELECT 'In-Stock Rate' AS kpi,
    ROUND(SUM(CASE WHEN stock_quantity > 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS value,
    '%' AS unit,
    CASE WHEN SUM(CASE WHEN stock_quantity > 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) >= 95 THEN 'Good' ELSE 'Needs Attention' END AS status
FROM products
WHERE is_active = 1;
