-- =============================================
-- Query: Warehouse Efficiency Metrics
-- Category: Operations Analytics
-- Difficulty: Intermediate
--
-- Business Question:
-- How efficiently is our warehouse operating?
-- What is our inventory turnover rate?
--
-- Use Case:
-- Warehouse operations, space optimization,
-- and inventory management KPIs.
-- =============================================

-- Inventory turnover by product
WITH product_sales AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        p.stock_quantity,
        p.unit_cost,
        COALESCE(SUM(oi.quantity), 0) AS units_sold
    FROM products p
    LEFT JOIN order_items oi ON p.product_id = oi.product_id
    LEFT JOIN orders o ON oi.order_id = o.order_id
        AND o.status = 'Completed'
        AND o.order_date >= DATE('now', '-12 months')
    WHERE p.is_active = 1
    GROUP BY p.product_id, p.product_name, p.category, p.stock_quantity, p.unit_cost
)
SELECT
    product_id,
    product_name,
    category,
    stock_quantity AS current_stock,
    units_sold AS annual_sales,
    CASE
        WHEN stock_quantity > 0 THEN ROUND(units_sold * 1.0 / stock_quantity, 2)
        ELSE 0
    END AS inventory_turns,
    CASE
        WHEN units_sold > 0 THEN ROUND(stock_quantity * 365.0 / units_sold, 1)
        ELSE 999
    END AS days_of_inventory,
    CASE
        WHEN stock_quantity > 0 AND units_sold * 1.0 / stock_quantity >= 6 THEN 'High Turnover'
        WHEN stock_quantity > 0 AND units_sold * 1.0 / stock_quantity >= 3 THEN 'Normal'
        WHEN stock_quantity > 0 AND units_sold * 1.0 / stock_quantity >= 1 THEN 'Slow Moving'
        ELSE 'Dead Stock Risk'
    END AS turnover_status
FROM product_sales
ORDER BY inventory_turns DESC;

-- =============================================
-- Expected Output:
-- | product_name    | current_stock | annual_sales | inventory_turns | turnover_status |
-- |-----------------|---------------|--------------|-----------------|-----------------|
-- | Office Supplies | 50            | 400          | 8.00            | High Turnover   |
-- | Executive Desk  | 25            | 30           | 1.20            | Slow Moving     |
-- =============================================

-- Category turnover summary
SELECT
    p.category,
    SUM(p.stock_quantity) AS total_stock,
    SUM(COALESCE(sales.units_sold, 0)) AS total_sold,
    ROUND(SUM(p.stock_quantity * p.unit_cost), 2) AS inventory_value,
    CASE
        WHEN SUM(p.stock_quantity) > 0
        THEN ROUND(SUM(COALESCE(sales.units_sold, 0)) * 1.0 / SUM(p.stock_quantity), 2)
        ELSE 0
    END AS category_turns
FROM products p
LEFT JOIN (
    SELECT product_id, SUM(quantity) AS units_sold
    FROM order_items oi
    INNER JOIN orders o ON oi.order_id = o.order_id
    WHERE o.status = 'Completed'
        AND o.order_date >= DATE('now', '-12 months')
    GROUP BY product_id
) sales ON p.product_id = sales.product_id
WHERE p.is_active = 1
GROUP BY p.category
ORDER BY category_turns DESC;

-- Inventory movement analysis
SELECT
    strftime('%Y-%m', transaction_date) AS month,
    SUM(CASE WHEN transaction_type = 'IN' THEN quantity ELSE 0 END) AS units_received,
    SUM(CASE WHEN transaction_type = 'OUT' THEN quantity ELSE 0 END) AS units_shipped,
    SUM(CASE WHEN transaction_type = 'ADJUSTMENT' THEN quantity ELSE 0 END) AS adjustments,
    SUM(CASE WHEN transaction_type = 'IN' THEN quantity ELSE 0 END) -
    SUM(CASE WHEN transaction_type = 'OUT' THEN quantity ELSE 0 END) AS net_change
FROM inventory_transactions
GROUP BY strftime('%Y-%m', transaction_date)
ORDER BY month DESC
LIMIT 12;

-- Slow-moving inventory report
WITH product_movement AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        p.stock_quantity,
        p.unit_cost,
        ROUND(p.stock_quantity * p.unit_cost, 2) AS tied_up_capital,
        MAX(it.transaction_date) AS last_movement,
        COALESCE(SUM(CASE WHEN it.transaction_type = 'OUT' THEN it.quantity ELSE 0 END), 0) AS units_shipped
    FROM products p
    LEFT JOIN inventory_transactions it ON p.product_id = it.product_id
    WHERE p.is_active = 1
    GROUP BY p.product_id, p.product_name, p.category, p.stock_quantity, p.unit_cost
)
SELECT
    product_name,
    category,
    stock_quantity,
    tied_up_capital,
    last_movement,
    JULIANDAY('now') - JULIANDAY(last_movement) AS days_since_movement,
    CASE
        WHEN JULIANDAY('now') - JULIANDAY(last_movement) > 180 THEN 'Consider Liquidation'
        WHEN JULIANDAY('now') - JULIANDAY(last_movement) > 90 THEN 'Promotion Candidate'
        ELSE 'Monitor'
    END AS recommendation
FROM product_movement
WHERE stock_quantity > 0
    AND (last_movement IS NULL OR JULIANDAY('now') - JULIANDAY(last_movement) > 60)
ORDER BY tied_up_capital DESC;

-- Warehouse space utilization (estimated)
SELECT
    category,
    COUNT(*) AS sku_count,
    SUM(stock_quantity) AS total_units,
    -- Assuming average space per unit category
    ROUND(SUM(stock_quantity) *
        CASE category
            WHEN 'Furniture' THEN 5.0
            WHEN 'Electronics' THEN 0.5
            WHEN 'Supplies' THEN 0.2
            ELSE 1.0
        END, 2) AS estimated_space_units,
    ROUND(SUM(stock_quantity * unit_cost), 2) AS inventory_value
FROM products
WHERE is_active = 1
GROUP BY category
ORDER BY estimated_space_units DESC;

-- ABC analysis (inventory classification)
WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        p.stock_quantity,
        ROUND(p.stock_quantity * p.unit_cost, 2) AS inventory_value,
        COALESCE(SUM(oi.line_total), 0) AS total_revenue
    FROM products p
    LEFT JOIN order_items oi ON p.product_id = oi.product_id
    LEFT JOIN orders o ON oi.order_id = o.order_id AND o.status = 'Completed'
    WHERE p.is_active = 1
    GROUP BY p.product_id, p.product_name, p.category, p.stock_quantity, p.unit_cost
),
ranked_products AS (
    SELECT
        *,
        SUM(total_revenue) OVER (ORDER BY total_revenue DESC) AS cumulative_revenue,
        SUM(total_revenue) OVER () AS total_all_revenue
    FROM product_revenue
)
SELECT
    product_name,
    category,
    stock_quantity,
    inventory_value,
    ROUND(total_revenue, 2) AS revenue,
    CASE
        WHEN cumulative_revenue <= total_all_revenue * 0.7 THEN 'A - High Value'
        WHEN cumulative_revenue <= total_all_revenue * 0.9 THEN 'B - Medium Value'
        ELSE 'C - Low Value'
    END AS abc_class
FROM ranked_products
ORDER BY total_revenue DESC;
