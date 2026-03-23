-- =============================================
-- Query: Salary Analysis
-- Category: HR Analytics
-- Difficulty: Intermediate
--
-- Business Question:
-- How are salaries distributed across the organization?
-- Are there pay equity concerns? How do we compare to budget?
--
-- Use Case:
-- Compensation planning, pay equity audits, budget
-- management, and retention strategy.
-- =============================================

-- Overall salary statistics
SELECT
    COUNT(*) AS employee_count,
    ROUND(SUM(salary), 2) AS total_payroll,
    ROUND(AVG(salary), 2) AS avg_salary,
    ROUND(MIN(salary), 2) AS min_salary,
    ROUND(MAX(salary), 2) AS max_salary,
    ROUND(MAX(salary) - MIN(salary), 2) AS salary_range,
    ROUND(MAX(salary) / MIN(salary), 2) AS pay_ratio
FROM employees
WHERE status = 'Active';

-- =============================================
-- Expected Output:
-- | employee_count | total_payroll | avg_salary | min_salary | max_salary | pay_ratio |
-- |----------------|---------------|------------|------------|------------|-----------|
-- | 20             | 72,500.00     | 3,625.00   | 2,000.00   | 8,500.00   | 4.25      |
-- =============================================

-- Salary by department
SELECT
    department,
    COUNT(*) AS employees,
    ROUND(SUM(salary), 2) AS dept_payroll,
    ROUND(AVG(salary), 2) AS avg_salary,
    ROUND(MIN(salary), 2) AS min_salary,
    ROUND(MAX(salary), 2) AS max_salary,
    ROUND(SUM(salary) * 100.0 / (SELECT SUM(salary) FROM employees WHERE status = 'Active'), 2) AS payroll_percent
FROM employees
WHERE status = 'Active'
GROUP BY department
ORDER BY avg_salary DESC;

-- Salary distribution (bands)
SELECT
    CASE
        WHEN salary < 2500 THEN '< 2,500'
        WHEN salary < 3500 THEN '2,500 - 3,499'
        WHEN salary < 5000 THEN '3,500 - 4,999'
        WHEN salary < 7000 THEN '5,000 - 6,999'
        ELSE '7,000+'
    END AS salary_band,
    COUNT(*) AS employee_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM employees WHERE status = 'Active'), 2) AS percentage,
    ROUND(AVG(salary), 2) AS avg_in_band
FROM employees
WHERE status = 'Active'
GROUP BY salary_band
ORDER BY MIN(salary);

-- Gender pay equity analysis
SELECT
    gender,
    COUNT(*) AS count,
    ROUND(AVG(salary), 2) AS avg_salary,
    ROUND(MIN(salary), 2) AS min_salary,
    ROUND(MAX(salary), 2) AS max_salary
FROM employees
WHERE status = 'Active'
GROUP BY gender;

-- Gender pay gap by department
SELECT
    department,
    ROUND(AVG(CASE WHEN gender = 'Male' THEN salary END), 2) AS male_avg,
    ROUND(AVG(CASE WHEN gender = 'Female' THEN salary END), 2) AS female_avg,
    ROUND(
        (AVG(CASE WHEN gender = 'Male' THEN salary END) -
         AVG(CASE WHEN gender = 'Female' THEN salary END)) /
        AVG(CASE WHEN gender = 'Male' THEN salary END) * 100,
    2) AS pay_gap_percent
FROM employees
WHERE status = 'Active'
GROUP BY department
HAVING male_avg IS NOT NULL AND female_avg IS NOT NULL
ORDER BY pay_gap_percent DESC;

-- Salary vs tenure analysis
SELECT
    CASE
        WHEN (JULIANDAY('now') - JULIANDAY(hire_date)) / 365 < 1 THEN '< 1 year'
        WHEN (JULIANDAY('now') - JULIANDAY(hire_date)) / 365 < 2 THEN '1-2 years'
        WHEN (JULIANDAY('now') - JULIANDAY(hire_date)) / 365 < 4 THEN '2-4 years'
        ELSE '4+ years'
    END AS tenure_group,
    COUNT(*) AS employees,
    ROUND(AVG(salary), 2) AS avg_salary,
    ROUND(MIN(salary), 2) AS min_salary,
    ROUND(MAX(salary), 2) AS max_salary
FROM employees
WHERE status = 'Active'
GROUP BY tenure_group
ORDER BY MIN(JULIANDAY('now') - JULIANDAY(hire_date));

-- Highest paid employees
SELECT
    employee_id,
    first_name || ' ' || last_name AS employee_name,
    department,
    job_title,
    salary,
    ROUND((JULIANDAY('now') - JULIANDAY(hire_date)) / 365, 1) AS tenure_years,
    ROUND(salary / (SELECT AVG(salary) FROM employees WHERE status = 'Active'), 2) AS salary_vs_avg_ratio
FROM employees
WHERE status = 'Active'
ORDER BY salary DESC
LIMIT 10;

-- Salary outliers (significantly above or below average)
WITH dept_stats AS (
    SELECT
        department,
        AVG(salary) AS dept_avg,
        AVG(salary) * 0.7 AS lower_bound,
        AVG(salary) * 1.3 AS upper_bound
    FROM employees
    WHERE status = 'Active'
    GROUP BY department
)
SELECT
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    e.department,
    e.job_title,
    e.salary,
    ROUND(ds.dept_avg, 2) AS dept_avg_salary,
    CASE
        WHEN e.salary < ds.lower_bound THEN 'Below Range'
        WHEN e.salary > ds.upper_bound THEN 'Above Range'
        ELSE 'Within Range'
    END AS salary_status
FROM employees e
INNER JOIN dept_stats ds ON e.department = ds.department
WHERE e.status = 'Active'
    AND (e.salary < ds.lower_bound OR e.salary > ds.upper_bound)
ORDER BY e.department, e.salary;
