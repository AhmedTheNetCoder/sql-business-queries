-- =============================================
-- Query: Employee Headcount Analysis
-- Category: HR Analytics
-- Difficulty: Beginner
--
-- Business Question:
-- What is our current employee count? How is headcount
-- distributed across departments and locations?
--
-- Use Case:
-- HR planning, budgeting, organizational design, and
-- compliance reporting.
-- =============================================

-- Current active headcount
SELECT
    COUNT(*) AS total_employees,
    COUNT(CASE WHEN status = 'Active' THEN 1 END) AS active_employees,
    COUNT(CASE WHEN status = 'On Leave' THEN 1 END) AS on_leave,
    COUNT(CASE WHEN status = 'Terminated' THEN 1 END) AS terminated
FROM employees;

-- =============================================
-- Expected Output:
-- | total_employees | active_employees | on_leave | terminated |
-- |-----------------|------------------|----------|------------|
-- | 23              | 20               | 0        | 3          |
-- =============================================

-- Headcount by department
SELECT
    department,
    COUNT(*) AS total_employees,
    COUNT(CASE WHEN status = 'Active' THEN 1 END) AS active,
    COUNT(CASE WHEN gender = 'Male' THEN 1 END) AS male,
    COUNT(CASE WHEN gender = 'Female' THEN 1 END) AS female,
    ROUND(COUNT(CASE WHEN gender = 'Female' THEN 1 END) * 100.0 / COUNT(*), 2) AS female_percent,
    ROUND(AVG(salary), 2) AS avg_salary
FROM employees
WHERE status = 'Active'
GROUP BY department
ORDER BY total_employees DESC;

-- Headcount by location
SELECT
    city,
    COUNT(*) AS employees,
    COUNT(DISTINCT department) AS departments_present,
    ROUND(AVG(salary), 2) AS avg_salary
FROM employees
WHERE status = 'Active'
GROUP BY city
ORDER BY employees DESC;

-- Headcount trend (hires over time)
SELECT
    strftime('%Y', hire_date) AS year,
    COUNT(*) AS hires,
    COUNT(CASE WHEN status = 'Terminated' THEN 1 END) AS now_terminated,
    COUNT(CASE WHEN status = 'Active' THEN 1 END) AS still_active
FROM employees
GROUP BY strftime('%Y', hire_date)
ORDER BY year DESC;

-- Manager span of control
SELECT
    m.employee_id AS manager_id,
    m.first_name || ' ' || m.last_name AS manager_name,
    m.department,
    m.job_title,
    COUNT(e.employee_id) AS direct_reports,
    ROUND(AVG(e.salary), 2) AS avg_team_salary
FROM employees m
LEFT JOIN employees e ON m.employee_id = e.manager_id AND e.status = 'Active'
WHERE m.status = 'Active'
GROUP BY m.employee_id, manager_name, m.department, m.job_title
HAVING direct_reports > 0
ORDER BY direct_reports DESC;
