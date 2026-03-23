-- =============================================
-- Query: Product Performance Analysis
-- Category: Sales Analytics
-- Difficulty: Intermediate
--
-- Business Question:
-- Which products generate the most revenue and profit?
-- What is the sales velocity and margin for each product?
--
-- Use Case:
-- Product managers and merchandising teams use this to optimize
-- inventory, pricing, and promotional strategies.
-- =============================================

-- Product performance summary
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.subcategory,
    p.unit_price,
    p.unit_cost,
    ROUND((p.unit_price - p.unit_cost) / p.unit_price * 100, 2) AS margin_percent,
    COUNT(DISTINCT oi.order_id) AS times_ordered,
    SUM(oi.quantity) AS total_units_sold,
    ROUND(SUM(oi.line_total), 2) AS total_revenue,
    ROUND(SUM(oi.quantity * p.unit_cost), 2) AS total_cost,
    ROUND(SUM(oi.line_total) - SUM(oi.quantity * p.unit_cost), 2) AS gross_profit
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id AND o.status = 'Completed'
GROUP BY p.product_id, p.product_name, p.category, p.subcategory, p.unit_price, p.unit_cost
HAVING total_units_sold > 0
ORDER BY total_revenue DESC;

-- =============================================
-- Expected Output:
-- | product_name        | category    | margin_percent | total_units_sold | total_revenue | gross_profit |
-- |---------------------|-------------|----------------|------------------|---------------|--------------|
-- | Laptop Pro 15"      | Electronics | 28.89          | 156              | 66,690.00     | 19,266.00    |
-- | Office Chair        | Furniture   | 43.75          | 89               | 27,075.20     | 11,845.40    |
-- =============================================

-- Category performance breakdown
SELECT
    p.category,
    COUNT(DISTINCT p.product_id) AS product_count,
    SUM(oi.quantity) AS total_units_sold,
    ROUND(SUM(oi.line_total), 2) AS category_revenue,
    ROUND(AVG((p.unit_price - p.unit_cost) / p.unit_price * 100), 2) AS avg_margin_percent,
    ROUND(SUM(oi.line_total) * 100.0 /
          (SELECT SUM(line_total) FROM order_items), 2) AS revenue_share_percent
FROM products p
INNER JOIN order_items oi ON p.product_id = oi.product_id
INNER JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY p.category
ORDER BY category_revenue DESC;

-- Products needing attention (low sales or margin)
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.stock_quantity,
    COALESCE(SUM(oi.quantity), 0) AS total_sold,
    ROUND((p.unit_price - p.unit_cost) / p.unit_price * 100, 2) AS margin_percent,
    CASE
        WHEN COALESCE(SUM(oi.quantity), 0) = 0 THEN 'No Sales'
        WHEN COALESCE(SUM(oi.quantity), 0) < 10 THEN 'Low Sales'
        WHEN (p.unit_price - p.unit_cost) / p.unit_price < 0.2 THEN 'Low Margin'
        ELSE 'OK'
    END AS attention_flag
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id AND o.status = 'Completed'
WHERE p.is_active = 1
GROUP BY p.product_id, p.product_name, p.category, p.stock_quantity, p.unit_price, p.unit_cost
HAVING attention_flag != 'OK'
ORDER BY attention_flag, total_sold;
