-- =============================================
-- Query: Best Selling Products Analysis
-- Category: Sales Analytics
-- Difficulty: Beginner
--
-- Business Question:
-- What are our top-selling products by units and revenue?
-- How do sales vary across categories?
--
-- Use Case:
-- Inventory planning, promotional focus, and supplier
-- negotiations based on sales velocity.
-- =============================================

-- Top 15 products by units sold
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.subcategory,
    SUM(oi.quantity) AS units_sold,
    COUNT(DISTINCT oi.order_id) AS order_count,
    ROUND(SUM(oi.line_total), 2) AS total_revenue,
    ROUND(AVG(oi.quantity), 1) AS avg_units_per_order,
    p.stock_quantity AS current_stock,
    CASE
        WHEN p.stock_quantity < p.reorder_level THEN 'Reorder Needed'
        WHEN p.stock_quantity < p.reorder_level * 2 THEN 'Low Stock'
        ELSE 'OK'
    END AS stock_status
FROM products p
INNER JOIN order_items oi ON p.product_id = oi.product_id
INNER JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY p.product_id, p.product_name, p.category, p.subcategory, p.stock_quantity, p.reorder_level
ORDER BY units_sold DESC
LIMIT 15;

-- =============================================
-- Expected Output:
-- | product_name      | category       | units_sold | total_revenue | stock_status |
-- |-------------------|----------------|------------|---------------|--------------|
-- | A4 Paper (5 Ream) | Office Supplies| 450        | 7,695.00      | OK           |
-- | Wireless Mouse    | Electronics    | 280        | 6,650.00      | OK           |
-- | Ballpoint Pens    | Office Supplies| 250        | 1,900.00      | OK           |
-- =============================================

-- Top 15 products by revenue
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.unit_price,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.line_total), 2) AS total_revenue,
    ROUND(SUM(oi.line_total) - SUM(oi.quantity * p.unit_cost), 2) AS gross_profit,
    ROUND((SUM(oi.line_total) - SUM(oi.quantity * p.unit_cost)) / SUM(oi.line_total) * 100, 2) AS profit_margin
FROM products p
INNER JOIN order_items oi ON p.product_id = oi.product_id
INNER JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY p.product_id, p.product_name, p.category, p.unit_price, p.unit_cost
ORDER BY total_revenue DESC
LIMIT 15;

-- Best sellers by category
WITH category_rankings AS (
    SELECT
        p.category,
        p.product_name,
        SUM(oi.quantity) AS units_sold,
        ROUND(SUM(oi.line_total), 2) AS revenue,
        ROW_NUMBER() OVER (PARTITION BY p.category ORDER BY SUM(oi.quantity) DESC) AS rank
    FROM products p
    INNER JOIN order_items oi ON p.product_id = oi.product_id
    INNER JOIN orders o ON oi.order_id = o.order_id
    WHERE o.status = 'Completed'
    GROUP BY p.category, p.product_name
)
SELECT
    category,
    product_name AS top_product,
    units_sold,
    revenue
FROM category_rankings
WHERE rank = 1
ORDER BY revenue DESC;

-- Sales velocity (units per day)
SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(oi.quantity) AS total_units_sold,
    COUNT(DISTINCT o.order_date) AS selling_days,
    ROUND(SUM(oi.quantity) * 1.0 / COUNT(DISTINCT o.order_date), 2) AS units_per_selling_day,
    p.stock_quantity,
    ROUND(p.stock_quantity / (SUM(oi.quantity) * 1.0 / COUNT(DISTINCT o.order_date)), 0) AS days_of_stock
FROM products p
INNER JOIN order_items oi ON p.product_id = oi.product_id
INNER JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY p.product_id, p.product_name, p.category, p.stock_quantity
HAVING units_per_selling_day > 0
ORDER BY units_per_selling_day DESC;
