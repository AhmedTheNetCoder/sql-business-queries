-- =============================================
-- Query: Profit Margin by Product
-- Category: Finance Analytics
-- Difficulty: Intermediate
--
-- Business Question:
-- What is the profit margin for each product and category?
-- Which products are most/least profitable?
--
-- Use Case:
-- Pricing strategy, product portfolio optimization,
-- and profitability analysis.
-- =============================================

-- Product profitability analysis
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.unit_price,
    p.unit_cost,
    ROUND(p.unit_price - p.unit_cost, 2) AS unit_margin,
    ROUND((p.unit_price - p.unit_cost) / p.unit_price * 100, 2) AS margin_percent,
    COALESCE(SUM(oi.quantity), 0) AS units_sold,
    ROUND(COALESCE(SUM(oi.line_total), 0), 2) AS total_revenue,
    ROUND(COALESCE(SUM(oi.quantity * p.unit_cost), 0), 2) AS total_cost,
    ROUND(COALESCE(SUM(oi.line_total), 0) - COALESCE(SUM(oi.quantity * p.unit_cost), 0), 2) AS gross_profit
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id AND o.status = 'Completed'
GROUP BY p.product_id, p.product_name, p.category, p.unit_price, p.unit_cost
ORDER BY gross_profit DESC;

-- =============================================
-- Expected Output:
-- | product_name      | category    | unit_margin | margin_percent | units_sold | gross_profit |
-- |-------------------|-------------|-------------|----------------|------------|--------------|
-- | Laptop Pro 15"    | Electronics | 130.00      | 28.89          | 156        | 20,280.00    |
-- | Executive Desk    | Furniture   | 170.00      | 37.78          | 45         | 7,650.00     |
-- =============================================

-- Category profitability
SELECT
    p.category,
    COUNT(DISTINCT p.product_id) AS products,
    SUM(oi.quantity) AS total_units,
    ROUND(SUM(oi.line_total), 2) AS total_revenue,
    ROUND(SUM(oi.quantity * p.unit_cost), 2) AS total_cost,
    ROUND(SUM(oi.line_total) - SUM(oi.quantity * p.unit_cost), 2) AS gross_profit,
    ROUND((SUM(oi.line_total) - SUM(oi.quantity * p.unit_cost)) / SUM(oi.line_total) * 100, 2) AS profit_margin,
    ROUND((SUM(oi.line_total) - SUM(oi.quantity * p.unit_cost)) * 100.0 /
          (SELECT SUM(oi2.line_total) - SUM(oi2.quantity * p2.unit_cost)
           FROM order_items oi2
           INNER JOIN products p2 ON oi2.product_id = p2.product_id
           INNER JOIN orders o2 ON oi2.order_id = o2.order_id
           WHERE o2.status = 'Completed'), 2) AS profit_contribution
FROM products p
INNER JOIN order_items oi ON p.product_id = oi.product_id
INNER JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY p.category
ORDER BY gross_profit DESC;

-- Products by margin tier
SELECT
    CASE
        WHEN (unit_price - unit_cost) / unit_price >= 0.5 THEN 'High Margin (50%+)'
        WHEN (unit_price - unit_cost) / unit_price >= 0.3 THEN 'Medium Margin (30-50%)'
        WHEN (unit_price - unit_cost) / unit_price >= 0.15 THEN 'Low Margin (15-30%)'
        ELSE 'Very Low Margin (<15%)'
    END AS margin_tier,
    COUNT(*) AS product_count,
    ROUND(AVG((unit_price - unit_cost) / unit_price * 100), 2) AS avg_margin_percent,
    ROUND(AVG(unit_price), 2) AS avg_price,
    ROUND(AVG(unit_cost), 2) AS avg_cost
FROM products
WHERE is_active = 1
GROUP BY margin_tier
ORDER BY avg_margin_percent DESC;

-- Profitability trend over time
SELECT
    strftime('%Y-%m', o.order_date) AS month,
    ROUND(SUM(oi.line_total), 2) AS revenue,
    ROUND(SUM(oi.quantity * p.unit_cost), 2) AS cost,
    ROUND(SUM(oi.line_total) - SUM(oi.quantity * p.unit_cost), 2) AS gross_profit,
    ROUND((SUM(oi.line_total) - SUM(oi.quantity * p.unit_cost)) / SUM(oi.line_total) * 100, 2) AS margin_percent
FROM orders o
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN products p ON oi.product_id = p.product_id
WHERE o.status = 'Completed'
GROUP BY strftime('%Y-%m', o.order_date)
ORDER BY month DESC
LIMIT 12;

-- Low margin products needing attention
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.unit_price,
    p.unit_cost,
    ROUND((p.unit_price - p.unit_cost) / p.unit_price * 100, 2) AS margin_percent,
    COALESCE(SUM(oi.quantity), 0) AS units_sold,
    CASE
        WHEN (p.unit_price - p.unit_cost) / p.unit_price < 0.15 THEN 'Consider Price Increase'
        WHEN COALESCE(SUM(oi.quantity), 0) < 10 THEN 'Low Volume - Review'
        ELSE 'Monitor'
    END AS recommendation
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id AND o.status = 'Completed'
WHERE p.is_active = 1
GROUP BY p.product_id, p.product_name, p.category, p.unit_price, p.unit_cost
HAVING margin_percent < 30 OR units_sold < 10
ORDER BY margin_percent ASC;

-- Margin by supplier
SELECT
    s.supplier_id,
    s.supplier_name,
    COUNT(DISTINCT p.product_id) AS products_supplied,
    ROUND(AVG((p.unit_price - p.unit_cost) / p.unit_price * 100), 2) AS avg_margin_percent,
    ROUND(SUM(oi.line_total - oi.quantity * p.unit_cost), 2) AS total_profit_generated
FROM suppliers s
INNER JOIN products p ON s.supplier_id = p.supplier_id
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id AND o.status = 'Completed'
GROUP BY s.supplier_id, s.supplier_name
ORDER BY avg_margin_percent DESC;
