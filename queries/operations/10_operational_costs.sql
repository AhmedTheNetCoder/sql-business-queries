-- =============================================
-- Query: Operational Costs Analysis
-- Category: Operations Analytics
-- Difficulty: Intermediate
--
-- Business Question:
-- What are our operational costs? How can we
-- optimize spending across operations?
--
-- Use Case:
-- Cost reduction, budget allocation,
-- and operational efficiency improvement.
-- =============================================

-- Monthly operational expenses
SELECT
    strftime('%Y-%m', expense_date) AS month,
    ROUND(SUM(amount), 2) AS total_expenses,
    ROUND(SUM(CASE WHEN category = 'Rent' THEN amount ELSE 0 END), 2) AS rent,
    ROUND(SUM(CASE WHEN category = 'Utilities' THEN amount ELSE 0 END), 2) AS utilities,
    ROUND(SUM(CASE WHEN category = 'IT' THEN amount ELSE 0 END), 2) AS it,
    ROUND(SUM(CASE WHEN category = 'Marketing' THEN amount ELSE 0 END), 2) AS marketing,
    ROUND(SUM(CASE WHEN category NOT IN ('Rent', 'Utilities', 'IT', 'Marketing') THEN amount ELSE 0 END), 2) AS other
FROM expenses
WHERE status IN ('Approved', 'Paid')
GROUP BY strftime('%Y-%m', expense_date)
ORDER BY month DESC
LIMIT 12;

-- =============================================
-- Expected Output:
-- | month   | total_expenses | rent     | utilities | it       | marketing |
-- |---------|----------------|----------|-----------|----------|-----------|
-- | 2024-02 | 45,230.00      | 15,000   | 3,500     | 8,200    | 12,500    |
-- | 2024-01 | 42,180.00      | 15,000   | 3,200     | 7,800    | 10,200    |
-- =============================================

-- Expense by department
SELECT
    department,
    COUNT(*) AS transaction_count,
    ROUND(SUM(amount), 2) AS total_spent,
    ROUND(AVG(amount), 2) AS avg_transaction,
    ROUND(SUM(amount) * 100.0 / (SELECT SUM(amount) FROM expenses WHERE status IN ('Approved', 'Paid')), 2) AS pct_of_total
FROM expenses
WHERE status IN ('Approved', 'Paid')
GROUP BY department
ORDER BY total_spent DESC;

-- Cost per order analysis
WITH monthly_costs AS (
    SELECT
        strftime('%Y-%m', expense_date) AS month,
        SUM(amount) AS expenses
    FROM expenses
    WHERE status IN ('Approved', 'Paid')
    GROUP BY strftime('%Y-%m', expense_date)
),
monthly_orders AS (
    SELECT
        strftime('%Y-%m', order_date) AS month,
        COUNT(*) AS orders,
        SUM(total_amount) AS revenue
    FROM orders
    WHERE status = 'Completed'
    GROUP BY strftime('%Y-%m', order_date)
)
SELECT
    COALESCE(mc.month, mo.month) AS month,
    COALESCE(mo.orders, 0) AS orders,
    ROUND(COALESCE(mo.revenue, 0), 2) AS revenue,
    ROUND(COALESCE(mc.expenses, 0), 2) AS expenses,
    ROUND(COALESCE(mc.expenses, 0) / NULLIF(mo.orders, 0), 2) AS cost_per_order,
    ROUND(COALESCE(mc.expenses, 0) * 100.0 / NULLIF(mo.revenue, 0), 2) AS expense_ratio
FROM monthly_costs mc
FULL OUTER JOIN monthly_orders mo ON mc.month = mo.month
ORDER BY month DESC
LIMIT 12;

-- Payroll costs by department
SELECT
    department,
    COUNT(*) AS employees,
    ROUND(SUM(salary), 2) AS monthly_payroll,
    ROUND(SUM(salary) * 12, 2) AS annual_payroll,
    ROUND(AVG(salary), 2) AS avg_salary,
    ROUND(SUM(salary) * 100.0 / (SELECT SUM(salary) FROM employees WHERE status = 'Active'), 2) AS pct_of_payroll
