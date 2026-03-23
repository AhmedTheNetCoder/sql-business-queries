-- =============================================
-- Query: Cost Center Analysis
-- Category: Finance Analytics
-- Difficulty: Intermediate
--
-- Business Question:
-- How are costs distributed across departments (cost centers)?
-- Which departments drive the most operational costs?
--
-- Use Case:
-- Cost allocation, internal charge-backs, profitability
-- by department, and resource optimization.
-- =============================================

-- Cost center summary (Department as cost center)
SELECT
    department AS cost_center,
    'Payroll' AS cost_type,
    ROUND(SUM(salary), 2) AS monthly_cost,
    ROUND(SUM(salary) * 12, 2) AS annual_cost,
    COUNT(*) AS headcount,
    ROUND(SUM(salary) * 100.0 / (SELECT SUM(salary) FROM employees WHERE status = 'Active'), 2) AS cost_share
FROM employees
WHERE status = 'Active'
GROUP BY department

UNION ALL

SELECT
    department AS cost_center,
    'Expenses' AS cost_type,
    ROUND(SUM(amount), 2) AS monthly_cost,
    ROUND(SUM(amount) * 12 / COUNT(DISTINCT strftime('%Y-%m', expense_date)), 2) AS annual_cost,
    COUNT(*) AS transaction_count,
    ROUND(SUM(amount) * 100.0 / (SELECT SUM(amount) FROM expenses WHERE status IN ('Approved', 'Paid')), 2) AS cost_share
FROM expenses
WHERE status IN ('Approved', 'Paid')
GROUP BY department

ORDER BY cost_center, cost_type;

-- =============================================
-- Expected Output:
-- | cost_center  | cost_type | monthly_cost | annual_cost | headcount | cost_share |
-- |--------------|-----------|--------------|-------------|-----------|------------|
-- | Sales        | Payroll   | 12,500.00    | 150,000.00  | 5         | 17.24      |
-- | Sales        | Expenses  | 2,500.00     | 30,000.00   | 15        | 12.50      |
-- =============================================

-- Total cost by department
WITH payroll_costs AS (
    SELECT
        department,
        SUM(salary) AS payroll
    FROM employees
    WHERE status = 'Active'
    GROUP BY department
),
expense_costs AS (
    SELECT
        department,
        SUM(amount) / COUNT(DISTINCT strftime('%Y-%m', expense_date)) AS avg_monthly_expense
    FROM expenses
    WHERE status IN ('Approved', 'Paid')
    GROUP BY department
)
SELECT
    COALESCE(p.department, e.department) AS department,
    ROUND(COALESCE(p.payroll, 0), 2) AS monthly_payroll,
    ROUND(COALESCE(e.avg_monthly_expense, 0), 2) AS monthly_expenses,
    ROUND(COALESCE(p.payroll, 0) + COALESCE(e.avg_monthly_expense, 0), 2) AS total_monthly_cost,
    ROUND((COALESCE(p.payroll, 0) + COALESCE(e.avg_monthly_expense, 0)) * 12, 2) AS annual_cost
FROM payroll_costs p
FULL OUTER JOIN expense_costs e ON p.department = e.department
ORDER BY total_monthly_cost DESC;

-- Cost per employee by department
SELECT
    e.department,
    COUNT(*) AS headcount,
    ROUND(SUM(e.salary), 2) AS total_payroll,
    ROUND(COALESCE(SUM(exp.dept_expenses) / COUNT(DISTINCT e.employee_id), 0), 2) AS expenses_per_employee,
    ROUND(SUM(e.salary) / COUNT(*) + COALESCE(SUM(exp.dept_expenses) / COUNT(*), 0), 2) AS cost_per_employee
FROM employees e
LEFT JOIN (
    SELECT department, SUM(amount) AS dept_expenses
    FROM expenses
    WHERE status IN ('Approved', 'Paid')
    GROUP BY department
) exp ON e.department = exp.department
WHERE e.status = 'Active'
GROUP BY e.department
ORDER BY cost_per_employee DESC;

-- Cost breakdown by category within each department
SELECT
    department,
    category,
    COUNT(*) AS transactions,
    ROUND(SUM(amount), 2) AS total_amount,
    ROUND(AVG(amount), 2) AS avg_amount
FROM expenses
WHERE status IN ('Approved', 'Paid')
GROUP BY department, category
ORDER BY department, total_amount DESC;

-- Month-over-month cost trend by department
SELECT
    department,
    strftime('%Y-%m', expense_date) AS month,
    ROUND(SUM(amount), 2) AS total_expenses
FROM expenses
WHERE status IN ('Approved', 'Paid')
GROUP BY department, strftime('%Y-%m', expense_date)
ORDER BY department, month DESC;

-- Revenue-generating vs support departments
WITH dept_revenue AS (
    SELECT
        e.department,
        SUM(o.total_amount) AS revenue_generated
    FROM employees e
    LEFT JOIN orders o ON e.employee_id = o.employee_id AND o.status = 'Completed'
    GROUP BY e.department
),
dept_costs AS (
    SELECT
        department,
        SUM(salary) AS payroll_cost
    FROM employees
    WHERE status = 'Active'
    GROUP BY department
)
SELECT
    dc.department,
    ROUND(dc.payroll_cost, 2) AS monthly_cost,
    ROUND(COALESCE(dr.revenue_generated, 0), 2) AS revenue_generated,
    CASE
        WHEN COALESCE(dr.revenue_generated, 0) > 0
        THEN ROUND(dr.revenue_generated / dc.payroll_cost, 2)
        ELSE 0
    END AS revenue_to_cost_ratio,
    CASE
        WHEN COALESCE(dr.revenue_generated, 0) > 0 THEN 'Revenue Center'
        ELSE 'Cost Center'
    END AS department_type
FROM dept_costs dc
LEFT JOIN dept_revenue dr ON dc.department = dr.department
ORDER BY revenue_to_cost_ratio DESC;
