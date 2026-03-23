-- =============================================
-- Query: Market Basket Analysis
-- Category: Advanced Analytics
-- Difficulty: Advanced
--
-- Business Question:
-- What products are frequently purchased together?
-- What cross-sell opportunities exist?
--
-- Use Case:
-- Product recommendations, bundle creation,
-- store layout optimization, and upselling.
-- =============================================

-- Products frequently bought together
WITH order_products AS (
    SELECT
        o.order_id,
        oi.product_id,
        p.product_name,
        p.category
    FROM orders o
    INNER JOIN order_items oi ON o.order_id = oi.order_id
    INNER JOIN products p ON oi.product_id = p.product_id
    WHERE o.status = 'Completed'
)
SELECT
    op1.product_name AS product_a,
    op2.product_name AS product_b,
    COUNT(*) AS times_bought_together,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT order_id) FROM order_products), 2) AS pct_of_orders
FROM order_products op1
INNER JOIN order_products op2 ON op1.order_id = op2.order_id
    AND op1.product_id < op2.product_id
GROUP BY op1.product_name, op2.product_name
HAVING COUNT(*) >= 3
ORDER BY times_bought_together DESC
LIMIT 20;

-- =============================================
-- Expected Output:
-- | product_a        | product_b          | times_bought_together | pct_of_orders |
-- |------------------|--------------------|-----------------------|---------------|
-- | Laptop Pro 15"   | Wireless Mouse     | 25                    | 31.25         |
-- | Office Chair     | Executive Desk     | 18                    | 22.50         |
-- =============================================

-- Category affinity analysis
WITH order_categories AS (
    SELECT DISTINCT
        o.order_id,
        p.category
    FROM orders o
    INNER JOIN order_items oi ON o.order_id = oi.order_id
    INNER JOIN products p ON oi.product_id = p.product_id
    WHERE o.status = 'Completed'
)
SELECT
    oc1.category AS category_a,
    oc2.category AS category_b,
    COUNT(*) AS co_occurrence,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT order_id) FROM order_categories), 2) AS affinity_pct
FROM order_categories oc1
INNER JOIN order_categories oc2 ON oc1.order_id = oc2.order_id
    AND oc1.category < oc2.category
GROUP BY oc1.category, oc2.category
ORDER BY co_occurrence DESC;

-- Product pair lift analysis
WITH product_orders AS (
    SELECT
        oi.product_id,
        p.product_name,
        COUNT(DISTINCT oi.order_id) AS orders_with_product
    FROM order_items oi
    INNER JOIN products p ON oi.product_id = p.product_id
    INNER JOIN orders o ON oi.order_id = o.order_id
    WHERE o.status = 'Completed'
    GROUP BY oi.product_id, p.product_name
),
product_pairs AS (
    SELECT
        oi1.product_id AS product_a_id,
        oi2.product_id AS product_b_id,
        COUNT(DISTINCT oi1.order_id) AS pair_orders
    FROM order_items oi1
    INNER JOIN order_items oi2 ON oi1.order_id = oi2.order_id
        AND oi1.product_id < oi2.product_id
    INNER JOIN orders o ON oi1.order_id = o.order_id
    WHERE o.status = 'Completed'
    GROUP BY oi1.product_id, oi2.product_id
),
total_orders AS (
    SELECT COUNT(DISTINCT order_id) AS total FROM orders WHERE status = 'Completed'
)
SELECT
    pa.product_name AS product_a,
    pb.product_name AS product_b,
    pp.pair_orders,
    pa.orders_with_product AS product_a_orders,
    pb.orders_with_product AS product_b_orders,
    -- Lift = P(A and B) / (P(A) * P(B))
    ROUND(
        (pp.pair_orders * 1.0 / t.total) /
        ((pa.orders_with_product * 1.0 / t.total) * (pb.orders_with_product * 1.0 / t.total)),
        2
    ) AS lift
FROM product_pairs pp
INNER JOIN product_orders pa ON pp.product_a_id = pa.product_id
INNER JOIN product_orders pb ON pp.product_b_id = pb.product_id
CROSS JOIN total_orders t
WHERE pp.pair_orders >= 3
ORDER BY lift DESC
LIMIT 20;

-- Basket size analysis
SELECT
    item_count AS basket_size,
    COUNT(*) AS order_count,
    ROUND(AVG(total_amount), 2) AS avg_order_value,
    ROUND(SUM(total_amount), 2) AS total_revenue
FROM (
    SELECT
        o.order_id,
        o.total_amount,
        COUNT(oi.product_id) AS item_count
    FROM orders o
    INNER JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'Completed'
    GROUP BY o.order_id, o.total_amount
)
GROUP BY item_count
ORDER BY item_count;

-- Recommended bundles (high affinity pairs with good margins)
WITH product_pairs AS (
    SELECT
        oi1.product_id AS product_a_id,
        oi2.product_id AS product_b_id,
        COUNT(DISTINCT oi1.order_id) AS times_together
    FROM order_items oi1
    INNER JOIN order_items oi2 ON oi1.order_id = oi2.order_id
        AND oi1.product_id < oi2.product_id
    INNER JOIN orders o ON oi1.order_id = o.order_id
    WHERE o.status = 'Completed'
    GROUP BY oi1.product_id, oi2.product_id
    HAVING COUNT(*) >= 3
)
SELECT
    pa.product_name AS product_a,
    pa.category AS category_a,
    pb.product_name AS product_b,
    pb.category AS category_b,
    pp.times_together,
    ROUND(pa.unit_price + pb.unit_price, 2) AS bundle_price,
    ROUND((pa.unit_price - pa.unit_cost) + (pb.unit_price - pb.unit_cost), 2) AS bundle_margin,
    ROUND(((pa.unit_price - pa.unit_cost) + (pb.unit_price - pb.unit_cost)) /
          (pa.unit_price + pb.unit_price) * 100, 2) AS margin_pct
FROM product_pairs pp
INNER JOIN products pa ON pp.product_a_id = pa.product_id
INNER JOIN products pb ON pp.product_b_id = pb.product_id
ORDER BY times_together DESC, margin_pct DESC
LIMIT 10;

-- Cross-sell recommendations by category
WITH category_affinity AS (
    SELECT DISTINCT
        o.order_id,
        o.customer_id,
        p.category
    FROM orders o
    INNER JOIN order_items oi ON o.order_id = oi.order_id
    INNER JOIN products p ON oi.product_id = p.product_id
    WHERE o.status = 'Completed'
),
customer_categories AS (
    SELECT
        customer_id,
        GROUP_CONCAT(DISTINCT category) AS purchased_categories
    FROM category_affinity
    GROUP BY customer_id
)
SELECT
    purchased_categories,
    COUNT(*) AS customer_count,
    CASE
        WHEN purchased_categories NOT LIKE '%Electronics%' AND purchased_categories LIKE '%Furniture%' THEN 'Recommend: Electronics'
        WHEN purchased_categories NOT LIKE '%Furniture%' AND purchased_categories LIKE '%Electronics%' THEN 'Recommend: Furniture'
        WHEN purchased_categories NOT LIKE '%Supplies%' THEN 'Recommend: Office Supplies'
        ELSE 'Full catalog buyer'
    END AS recommendation
FROM customer_categories
GROUP BY purchased_categories
ORDER BY customer_count DESC;
