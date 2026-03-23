-- =============================================
-- Query: Order Fulfillment Analysis
-- Category: Operations Analytics
-- Difficulty: Intermediate
--
-- Business Question:
-- How efficiently are we fulfilling orders?
-- What is our average fulfillment time?
--
-- Use Case:
-- Operational efficiency, customer satisfaction,
-- and process improvement.
-- =============================================

-- Order fulfillment metrics
SELECT
    strftime('%Y-%m', order_date) AS month,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) AS completed,
    SUM(CASE WHEN status = 'Pending' THEN 1 ELSE 0 END) AS pending,
    SUM(CASE WHEN status = 'Processing' THEN 1 ELSE 0 END) AS processing,
    SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled,
    ROUND(SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS fulfillment_rate
FROM orders
GROUP BY strftime('%Y-%m', order_date)
ORDER BY month DESC
LIMIT 12;

-- =============================================
-- Expected Output:
-- | month   | total_orders | completed | pending | fulfillment_rate |
-- |---------|--------------|-----------|---------|------------------|
-- | 2024-02 | 45           | 38        | 5       | 84.44            |
-- | 2024-01 | 52           | 48        | 2       | 92.31            |
-- =============================================

-- Average fulfillment time by status
SELECT
    status,
    COUNT(*) AS order_count,
    ROUND(SUM(total_amount), 2) AS total_value,
    ROUND(AVG(total_amount), 2) AS avg_order_value
FROM orders
GROUP BY status
ORDER BY order_count DESC;

-- Orders by region fulfillment
SELECT
    r.region_name,
    COUNT(o.order_id) AS total_orders,
    SUM(CASE WHEN o.status = 'Completed' THEN 1 ELSE 0 END) AS completed,
    ROUND(SUM(CASE WHEN o.status = 'Completed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS completion_rate,
    ROUND(AVG(o.total_amount), 2) AS avg_order_value
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN regions r ON c.region_id = r.region_id
GROUP BY r.region_name
ORDER BY total_orders DESC;

-- Pending orders requiring attention
SELECT
    o.order_id,
    o.order_number,
    c.company_name AS customer,
    o.order_date,
    JULIANDAY('now') - JULIANDAY(o.order_date) AS days_pending,
    o.total_amount,
    o.status,
    CASE
        WHEN JULIANDAY('now') - JULIANDAY(o.order_date) > 7 THEN 'Urgent'
        WHEN JULIANDAY('now') - JULIANDAY(o.order_date) > 3 THEN 'High'
        ELSE 'Normal'
    END AS priority
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
WHERE o.status IN ('Pending', 'Processing')
ORDER BY days_pending DESC;

-- Daily order volume
SELECT
    strftime('%w', order_date) AS day_of_week,
    CASE CAST(strftime('%w', order_date) AS INTEGER)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END AS day_name,
    COUNT(*) AS order_count,
    ROUND(AVG(total_amount), 2) AS avg_order_value,
    ROUND(SUM(total_amount), 2) AS total_revenue
FROM orders
WHERE status = 'Completed'
GROUP BY strftime('%w', order_date)
ORDER BY CAST(strftime('%w', order_date) AS INTEGER);

-- Order size distribution
SELECT
    CASE
        WHEN total_amount < 500 THEN 'Small (<500)'
        WHEN total_amount < 2000 THEN 'Medium (500-2000)'
        WHEN total_amount < 5000 THEN 'Large (2000-5000)'
        ELSE 'Enterprise (5000+)'
    END AS order_size,
    COUNT(*) AS order_count,
    ROUND(SUM(total_amount), 2) AS total_revenue,
    ROUND(AVG(total_amount), 2) AS avg_value,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders WHERE status = 'Completed'), 2) AS pct_of_orders
FROM orders
WHERE status = 'Completed'
GROUP BY order_size
ORDER BY MIN(total_amount);

-- Employee fulfillment performance
SELECT
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    e.department,
    COUNT(o.order_id) AS orders_handled,
    SUM(CASE WHEN o.status = 'Completed' THEN 1 ELSE 0 END) AS completed,
    ROUND(SUM(o.total_amount), 2) AS total_value,
    ROUND(SUM(CASE WHEN o.status = 'Completed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS completion_rate
FROM employees e
INNER JOIN orders o ON e.employee_id = o.employee_id
WHERE e.department = 'Sales'
GROUP BY e.employee_id, e.first_name, e.last_name, e.department
ORDER BY orders_handled DESC;
