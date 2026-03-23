-- =============================================
-- Query: Inventory Status Report
-- Category: Operations Analytics
-- Difficulty: Beginner
--
-- Business Question:
-- What is the current inventory status across all products?
-- Which items need attention?
--
-- Use Case:
-- Stock management, purchasing decisions,
-- and warehouse operations planning.
-- =============================================

-- Current inventory snapshot
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.sku,
    p.stock_quantity,
    p.reorder_level,
    p.unit_cost,
    ROUND(p.stock_quantity * p.unit_cost, 2) AS inventory_value,
    CASE
        WHEN p.stock_quantity = 0 THEN 'Out of Stock'
        WHEN p.stock_quantity <= p.reorder_level THEN 'Low Stock'
        WHEN p.stock_quantity <= p.reorder_level * 2 THEN 'Adequate'
        ELSE 'Well Stocked'
    END AS stock_status
FROM products p
WHERE p.is_active = 1
ORDER BY
    CASE
        WHEN p.stock_quantity = 0 THEN 1
        WHEN p.stock_quantity <= p.reorder_level THEN 2
        ELSE 3
    END,
    p.stock_quantity ASC;

-- =============================================
-- Expected Output:
-- | product_name    | stock_quantity | reorder_level | stock_status |
-- |-----------------|----------------|---------------|--------------|
-- | Wireless Mouse  | 5              | 20            | Low Stock    |
-- | Office Chair    | 45             | 15            | Well Stocked |
-- =============================================

-- Inventory summary by category
SELECT
    category,
    COUNT(*) AS product_count,
    SUM(stock_quantity) AS total_units,
    ROUND(SUM(stock_quantity * unit_cost), 2) AS total_value,
    SUM(CASE WHEN stock_quantity = 0 THEN 1 ELSE 0 END) AS out_of_stock,
    SUM(CASE WHEN stock_quantity <= reorder_level AND stock_quantity > 0 THEN 1 ELSE 0 END) AS low_stock,
    ROUND(AVG(stock_quantity), 1) AS avg_stock_level
FROM products
WHERE is_active = 1
GROUP BY category
ORDER BY total_value DESC;

-- Items requiring immediate attention
SELECT
    p.product_id,
    p.product_name,
    p.sku,
    p.stock_quantity,
    p.reorder_level,
    s.supplier_name,
    s.email AS supplier_email,
    s.payment_terms,
    CASE
        WHEN p.stock_quantity = 0 THEN 'URGENT: Out of Stock'
        ELSE 'Reorder Required'
    END AS action_required
FROM products p
INNER JOIN suppliers s ON p.supplier_id = s.supplier_id
WHERE p.is_active = 1
    AND p.stock_quantity <= p.reorder_level
ORDER BY p.stock_quantity ASC;

-- Inventory valuation summary
SELECT
    'Total Inventory Value' AS metric,
    ROUND(SUM(stock_quantity * unit_cost), 2) AS value
FROM products WHERE is_active = 1

UNION ALL

SELECT
    'Total Retail Value' AS metric,
    ROUND(SUM(stock_quantity * unit_price), 2) AS value
FROM products WHERE is_active = 1

UNION ALL

SELECT
    'Potential Gross Profit' AS metric,
    ROUND(SUM(stock_quantity * (unit_price - unit_cost)), 2) AS value
FROM products WHERE is_active = 1

UNION ALL

SELECT
    'Total SKUs' AS metric,
    COUNT(*) AS value
FROM products WHERE is_active = 1

UNION ALL

SELECT
    'Total Units' AS metric,
    SUM(stock_quantity) AS value
FROM products WHERE is_active = 1;

-- Stock by supplier
SELECT
    s.supplier_id,
    s.supplier_name,
    COUNT(DISTINCT p.product_id) AS products,
    SUM(p.stock_quantity) AS total_units,
    ROUND(SUM(p.stock_quantity * p.unit_cost), 2) AS inventory_value,
    SUM(CASE WHEN p.stock_quantity <= p.reorder_level THEN 1 ELSE 0 END) AS items_need_reorder
FROM suppliers s
INNER JOIN products p ON s.supplier_id = p.supplier_id
WHERE p.is_active = 1
GROUP BY s.supplier_id, s.supplier_name
ORDER BY inventory_value DESC;

-- Stock age analysis (based on last transaction)
SELECT
    p.product_id,
    p.product_name,
    p.stock_quantity,
    MAX(it.transaction_date) AS last_movement,
    JULIANDAY('now') - JULIANDAY(MAX(it.transaction_date)) AS days_since_movement,
    CASE
        WHEN JULIANDAY('now') - JULIANDAY(MAX(it.transaction_date)) > 90 THEN 'Slow Moving'
        WHEN JULIANDAY('now') - JULIANDAY(MAX(it.transaction_date)) > 60 THEN 'Moderate'
        ELSE 'Active'
    END AS movement_status
FROM products p
LEFT JOIN inventory_transactions it ON p.product_id = it.product_id
WHERE p.is_active = 1
GROUP BY p.product_id, p.product_name, p.stock_quantity
HAVING p.stock_quantity > 0
ORDER BY days_since_movement DESC;
