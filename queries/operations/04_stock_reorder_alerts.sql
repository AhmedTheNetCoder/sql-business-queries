-- =============================================
-- Query: Stock Reorder Alerts
-- Category: Operations Analytics
-- Difficulty: Beginner
--
-- Business Question:
-- Which products need to be reordered?
-- What quantities should we order?
--
-- Use Case:
-- Inventory replenishment, purchase order generation,
-- and stockout prevention.
-- =============================================

-- Products requiring reorder
SELECT
    p.product_id,
    p.sku,
    p.product_name,
    p.category,
    p.stock_quantity AS current_stock,
    p.reorder_level,
    p.stock_quantity - p.reorder_level AS below_threshold,
    s.supplier_name,
    s.contact_name,
    s.email AS supplier_email,
    s.payment_terms,
    CASE
        WHEN p.stock_quantity = 0 THEN 'CRITICAL'
        WHEN p.stock_quantity < p.reorder_level * 0.5 THEN 'URGENT'
        ELSE 'REORDER'
    END AS alert_level
FROM products p
INNER JOIN suppliers s ON p.supplier_id = s.supplier_id
WHERE p.is_active = 1
    AND p.stock_quantity <= p.reorder_level
ORDER BY
    CASE
        WHEN p.stock_quantity = 0 THEN 1
        WHEN p.stock_quantity < p.reorder_level * 0.5 THEN 2
        ELSE 3
    END,
    p.stock_quantity ASC;

-- =============================================
-- Expected Output:
-- | sku        | product_name    | current_stock | reorder_level | alert_level |
-- |------------|-----------------|---------------|---------------|-------------|
-- | SKU-001    | Wireless Mouse  | 0             | 20            | CRITICAL    |
-- | SKU-015    | USB-C Hub       | 8             | 25            | URGENT      |
-- =============================================

-- Suggested order quantities (based on sales velocity)
WITH sales_velocity AS (
    SELECT
        p.product_id,
        COALESCE(SUM(oi.quantity), 0) AS units_sold,
        COALESCE(SUM(oi.quantity) /
            NULLIF(COUNT(DISTINCT strftime('%Y-%m', o.order_date)), 0), 0) AS monthly_velocity
    FROM products p
    LEFT JOIN order_items oi ON p.product_id = oi.product_id
    LEFT JOIN orders o ON oi.order_id = o.order_id AND o.status = 'Completed'
    GROUP BY p.product_id
)
SELECT
    p.product_id,
    p.product_name,
    p.stock_quantity AS current_stock,
    p.reorder_level,
    ROUND(sv.monthly_velocity, 1) AS monthly_sales,
    -- Suggest ordering 2 months of stock above reorder level
    CASE
        WHEN sv.monthly_velocity > 0
        THEN MAX(ROUND(sv.monthly_velocity * 2 - p.stock_quantity + p.reorder_level, 0), p.reorder_level)
        ELSE p.reorder_level * 2
    END AS suggested_order_qty,
    ROUND(p.unit_cost *
        CASE
            WHEN sv.monthly_velocity > 0
            THEN MAX(ROUND(sv.monthly_velocity * 2 - p.stock_quantity + p.reorder_level, 0), p.reorder_level)
            ELSE p.reorder_level * 2
        END, 2) AS estimated_cost
FROM products p
INNER JOIN sales_velocity sv ON p.product_id = sv.product_id
WHERE p.is_active = 1
    AND p.stock_quantity <= p.reorder_level
ORDER BY p.stock_quantity ASC;

-- Reorder summary by supplier
SELECT
    s.supplier_id,
    s.supplier_name,
    s.contact_name,
    s.email,
    COUNT(*) AS items_to_reorder,
    SUM(CASE WHEN p.stock_quantity = 0 THEN 1 ELSE 0 END) AS critical_items,
    ROUND(SUM(p.reorder_level * p.unit_cost), 2) AS min_order_value,
    s.payment_terms || ' days' AS payment_terms
FROM suppliers s
INNER JOIN products p ON s.supplier_id = p.supplier_id
WHERE p.is_active = 1
    AND p.stock_quantity <= p.reorder_level
GROUP BY s.supplier_id, s.supplier_name, s.contact_name, s.email, s.payment_terms
ORDER BY critical_items DESC, items_to_reorder DESC;

-- Out of stock report
SELECT
    p.product_id,
    p.sku,
    p.product_name,
    p.category,
    s.supplier_name,
    MAX(o.order_date) AS last_order_date,
    COALESCE(SUM(oi.quantity), 0) AS total_units_sold,
    ROUND(COALESCE(SUM(oi.line_total), 0), 2) AS total_revenue_lost_potential
FROM products p
INNER JOIN suppliers s ON p.supplier_id = s.supplier_id
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id AND o.status = 'Completed'
WHERE p.is_active = 1
    AND p.stock_quantity = 0
GROUP BY p.product_id, p.sku, p.product_name, p.category, s.supplier_name
ORDER BY total_units_sold DESC;

-- Category reorder summary
SELECT
    p.category,
    COUNT(*) AS products_need_reorder,
    SUM(CASE WHEN p.stock_quantity = 0 THEN 1 ELSE 0 END) AS out_of_stock,
    SUM(p.reorder_level - p.stock_quantity) AS total_units_needed,
    ROUND(SUM((p.reorder_level - p.stock_quantity) * p.unit_cost), 2) AS estimated_reorder_cost
FROM products p
WHERE p.is_active = 1
    AND p.stock_quantity <= p.reorder_level
GROUP BY p.category
ORDER BY out_of_stock DESC, products_need_reorder DESC;

-- Weekly stock alerts trend
SELECT
    strftime('%Y-W%W', 'now') AS current_week,
    COUNT(*) AS total_alerts,
    SUM(CASE WHEN stock_quantity = 0 THEN 1 ELSE 0 END) AS critical_alerts,
    SUM(CASE WHEN stock_quantity > 0 AND stock_quantity <= reorder_level THEN 1 ELSE 0 END) AS reorder_alerts,
    ROUND(AVG(reorder_level - stock_quantity), 1) AS avg_units_below_threshold
FROM products
WHERE is_active = 1
    AND stock_quantity <= reorder_level;
