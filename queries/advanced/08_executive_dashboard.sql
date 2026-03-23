-- =============================================
-- Query: Executive Dashboard KPIs
-- Category: Advanced Analytics
-- Difficulty: Advanced
--
-- Business Question:
-- What are the key metrics executives need to see?
-- How is the business performing overall?
--
-- Use Case:
-- Executive reporting, board presentations,
-- strategic decision-making, and KPI monitoring.
-- =============================================

-- Executive summary metrics
SELECT
    'Revenue (Total)' AS metric,
    ROUND(SUM(total_amount), 2) AS value,
    'OMR' AS unit
FROM orders WHERE status = 'Completed'

UNION ALL

SELECT
    'Revenue (This Month)' AS metric,
    ROUND(SUM(total_amount), 2) AS value,
    'OMR' AS unit
FROM orders
WHERE status = 'Completed'
    AND strftime('%Y-%m', order_date) = strftime('%Y-%m', 'now')

UNION ALL

SELECT
    'Orders (Total)' AS metric,
    COUNT(*) AS value,
    'count' AS unit
FROM orders WHERE status = 'Completed'

UNION ALL

SELECT
    'Active Customers' AS metric,
    COUNT(DISTINCT customer_id) AS value,
    'count' AS unit
FROM orders
WHERE status = 'Completed'
    AND order_date >= DATE('now', '-90 days')

UNION ALL

SELECT
    'Average Order Value' AS metric,
    ROUND(AVG(total_amount), 2) AS value,
    'OMR' AS unit
FROM orders WHERE status = 'Completed'

UNION ALL

SELECT
    'Employees' AS metric,
    COUNT(*) AS value,
    'count' AS unit
FROM employees WHERE status = 'Active'

UNION ALL

SELECT
    'Products (Active)' AS metric,
    COUNT(*) AS value,
    'count' AS unit
FROM products WHERE is_active = 1

UNION ALL

SELECT
    'Inventory Value' AS metric,
    ROUND(SUM(stock_quantity * unit_cost), 2) AS value,
    'OMR' AS unit
FROM products WHERE is_active = 1;

-- =============================================
-- Expected Output:
-- | metric              | value      | unit  |
-- |---------------------|------------|-------|
-- | Revenue (Total)     | 492,150.00 | OMR   |
-- | Active Customers    | 45         | count |
-- | Average Order Value | 3,245.00   | OMR   |
-- =============================================

-- Monthly performance trend
SELECT
    strftime('%Y-%m', order_date) AS month,
    COUNT(*) AS orders,
    COUNT(DISTINCT customer_id) AS customers,
    ROUND(SUM(total_amount), 2) AS revenue,
    ROUND(AVG(total_amount), 2) AS aov,
    LAG(ROUND(SUM(total_amount), 2)) OVER (ORDER BY strftime('%Y-%m', order_date)) AS prev_month_revenue,
    ROUND(
        (SUM(total_amount) - LAG(SUM(total_amount)) OVER (ORDER BY strftime('%Y-%m', order_date))) * 100.0 /
        LAG(SUM(total_amount)) OVER (ORDER BY strftime('%Y-%m', order_date)), 2
    ) AS mom_growth
FROM orders
WHERE status = 'Completed'
GROUP BY strftime('%Y-%m', order_date)
ORDER BY month DESC
LIMIT 12;

-- Department performance summary
SELECT
    'Sales' AS department,
    (SELECT COUNT(*) FROM employees WHERE department = 'Sales' AND status = 'Active') AS headcount,
    (SELECT ROUND(SUM(total_amount), 2) FROM orders WHERE status = 'Completed') AS revenue_generated,
    (SELECT COUNT(*) FROM orders WHERE status = 'Completed') AS orders_processed

UNION ALL

SELECT
    'Operations' AS department,
    (SELECT COUNT(*) FROM employees WHERE department = 'Operations' AND status = 'Active') AS headcount,
    NULL AS revenue_generated,
    (SELECT COUNT(*) FROM orders WHERE status IN ('Pending', 'Processing')) AS orders_in_pipeline

UNION ALL

SELECT
    'HR' AS department,
    (SELECT COUNT(*) FROM employees WHERE department = 'HR' AND status = 'Active') AS headcount,
    NULL AS revenue_generated,
    (SELECT COUNT(*) FROM employees WHERE status = 'Active') AS total_employees_managed;