FROM employees
WHERE status = 'Active'
GROUP BY department
ORDER BY monthly_payroll DESC;

-- Total operational cost summary
SELECT 'Payroll (Monthly)' AS cost_type,
    ROUND(SUM(salary), 2) AS amount
FROM employees WHERE status = 'Active'

UNION ALL

SELECT 'Operating Expenses (Monthly Avg)' AS cost_type,
    ROUND(AVG(monthly_total), 2) AS amount
FROM (
    SELECT SUM(amount) AS monthly_total
    FROM expenses
    WHERE status IN ('Approved', 'Paid')
    GROUP BY strftime('%Y-%m', expense_date)
)

UNION ALL

SELECT 'Inventory Holding Cost (Est.)' AS cost_type,
    ROUND(SUM(stock_quantity * unit_cost) * 0.02, 2) AS amount  -- 2% monthly holding cost
FROM products WHERE is_active = 1;

-- Cost trend analysis
SELECT
    strftime('%Y-%m', expense_date) AS month,
    category,
    ROUND(SUM(amount), 2) AS total,
    LAG(ROUND(SUM(amount), 2)) OVER (PARTITION BY category ORDER BY strftime('%Y-%m', expense_date)) AS prev_month,
    ROUND(
        (SUM(amount) - LAG(SUM(amount)) OVER (PARTITION BY category ORDER BY strftime('%Y-%m', expense_date))) * 100.0 /
        NULLIF(LAG(SUM(amount)) OVER (PARTITION BY category ORDER BY strftime('%Y-%m', expense_date)), 0), 2
    ) AS mom_change_pct
FROM expenses
WHERE status IN ('Approved', 'Paid')
GROUP BY strftime('%Y-%m', expense_date), category
ORDER BY month DESC, category;

-- High-value expenses requiring review
SELECT
    expense_id,
    department,
    category,
    description,
    amount,
    expense_date,
    status,
    CASE
        WHEN amount > 5000 THEN 'High Value'
        WHEN amount > 2000 THEN 'Medium Value'
        ELSE 'Standard'
    END AS expense_tier
FROM expenses
WHERE status IN ('Pending', 'Approved')
    AND amount > 1000
ORDER BY amount DESC;

-- Cost efficiency by employee (Sales)
SELECT
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee,
    e.salary AS monthly_salary,
    COUNT(o.order_id) AS orders_generated,
    ROUND(SUM(o.total_amount), 2) AS revenue_generated,
    ROUND(SUM(o.total_amount) / e.salary, 2) AS revenue_to_salary_ratio,
    CASE
        WHEN SUM(o.total_amount) / e.salary >= 10 THEN 'High Performer'
        WHEN SUM(o.total_amount) / e.salary >= 5 THEN 'On Target'
        ELSE 'Below Target'
    END AS performance_tier
FROM employees e
LEFT JOIN orders o ON e.employee_id = o.employee_id AND o.status = 'Completed'
WHERE e.department = 'Sales'
    AND e.status = 'Active'
GROUP BY e.employee_id, e.first_name, e.last_name, e.salary
ORDER BY revenue_to_salary_ratio DESC;

-- Budget utilization
SELECT
    b.department,
    b.category,
    b.fiscal_year,
    b.budget_amount,
    COALESCE(SUM(e.amount), 0) AS spent,
    b.budget_amount - COALESCE(SUM(e.amount), 0) AS remaining,
    ROUND(COALESCE(SUM(e.amount), 0) * 100.0 / b.budget_amount, 2) AS utilization_pct
FROM budget b
LEFT JOIN expenses e ON b.department = e.department
    AND b.category = e.category
    AND strftime('%Y', e.expense_date) = CAST(b.fiscal_year AS TEXT)
    AND e.status IN ('Approved', 'Paid')
GROUP BY b.department, b.category, b.fiscal_year, b.budget_amount
ORDER BY b.fiscal_year DESC, utilization_pct DESC;
