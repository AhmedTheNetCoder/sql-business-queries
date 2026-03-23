-- =============================================
-- Query: Department Distribution Analysis
-- Category: HR Analytics
-- Difficulty: Beginner
--
-- Business Question:
-- How are employees distributed across departments?
-- Which departments are largest/smallest?
--
-- Use Case:
-- Organizational planning, resource allocation,
-- and restructuring decisions.
-- =============================================

-- Department overview
SELECT
    department,
    COUNT(*) AS headcount,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM employees WHERE status = 'Active'), 2) AS percent_of_total,
    MIN(hire_date) AS earliest_hire,
    MAX(hire_date) AS latest_hire,
    ROUND(AVG(JULIANDAY('now') - JULIANDAY(hire_date)) / 365, 1) AS avg_tenure_years
FROM employees
WHERE status = 'Active'
GROUP BY department
ORDER BY headcount DESC;

-- =============================================
-- Expected Output:
-- | department       | headcount | percent_of_total | avg_tenure_years |
-- |------------------|-----------|------------------|------------------|
-- | Sales            | 5         | 25.00            | 3.2              |
-- | Operations       | 4         | 20.00            | 3.8              |
-- | Finance          | 3         | 15.00            | 4.1              |
-- =============================================

-- Department hierarchy (with managers)
SELECT
    d.department,
    d.headcount,
    m.first_name || ' ' || m.last_name AS department_head,
    m.job_title,
    ROUND(d.total_salary, 2) AS total_salary_cost,
    ROUND(d.total_salary / d.headcount, 2) AS avg_salary
FROM (
    SELECT
        department,
        COUNT(*) AS headcount,
        SUM(salary) AS total_salary
    FROM employees
    WHERE status = 'Active'
    GROUP BY department
) d
LEFT JOIN employees m ON d.department = m.department
    AND m.manager_id = (SELECT employee_id FROM employees WHERE manager_id IS NULL)
    AND m.status = 'Active'
ORDER BY d.headcount DESC;

-- Department salary comparison
SELECT
    department,
    COUNT(*) AS employees,
    ROUND(MIN(salary), 2) AS min_salary,
    ROUND(AVG(salary), 2) AS avg_salary,
    ROUND(MAX(salary), 2) AS max_salary,
    ROUND(MAX(salary) - MIN(salary), 2) AS salary_range,
    ROUND(SUM(salary), 2) AS total_payroll
FROM employees
WHERE status = 'Active'
GROUP BY department
ORDER BY avg_salary DESC;

-- Department gender diversity
SELECT
    department,
    COUNT(*) AS total,
    COUNT(CASE WHEN gender = 'Male' THEN 1 END) AS male,
    COUNT(CASE WHEN gender = 'Female' THEN 1 END) AS female,
    ROUND(COUNT(CASE WHEN gender = 'Female' THEN 1 END) * 100.0 / COUNT(*), 1) AS female_percent,
    CASE
        WHEN COUNT(CASE WHEN gender = 'Female' THEN 1 END) * 100.0 / COUNT(*) >= 40 THEN 'Balanced'
        WHEN COUNT(CASE WHEN gender = 'Female' THEN 1 END) * 100.0 / COUNT(*) >= 25 THEN 'Moderate'
        ELSE 'Low Diversity'
    END AS diversity_status
FROM employees
WHERE status = 'Active'
GROUP BY department
ORDER BY female_percent DESC;

-- Department growth over time
SELECT
    department,
    strftime('%Y', hire_date) AS year,
    COUNT(*) AS hires
FROM employees
GROUP BY department, strftime('%Y', hire_date)
ORDER BY department, year;
