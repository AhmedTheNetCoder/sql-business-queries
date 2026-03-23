-- =============================================
-- Query: Department Cost Analysis
-- Category: HR Analytics
-- Difficulty: Intermediate
--
-- Business Question:
-- What is the total cost of each department? How does
-- headcount relate to salary expenses?
--
-- Use Case:
-- Budget planning, cost optimization, organizational
-- restructuring, and financial reporting.
-- =============================================

-- Department cost overview
SELECT
    department,
    COUNT(*) AS headcount,
    ROUND(SUM(salary), 2) AS monthly_payroll,
    ROUND(SUM(salary) * 12, 2) AS annual_payroll,
    ROUND(AVG(salary), 2) AS avg_salary,
    ROUND(SUM(salary) * 100.0 / (SELECT SUM(salary) FROM employees WHERE status = 'Active'), 2) AS payroll_percent
FROM employees
WHERE status = 'Active'
GROUP BY department
ORDER BY monthly_payroll DESC;

-- =============================================
-- Expected Output:
-- | department       | headcount | monthly_payroll | annual_payroll | avg_salary | payroll_percent |
-- |------------------|-----------|-----------------|----------------|------------|-----------------|
-- | Executive        | 1         | 8,500.00        | 102,000.00     | 8,500.00   | 11.72           |
-- | Sales            | 5         | 12,500.00       | 150,000.00     | 2,500.00   | 17.24           |
-- =============================================

-- Cost per employee by department
SELECT
    department,
    COUNT(*) AS headcount,
    ROUND(SUM(salary), 2) AS total_payroll,
    ROUND(AVG(salary), 2) AS avg_salary_per_employee,
    -- Assuming 20% overhead (benefits, equipment, etc.)
    ROUND(SUM(salary) * 1.2, 2) AS total_cost_with_overhead,
    ROUND(SUM(salary) * 1.2 / COUNT(*), 2) AS cost_per_employee
FROM employees
WHERE status = 'Active'
GROUP BY department
ORDER BY cost_per_employee DESC;

-- Department cost vs revenue contribution (for sales)
WITH dept_costs AS (
    SELECT
        department,
        SUM(salary) AS monthly_cost
    FROM employees
    WHERE status = 'Active'
    GROUP BY department
),
sales_revenue AS (
    SELECT
        e.department,
        SUM(o.total_amount) AS total_revenue
    FROM employees e
    INNER JOIN orders o ON e.employee_id = o.employee_id
    WHERE o.status = 'Completed'
    GROUP BY e.department
)
SELECT
    dc.department,
    ROUND(dc.monthly_cost, 2) AS monthly_cost,
    ROUND(COALESCE(sr.total_revenue, 0), 2) AS revenue_generated,
    ROUND(COALESCE(sr.total_revenue, 0) / dc.monthly_cost, 2) AS revenue_per_cost_dollar,
    CASE
        WHEN sr.total_revenue IS NOT NULL
        THEN ROUND(sr.total_revenue / dc.monthly_cost, 1) || 'x return'
        ELSE 'Support function'
    END AS roi_assessment
FROM dept_costs dc
LEFT JOIN sales_revenue sr ON dc.department = sr.department
ORDER BY revenue_per_cost_dollar DESC NULLS LAST;

-- Cost breakdown by job level
SELECT
    department,
    CASE
        WHEN job_title LIKE '%Director%' OR job_title LIKE '%Manager%' OR job_title LIKE '%CEO%' OR job_title LIKE '%CFO%'
        THEN 'Leadership'
        WHEN job_title LIKE '%Senior%' OR job_title LIKE '%Supervisor%'
        THEN 'Senior'
        ELSE 'Staff'
    END AS level,
    COUNT(*) AS headcount,
    ROUND(SUM(salary), 2) AS level_payroll,
    ROUND(AVG(salary), 2) AS avg_salary
FROM employees
WHERE status = 'Active'
GROUP BY department, level
ORDER BY department, avg_salary DESC;

-- Year-over-year cost comparison (by hire date cohorts)
SELECT
    strftime('%Y', hire_date) AS hire_year,
    COUNT(*) AS employees_hired,
    COUNT(CASE WHEN status = 'Active' THEN 1 END) AS still_active,
    ROUND(SUM(CASE WHEN status = 'Active' THEN salary ELSE 0 END), 2) AS current_payroll,
    ROUND(AVG(CASE WHEN status = 'Active' THEN salary END), 2) AS avg_current_salary
FROM employees
GROUP BY strftime('%Y', hire_date)
ORDER BY hire_year DESC;

-- Commission cost analysis (for sales roles)
SELECT
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    e.department,
    e.salary AS base_salary,
    e.commission_rate,
    COALESCE(SUM(o.total_amount), 0) AS sales_generated,
    ROUND(COALESCE(SUM(o.total_amount), 0) * e.commission_rate, 2) AS commission_earned,
    ROUND(e.salary + COALESCE(SUM(o.total_amount), 0) * e.commission_rate, 2) AS total_compensation
FROM employees e
LEFT JOIN orders o ON e.employee_id = o.employee_id AND o.status = 'Completed'
WHERE e.status = 'Active'
    AND e.commission_rate > 0
GROUP BY e.employee_id, employee_name, e.department, e.salary, e.commission_rate
ORDER BY total_compensation DESC;

-- Budget variance by department
SELECT
    b.department,
    b.category,
    ROUND(SUM(b.budgeted_amount), 2) AS total_budgeted,
    ROUND(SUM(b.actual_amount), 2) AS total_actual,
    ROUND(SUM(b.budgeted_amount) - SUM(b.actual_amount), 2) AS variance,
    ROUND((SUM(b.actual_amount) / SUM(b.budgeted_amount)) * 100, 2) AS utilization_percent,
    CASE
        WHEN SUM(b.actual_amount) > SUM(b.budgeted_amount) THEN 'Over Budget'
        WHEN SUM(b.actual_amount) >= SUM(b.budgeted_amount) * 0.9 THEN 'On Track'
        ELSE 'Under Budget'
    END AS status
FROM budget b
WHERE b.category = 'Salaries'
GROUP BY b.department, b.category
ORDER BY variance;
