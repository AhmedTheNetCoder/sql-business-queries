-- =============================================
-- Query: Promotion Rate Analysis
-- Category: HR Analytics
-- Difficulty: Intermediate
--
-- Business Question:
-- What is the internal promotion rate? How long does
-- it take for employees to get promoted?
--
-- Use Case:
-- Career development planning, succession planning,
-- and employee engagement analysis.
--
-- Note: This query simulates promotion data based on
-- job titles and salary progression since we don't have
-- a dedicated promotions table.
-- =============================================

-- Identify management/senior positions (potential promotions)
SELECT
    job_title,
    COUNT(*) AS employee_count,
    ROUND(AVG(salary), 2) AS avg_salary,
    ROUND(AVG((JULIANDAY('now') - JULIANDAY(hire_date)) / 365), 1) AS avg_tenure,
    CASE
        WHEN job_title LIKE '%Director%' OR job_title LIKE '%Manager%' OR job_title LIKE '%CEO%' OR job_title LIKE '%CFO%'
        THEN 'Leadership'
        WHEN job_title LIKE '%Senior%' OR job_title LIKE '%Supervisor%'
        THEN 'Senior'
        ELSE 'Staff'
    END AS level
FROM employees
WHERE status = 'Active'
GROUP BY job_title
ORDER BY avg_salary DESC;

-- =============================================
-- Expected Output:
-- | job_title           | employee_count | avg_salary | level      |
-- |---------------------|----------------|------------|------------|
-- | CEO                 | 1              | 8,500.00   | Leadership |
-- | CFO                 | 1              | 7,000.00   | Leadership |
-- | Sales Director      | 1              | 6,500.00   | Leadership |
-- =============================================

-- Employee level distribution
SELECT
    CASE
        WHEN job_title LIKE '%Director%' OR job_title LIKE '%Manager%' OR job_title LIKE '%CEO%' OR job_title LIKE '%CFO%'
        THEN 'Leadership'
        WHEN job_title LIKE '%Senior%' OR job_title LIKE '%Supervisor%'
        THEN 'Senior'
        WHEN job_title LIKE '%Junior%' OR job_title LIKE '%Coordinator%'
        THEN 'Junior'
        ELSE 'Mid-Level'
    END AS level,
    COUNT(*) AS employee_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM employees WHERE status = 'Active'), 2) AS percentage,
    ROUND(AVG(salary), 2) AS avg_salary,
    ROUND(AVG((JULIANDAY('now') - JULIANDAY(hire_date)) / 365), 1) AS avg_tenure_years
FROM employees
WHERE status = 'Active'
GROUP BY level
ORDER BY avg_salary DESC;

-- Tenure required for each level
SELECT
    CASE
        WHEN job_title LIKE '%Director%' OR job_title LIKE '%Manager%' OR job_title LIKE '%CEO%' OR job_title LIKE '%CFO%'
        THEN 'Leadership'
        WHEN job_title LIKE '%Senior%' OR job_title LIKE '%Supervisor%'
        THEN 'Senior'
        WHEN job_title LIKE '%Junior%' OR job_title LIKE '%Coordinator%'
        THEN 'Junior'
        ELSE 'Mid-Level'
    END AS level,
    ROUND(MIN((JULIANDAY('now') - JULIANDAY(hire_date)) / 365), 1) AS min_tenure,
    ROUND(AVG((JULIANDAY('now') - JULIANDAY(hire_date)) / 365), 1) AS avg_tenure,
    ROUND(MAX((JULIANDAY('now') - JULIANDAY(hire_date)) / 365), 1) AS max_tenure
FROM employees
WHERE status = 'Active'
GROUP BY level
ORDER BY avg_tenure DESC;

-- Promotion readiness (staff with 2+ years, potential for senior roles)
SELECT
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    e.department,
    e.job_title,
    ROUND((JULIANDAY('now') - JULIANDAY(e.hire_date)) / 365, 1) AS tenure_years,
    e.salary,
    m.first_name || ' ' || m.last_name AS manager_name,
    CASE
        WHEN (JULIANDAY('now') - JULIANDAY(e.hire_date)) / 365 >= 3
             AND e.job_title NOT LIKE '%Senior%'
             AND e.job_title NOT LIKE '%Manager%'
             AND e.job_title NOT LIKE '%Director%'
        THEN 'Ready for Promotion'
        WHEN (JULIANDAY('now') - JULIANDAY(e.hire_date)) / 365 >= 2
        THEN 'Monitor for Promotion'
        ELSE 'Developing'
    END AS promotion_readiness
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id
WHERE e.status = 'Active'
    AND e.job_title NOT LIKE '%CEO%'
    AND e.job_title NOT LIKE '%CFO%'
    AND e.job_title NOT LIKE '%Director%'
ORDER BY tenure_years DESC;

-- Department promotion pipeline
SELECT
    department,
    COUNT(*) AS total_staff,
    COUNT(CASE
        WHEN job_title LIKE '%Senior%' OR job_title LIKE '%Manager%' OR job_title LIKE '%Director%'
        THEN 1 END) AS senior_roles,
    COUNT(CASE
        WHEN job_title NOT LIKE '%Senior%'
             AND job_title NOT LIKE '%Manager%'
             AND job_title NOT LIKE '%Director%'
             AND (JULIANDAY('now') - JULIANDAY(hire_date)) / 365 >= 2
        THEN 1 END) AS promotion_candidates,
    ROUND(COUNT(CASE
        WHEN job_title LIKE '%Senior%' OR job_title LIKE '%Manager%' OR job_title LIKE '%Director%'
        THEN 1 END) * 100.0 / COUNT(*), 2) AS senior_ratio_percent
FROM employees
WHERE status = 'Active'
GROUP BY department
ORDER BY promotion_candidates DESC;