-- Top 10 customers this quarter
SELECT
    c.company_name,
    c.customer_type,
    COUNT(o.order_id) AS orders,
    ROUND(SUM(o.total_amount), 2) AS revenue,
    ROUND(AVG(o.total_amount), 2) AS aov
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status = 'Completed'
    AND o.order_date >= DATE('now', '-3 months')
GROUP BY c.customer_id, c.company_name, c.customer_type
ORDER BY revenue DESC
LIMIT 10;

-- Product category performance
SELECT
    p.category,
    COUNT(DISTINCT p.product_id) AS products,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.line_total), 2) AS revenue,
    ROUND(SUM(oi.line_total) - SUM(oi.quantity * p.unit_cost), 2) AS gross_profit,
    ROUND((SUM(oi.line_total) - SUM(oi.quantity * p.unit_cost)) * 100.0 / SUM(oi.line_total), 2) AS margin_pct
FROM products p
INNER JOIN order_items oi ON p.product_id = oi.product_id
INNER JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY p.category
ORDER BY revenue DESC;

-- Regional performance
SELECT
    r.region_name,
    COUNT(DISTINCT c.customer_id) AS customers,
    COUNT(o.order_id) AS orders,
    ROUND(SUM(o.total_amount), 2) AS revenue,
    ROUND(SUM(o.total_amount) * 100.0 / (SELECT SUM(total_amount) FROM orders WHERE status = 'Completed'), 2) AS revenue_share
FROM regions r
INNER JOIN customers c ON r.region_id = c.region_id
INNER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status = 'Completed'
GROUP BY r.region_name
ORDER BY revenue DESC;

-- Financial health indicators
SELECT
    'Gross Margin' AS metric,
    ROUND(
        (SUM(oi.line_total) - SUM(oi.quantity * p.unit_cost)) * 100.0 / SUM(oi.line_total), 2
    ) AS value,
    '%' AS unit
FROM order_items oi
INNER JOIN products p ON oi.product_id = p.product_id
INNER JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Completed'

UNION ALL

SELECT
    'Accounts Receivable' AS metric,
    ROUND(SUM(total_amount - paid_amount), 2) AS value,
    'OMR' AS unit
FROM invoices
WHERE status NOT IN ('Paid', 'Cancelled')

UNION ALL

SELECT
    'Overdue Invoices' AS metric,
    COUNT(*) AS value,
    'count' AS unit
FROM invoices
WHERE status IN ('Overdue', 'Partial')
    AND due_date < DATE('now')

UNION ALL

SELECT
    'Monthly Payroll' AS metric,
    ROUND(SUM(salary), 2) AS value,
    'OMR' AS unit
FROM employees
WHERE status = 'Active';

-- Key alerts and action items
SELECT
    'Low Stock Products' AS alert_type,
    COUNT(*) AS count,
    'Reorder needed' AS action
FROM products
WHERE is_active = 1 AND stock_quantity <= reorder_level

UNION ALL

SELECT
    'Overdue Invoices' AS alert_type,
    COUNT(*) AS count,
    'Follow up on collections' AS action
FROM invoices
WHERE status IN ('Overdue', 'Partial') AND due_date < DATE('now')

UNION ALL

SELECT
    'Pending Orders' AS alert_type,
    COUNT(*) AS count,
    'Process pending orders' AS action
FROM orders
WHERE status = 'Pending'

UNION ALL

SELECT
    'At-Risk Customers' AS alert_type,
    COUNT(DISTINCT customer_id) AS count,
    'Re-engagement needed' AS action
FROM orders
WHERE status = 'Completed'
GROUP BY customer_id
HAVING JULIANDAY('now') - JULIANDAY(MAX(order_date)) BETWEEN 60 AND 90;

-- Year-to-date performance
SELECT
    strftime('%Y', 'now') AS current_year,
    COUNT(*) AS ytd_orders,
    COUNT(DISTINCT customer_id) AS ytd_customers,
    ROUND(SUM(total_amount), 2) AS ytd_revenue,
    ROUND(AVG(total_amount), 2) AS ytd_aov,
    (SELECT COUNT(*) FROM customers WHERE is_active = 1) AS total_active_customers,
    (SELECT COUNT(*) FROM products WHERE is_active = 1) AS active_products,
    (SELECT COUNT(*) FROM employees WHERE status = 'Active') AS active_employees
FROM orders
WHERE status = 'Completed'
    AND strftime('%Y', order_date) = strftime('%Y', 'now');
