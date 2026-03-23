-- =============================================
-- Query: Financial Ratios & KPIs
-- Category: Finance Analytics
-- Difficulty: Advanced
--
-- Business Question:
-- What are the key financial ratios and KPIs
-- that indicate business health?
--
-- Use Case:
-- Executive reporting, investor relations,
-- financial analysis, and benchmarking.
-- =============================================

-- Key financial metrics dashboard
WITH revenue_metrics AS (
    SELECT
        SUM(total_amount) AS total_revenue,
        COUNT(*) AS total_orders,
        COUNT(DISTINCT customer_id) AS unique_customers
    FROM orders
    WHERE status = 'Completed'
),
cost_metrics AS (
    SELECT
        SUM(oi.quantity * p.unit_cost) AS total_cogs
    FROM order_items oi
    INNER JOIN products p ON oi.product_id = p.product_id
    INNER JOIN orders o ON oi.order_id = o.order_id
    WHERE o.status = 'Completed'
),
expense_metrics AS (
    SELECT SUM(amount) AS total_expenses
    FROM expenses
    WHERE status IN ('Approved', 'Paid')
),
payroll_metrics AS (
    SELECT SUM(salary) * 12 AS annual_payroll
    FROM employees
    WHERE status = 'Active'
)
SELECT
    'Revenue' AS metric,
    ROUND(r.total_revenue, 2) AS value,
    'OMR' AS unit
FROM revenue_metrics r
UNION ALL
SELECT
    'Cost of Goods Sold' AS metric,
    ROUND(c.total_cogs, 2) AS value,
    'OMR' AS unit
FROM cost_metrics c
UNION ALL
SELECT
    'Gross Profit' AS metric,
    ROUND(r.total_revenue - c.total_cogs, 2) AS value,
    'OMR' AS unit
FROM revenue_metrics r, cost_metrics c
UNION ALL
SELECT
    'Gross Margin %' AS metric,
    ROUND((r.total_revenue - c.total_cogs) / r.total_revenue * 100, 2) AS value,
    '%' AS unit
FROM revenue_metrics r, cost_metrics c
UNION ALL
SELECT
    'Operating Expenses' AS metric,
    ROUND(e.total_expenses, 2) AS value,
    'OMR' AS unit
FROM expense_metrics e
UNION ALL
SELECT
    'Average Order Value' AS metric,
    ROUND(r.total_revenue / r.total_orders, 2) AS value,
    'OMR' AS unit
FROM revenue_metrics r
UNION ALL
SELECT
    'Revenue per Customer' AS metric,
    ROUND(r.total_revenue / r.unique_customers, 2) AS value,
    'OMR' AS unit
FROM revenue_metrics r;

-- =============================================
-- Expected Output:
-- | metric              | value      | unit |
-- |---------------------|------------|------|
-- | Revenue             | 245,680.00 | OMR  |
-- | Gross Margin %      | 32.50      | %    |
-- | Average Order Value | 3,245.00   | OMR  |
-- =============================================

-- Monthly financial KPIs
WITH monthly_data AS (
    SELECT
        strftime('%Y-%m', o.order_date) AS month,
        SUM(o.total_amount) AS revenue,
        SUM(oi.quantity * p.unit_cost) AS cogs,
        COUNT(DISTINCT o.order_id) AS orders,
        COUNT(DISTINCT o.customer_id) AS customers
    FROM orders o
    INNER JOIN order_items oi ON o.order_id = oi.order_id
    INNER JOIN products p ON oi.product_id = p.product_id
    WHERE o.status = 'Completed'
    GROUP BY strftime('%Y-%m', o.order_date)
)
SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(cogs, 2) AS cogs,
    ROUND(revenue - cogs, 2) AS gross_profit,
    ROUND((revenue - cogs) / revenue * 100, 2) AS gross_margin_pct,
    orders,
    customers,
    ROUND(revenue / orders, 2) AS aov,
    ROUND(revenue / customers, 2) AS revenue_per_customer
FROM monthly_data
ORDER BY month DESC
LIMIT 12;

-- Working capital metrics
SELECT
    'Accounts Receivable' AS component,
    ROUND(SUM(total_amount - paid_amount), 2) AS amount,
    'Current Asset' AS type
FROM invoices
WHERE status NOT IN ('Paid', 'Cancelled')

UNION ALL

SELECT
    'Inventory Value' AS component,
    ROUND(SUM(stock_quantity * unit_cost), 2) AS amount,
    'Current Asset' AS type
FROM products
WHERE is_active = 1

UNION ALL

SELECT
    'Accounts Payable (Est.)' AS component,
    ROUND(SUM(amount), 2) AS amount,
    'Current Liability' AS type
