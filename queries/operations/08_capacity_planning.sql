-- =============================================
-- Query: Capacity Planning Analysis
-- Category: Operations Analytics
-- Difficulty: Advanced
--
-- Business Question:
-- What is our current operational capacity?
-- How should we plan for future growth?
--
-- Use Case:
-- Resource planning, hiring decisions,
-- and infrastructure investment.
-- =============================================

-- Order volume trend for capacity planning
SELECT
    strftime('%Y-%m', order_date) AS month,
    COUNT(*) AS order_count,
    ROUND(SUM(total_amount), 2) AS revenue,
    COUNT(DISTINCT customer_id) AS unique_customers,
    ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT strftime('%d', order_date)), 1) AS avg_daily_orders
FROM orders
WHERE status != 'Cancelled'
GROUP BY strftime('%Y-%m', order_date)
ORDER BY month DESC
LIMIT 12;

-- =============================================
-- Expected Output:
-- | month   | order_count | revenue     | avg_daily_orders |
-- |---------|-------------|-------------|------------------|
-- | 2024-02 | 48          | 125,430.00  | 1.7              |
-- | 2024-01 | 55          | 142,280.00  | 1.8              |
-- =============================================

-- Sales team capacity analysis
SELECT
    e.employee_id,
    e.first_name || ' ' || e.last_name AS sales_rep,
    e.hire_date,
    ROUND(JULIANDAY('now') - JULIANDAY(e.hire_date)) AS days_employed,
    COUNT(o.order_id) AS orders_handled,
    ROUND(SUM(o.total_amount), 2) AS total_revenue,
    ROUND(SUM(o.total_amount) / COUNT(o.order_id), 2) AS avg_order_value,
    CASE
        WHEN COUNT(o.order_id) > 50 THEN 'At Capacity'
        WHEN COUNT(o.order_id) > 30 THEN 'Moderate Load'
        ELSE 'Available Capacity'
    END AS workload_status
FROM employees e
LEFT JOIN orders o ON e.employee_id = o.employee_id AND o.status = 'Completed'
WHERE e.department = 'Sales'
    AND e.status = 'Active'
GROUP BY e.employee_id, e.first_name, e.last_name, e.hire_date
ORDER BY orders_handled DESC;

-- Department staffing analysis
SELECT
    department,
    COUNT(*) AS headcount,
    SUM(CASE WHEN status = 'Active' THEN 1 ELSE 0 END) AS active_employees,
    ROUND(SUM(salary), 2) AS total_monthly_payroll,
    ROUND(AVG(salary), 2) AS avg_salary,
    ROUND(AVG(JULIANDAY('now') - JULIANDAY(hire_date)) / 365, 1) AS avg_tenure_years
FROM employees
GROUP BY department
ORDER BY headcount DESC;

-- Warehouse capacity by product volume
SELECT
    p.category,
    COUNT(*) AS sku_count,
    SUM(p.stock_quantity) AS total_units,
    ROUND(SUM(p.stock_quantity * p.unit_cost), 2) AS inventory_value,
    SUM(COALESCE(monthly_sales.units, 0)) AS monthly_throughput,
    CASE
        WHEN SUM(p.stock_quantity) > SUM(COALESCE(monthly_sales.units, 0)) * 3 THEN 'Overstocked'
        WHEN SUM(p.stock_quantity) < SUM(COALESCE(monthly_sales.units, 0)) THEN 'Understocked'
        ELSE 'Balanced'
    END AS inventory_status
FROM products p
LEFT JOIN (
    SELECT
        oi.product_id,
        SUM(oi.quantity) / COUNT(DISTINCT strftime('%Y-%m', o.order_date)) AS units
    FROM order_items oi
    INNER JOIN orders o ON oi.order_id = o.order_id
    WHERE o.status = 'Completed'
    GROUP BY oi.product_id
) monthly_sales ON p.product_id = monthly_sales.product_id
WHERE p.is_active = 1
GROUP BY p.category
ORDER BY total_units DESC;

-- Growth projection data
WITH monthly_metrics AS (
    SELECT
        strftime('%Y-%m', order_date) AS month,
        COUNT(*) AS orders,
        SUM(total_amount) AS revenue,
        COUNT(DISTINCT customer_id) AS customers
    FROM orders
    WHERE status = 'Completed'
    GROUP BY strftime('%Y-%m', order_date)
),
growth_calc AS (
    SELECT
        month,
        orders,
        revenue,
        customers,
        LAG(orders) OVER (ORDER BY month) AS prev_orders,
        LAG(revenue) OVER (ORDER BY month) AS prev_revenue
    FROM monthly_metrics
)
SELECT
    month,
    orders,
    ROUND(revenue, 2) AS revenue,
    customers,
    ROUND((orders - prev_orders) * 100.0 / NULLIF(prev_orders, 0), 2) AS order_growth_pct,
    ROUND((revenue - prev_revenue) * 100.0 / NULLIF(prev_revenue, 0), 2) AS revenue_growth_pct
FROM growth_calc
ORDER BY month DESC
LIMIT 12;

-- Peak load analysis
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
    COUNT(*) AS total_orders,
    ROUND(AVG(total_amount), 2) AS avg_order_value,
    MAX(total_amount) AS max_order,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS pct_of_volume
FROM orders
GROUP BY strftime('%w', order_date)
ORDER BY total_orders DESC;

-- Customer acquisition capacity
SELECT
    strftime('%Y-%m', first_order) AS cohort_month,
    COUNT(*) AS new_customers,
    ROUND(SUM(total_spend), 2) AS cohort_revenue,
    ROUND(AVG(total_spend), 2) AS avg_customer_value
FROM (
    SELECT
        customer_id,
        MIN(order_date) AS first_order,
        SUM(total_amount) AS total_spend
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id
)
GROUP BY strftime('%Y-%m', first_order)
ORDER BY cohort_month DESC
LIMIT 12;

-- Resource utilization summary
SELECT 'Sales Capacity' AS metric,
    (SELECT COUNT(*) FROM employees WHERE department = 'Sales' AND status = 'Active') AS value,
    'headcount' AS unit

UNION ALL

SELECT 'Monthly Order Volume' AS metric,
    (SELECT COUNT(*) FROM orders WHERE order_date >= DATE('now', '-30 days')) AS value,
    'orders' AS unit

UNION ALL

SELECT 'Active SKUs' AS metric,
    (SELECT COUNT(*) FROM products WHERE is_active = 1) AS value,
    'products' AS unit

UNION ALL

SELECT 'Active Customers' AS metric,
    (SELECT COUNT(DISTINCT customer_id) FROM orders WHERE order_date >= DATE('now', '-90 days')) AS value,
    'customers' AS unit;
