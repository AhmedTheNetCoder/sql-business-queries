-- =============================================
-- Query: Delivery Performance Analysis
-- Category: Operations Analytics
-- Difficulty: Intermediate
--
-- Business Question:
-- How well are we meeting delivery commitments?
-- What regions have delivery challenges?
--
-- Use Case:
-- Logistics optimization, customer satisfaction,
-- and delivery SLA monitoring.
-- =============================================

-- Overall delivery performance
SELECT
    strftime('%Y-%m', order_date) AS month,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) AS delivered,
    SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled,
    ROUND(SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS delivery_rate,
    ROUND(SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS cancellation_rate
FROM orders
GROUP BY strftime('%Y-%m', order_date)
ORDER BY month DESC
LIMIT 12;

-- =============================================
-- Expected Output:
-- | month   | total_orders | delivered | cancelled | delivery_rate |
-- |---------|--------------|-----------|-----------|---------------|
-- | 2024-02 | 48           | 42        | 3         | 87.50         |
-- | 2024-01 | 55           | 51        | 2         | 92.73         |
-- =============================================

-- Delivery performance by region
SELECT
    r.region_name,
    r.region_code,
    COUNT(o.order_id) AS total_orders,
    SUM(CASE WHEN o.status = 'Completed' THEN 1 ELSE 0 END) AS delivered,
    ROUND(SUM(CASE WHEN o.status = 'Completed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS delivery_rate,
    ROUND(AVG(o.total_amount), 2) AS avg_order_value,
    ROUND(SUM(o.total_amount), 2) AS total_revenue
FROM regions r
INNER JOIN customers c ON r.region_id = c.region_id
INNER JOIN orders o ON c.customer_id = o.customer_id
GROUP BY r.region_name, r.region_code
ORDER BY total_orders DESC;

-- Customer delivery satisfaction (based on completed orders)
SELECT
    c.customer_id,
    c.company_name,
    r.region_name,
    COUNT(o.order_id) AS total_orders,
    SUM(CASE WHEN o.status = 'Completed' THEN 1 ELSE 0 END) AS completed_orders,
    SUM(CASE WHEN o.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
    ROUND(SUM(CASE WHEN o.status = 'Completed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS success_rate
FROM customers c
INNER JOIN regions r ON c.region_id = r.region_id
INNER JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.company_name, r.region_name
HAVING COUNT(*) >= 3
ORDER BY success_rate ASC, total_orders DESC;

-- Orders pending delivery
SELECT
    o.order_id,
    o.order_number,
    c.company_name AS customer,
    r.region_name,
    c.city,
    o.order_date,
    JULIANDAY('now') - JULIANDAY(o.order_date) AS days_pending,
    o.total_amount,
    o.status,
    CASE
        WHEN JULIANDAY('now') - JULIANDAY(o.order_date) > 7 THEN 'Critical'
        WHEN JULIANDAY('now') - JULIANDAY(o.order_date) > 3 THEN 'Warning'
        ELSE 'On Track'
    END AS delivery_status
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN regions r ON c.region_id = r.region_id
WHERE o.status IN ('Pending', 'Processing')
ORDER BY days_pending DESC;

-- Delivery by day of week
SELECT
    CASE CAST(strftime('%w', order_date) AS INTEGER)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END AS day_name,
    COUNT(*) AS orders_placed,
    SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) AS delivered,
    ROUND(SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS delivery_rate
FROM orders
GROUP BY strftime('%w', order_date)
ORDER BY CAST(strftime('%w', order_date) AS INTEGER);

-- Cancelled orders analysis
SELECT
    strftime('%Y-%m', order_date) AS month,
    COUNT(*) AS cancelled_orders,
    ROUND(SUM(total_amount), 2) AS lost_revenue,
    ROUND(AVG(total_amount), 2) AS avg_cancelled_value
FROM orders
WHERE status = 'Cancelled'
GROUP BY strftime('%Y-%m', order_date)
ORDER BY month DESC
LIMIT 12;

-- High-value pending deliveries
SELECT
    o.order_id,
    o.order_number,
    c.company_name,
    c.customer_type,
    o.order_date,
    o.total_amount,
    JULIANDAY('now') - JULIANDAY(o.order_date) AS days_since_order,
    'Requires Priority Handling' AS action
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
WHERE o.status IN ('Pending', 'Processing')
    AND (o.total_amount > 5000 OR c.customer_type = 'Enterprise')
ORDER BY o.total_amount DESC;

-- Regional delivery capacity analysis
SELECT
    r.region_name,
    COUNT(DISTINCT c.customer_id) AS customers,
    COUNT(o.order_id) AS orders_last_30_days,
    ROUND(AVG(o.total_amount), 2) AS avg_order_value,
    ROUND(SUM(o.total_amount) / 30, 2) AS daily_avg_revenue
FROM regions r
INNER JOIN customers c ON r.region_id = c.region_id
LEFT JOIN orders o ON c.customer_id = o.customer_id
    AND o.order_date >= DATE('now', '-30 days')
GROUP BY r.region_name
ORDER BY orders_last_30_days DESC;
