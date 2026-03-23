-- =============================================
-- Query: Employee Tenure Analysis
-- Category: HR Analytics
-- Difficulty: Beginner
--
-- Business Question:
-- How long do employees stay with the company?
-- Which departments have the longest/shortest tenure?
--
-- Use Case:
-- Retention analysis, succession planning, and
-- identifying flight risk patterns.
-- =============================================

-- Overall tenure statistics
SELECT
    COUNT(*) AS total_employees,
    ROUND(AVG(JULIANDAY('now') - JULIANDAY(hire_date)) / 365, 2) AS avg_tenure_years,
    ROUND(MIN(JULIANDAY('now') - JULIANDAY(hire_date)) / 365, 2) AS min_tenure_years,
    ROUND(MAX(JULIANDAY('now') - JULIANDAY(hire_date)) / 365, 2) AS max_tenure_years,
    ROUND(AVG(JULIANDAY('now') - JULIANDAY(hire_date)) / 30, 0) AS avg_tenure_months
FROM employees
WHERE status = 'Active';

-- =============================================
-- Expected Output:
-- | total_employees | avg_tenure_years | min_tenure_years | max_tenure_years |
-- |-----------------|------------------|------------------|------------------|
-- | 20              | 3.45             | 0.75             | 6.20             |
-- =============================================

-- Tenure by department
SELECT
    department,
    COUNT(*) AS employees,
    ROUND(AVG(JULIANDAY('now') - JULIANDAY(hire_date)) / 365, 2) AS avg_tenure_years,
    ROUND(MIN(JULIANDAY('now') - JULIANDAY(hire_date)) / 365, 2) AS min_tenure,
    ROUND(MAX(JULIANDAY('now') - JULIANDAY(hire_date)) / 365, 2) AS max_tenure
FROM employees
WHERE status = 'Active'
GROUP BY department
ORDER BY avg_tenure_years DESC;

-- Tenure distribution (buckets)
SELECT
    CASE
        WHEN (JULIANDAY('now') - JULIANDAY(hire_date)) / 365 < 1 THEN '< 1 year'
        WHEN (JULIANDAY('now') - JULIANDAY(hire_date)) / 365 < 2 THEN '1-2 years'
        WHEN (JULIANDAY('now') - JULIANDAY(hire_date)) / 365 < 3 THEN '2-3 years'
        WHEN (JULIANDAY('now') - JULIANDAY(hire_date)) / 365 < 5 THEN '3-5 years'
        ELSE '5+ years'
    END AS tenure_bucket,
    COUNT(*) AS employee_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM employees WHERE status = 'Active'), 2) AS percentage,
    ROUND(AVG(salary), 2) AS avg_salary
FROM employees
WHERE status = 'Active'
GROUP BY tenure_bucket
ORDER BY MIN(JULIANDAY('now') - JULIANDAY(hire_date));

-- Long-tenured employees (potential institutional knowledge holders)
SELECT
    employee_id,
    first_name || ' ' || last_name AS employee_name,
    department,
    job_title,
    hire_date,
    ROUND((JULIANDAY('now') - JULIANDAY(hire_date)) / 365, 1) AS tenure_years,
    salary
FROM employees
WHERE status = 'Active'
ORDER BY hire_date ASC
LIMIT 10;

-- New employees (< 1 year) who might need extra support
SELECT
    employee_id,
    first_name || ' ' || last_name AS employee_name,
    department,
    job_title,
    hire_date,
    ROUND((JULIANDAY('now') - JULIANDAY(hire_date)) / 30, 0) AS tenure_months,
    m.first_name || ' ' || m.last_name AS manager_name
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id
WHERE e.status = 'Active'
    AND (JULIANDAY('now') - JULIANDAY(e.hire_date)) / 365 < 1
ORDER BY e.hire_date DESC;

-- Tenure vs salary correlation
SELECT
    CASE
        WHEN (JULIANDAY('now') - JULIANDAY(hire_date)) / 365 < 2 THEN '0-2 years'
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