FROM expenses
WHERE status IN ('Pending', 'Approved');

-- Efficiency ratios
WITH ar_data AS (
    SELECT
        SUM(total_amount - paid_amount) AS ar_balance,
        (SELECT SUM(total_amount) FROM orders WHERE status = 'Completed') / 365 AS daily_sales
    FROM invoices
    WHERE status NOT IN ('Paid', 'Cancelled')
),
inventory_data AS (
    SELECT
        SUM(p.stock_quantity * p.unit_cost) AS inventory_value,
        (SELECT SUM(oi.quantity * p2.unit_cost)
         FROM order_items oi
         INNER JOIN products p2 ON oi.product_id = p2.product_id
         INNER JOIN orders o ON oi.order_id = o.order_id
         WHERE o.status = 'Completed') / 365 AS daily_cogs
    FROM products p
    WHERE p.is_active = 1
)
SELECT
    'Days Sales Outstanding (DSO)' AS ratio,
    ROUND(ar.ar_balance / ar.daily_sales, 1) AS value,
    'days' AS unit,
    'Lower is better - faster collection' AS interpretation
FROM ar_data ar

UNION ALL

SELECT
    'Days Inventory Outstanding (DIO)' AS ratio,
    ROUND(i.inventory_value / i.daily_cogs, 1) AS value,
    'days' AS unit,
    'Balance between stockouts and holding costs' AS interpretation
FROM inventory_data i;

-- Customer concentration analysis
WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(total_amount) AS revenue
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id
),
total_revenue AS (
    SELECT SUM(revenue) AS total FROM customer_revenue
)
SELECT
    'Top Customer %' AS metric,
    ROUND(MAX(cr.revenue) * 100.0 / tr.total, 2) AS value,
    'Concentration Risk' AS category
FROM customer_revenue cr, total_revenue tr

UNION ALL

SELECT
    'Top 5 Customers %' AS metric,
    ROUND((SELECT SUM(revenue) FROM (SELECT revenue FROM customer_revenue ORDER BY revenue DESC LIMIT 5)) * 100.0 / tr.total, 2) AS value,
    'Concentration Risk' AS category
FROM total_revenue tr

UNION ALL

SELECT
    'Top 10 Customers %' AS metric,
    ROUND((SELECT SUM(revenue) FROM (SELECT revenue FROM customer_revenue ORDER BY revenue DESC LIMIT 10)) * 100.0 / tr.total, 2) AS value,
    'Concentration Risk' AS category
FROM total_revenue tr;

-- Year-over-year comparison
WITH yearly_metrics AS (
    SELECT
        strftime('%Y', order_date) AS year,
        SUM(total_amount) AS revenue,
        COUNT(DISTINCT order_id) AS orders,
        COUNT(DISTINCT customer_id) AS customers,
        SUM(total_amount) / COUNT(DISTINCT order_id) AS aov
    FROM orders
    WHERE status = 'Completed'
    GROUP BY strftime('%Y', order_date)
)
SELECT
    y1.year,
    ROUND(y1.revenue, 2) AS revenue,
    y1.orders,
    y1.customers,
    ROUND(y1.aov, 2) AS aov,
    ROUND((y1.revenue - y2.revenue) / y2.revenue * 100, 2) AS revenue_growth_pct,
    y1.orders - y2.orders AS orders_growth,
    y1.customers - y2.customers AS customers_growth
FROM yearly_metrics y1
LEFT JOIN yearly_metrics y2 ON y1.year = y2.year + 1
ORDER BY y1.year DESC;

-- Product profitability index
SELECT
    p.category,
    ROUND(SUM(oi.line_total), 2) AS revenue,
    ROUND(SUM(oi.quantity * p.unit_cost), 2) AS cost,
    ROUND(SUM(oi.line_total) - SUM(oi.quantity * p.unit_cost), 2) AS gross_profit,
    ROUND((SUM(oi.line_total) - SUM(oi.quantity * p.unit_cost)) / SUM(oi.line_total) * 100, 2) AS margin_pct,
    ROUND((SUM(oi.line_total) - SUM(oi.quantity * p.unit_cost)) * 100.0 /
          (SELECT SUM(oi2.line_total - oi2.quantity * p2.unit_cost)
           FROM order_items oi2
           INNER JOIN products p2 ON oi2.product_id = p2.product_id
           INNER JOIN orders o2 ON oi2.order_id = o2.order_id
           WHERE o2.status = 'Completed'), 2) AS profit_contribution_pct
FROM products p
INNER JOIN order_items oi ON p.product_id = oi.product_id
INNER JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY p.category
ORDER BY gross_profit DESC;
