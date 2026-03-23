-- =============================================
-- Query: Employee Turnover Rate Analysis
-- Category: HR Analytics
-- Difficulty: Intermediate
--
-- Business Question:
-- What is our employee turnover rate? Which departments
-- have the highest attrition? What's the cost impact?
--
-- Use Case:
-- Retention strategy development, budget planning for
-- replacement costs, and identifying problem areas.
-- =============================================

-- Overall turnover rate
WITH turnover_stats AS (
    SELECT
        COUNT(CASE WHEN status = 'Terminated' THEN 1 END) AS terminations,
        COUNT(*) AS total_employees,
        COUNT(CASE WHEN status = 'Active' THEN 1 END) AS current_employees
    FROM employees
)
SELECT
    terminations,
    total_employees,
    current_employees,
    ROUND(terminations * 100.0 / total_employees, 2) AS overall_turnover_rate,
    -- Industry benchmark comparison (assuming 15% is average)
    CASE
        WHEN terminations * 100.0 / total_employees > 20 THEN 'High - Action Needed'
        WHEN terminations * 100.0 / total_employees > 15 THEN 'Above Average'
        WHEN terminations * 100.0 / total_employees > 10 THEN 'Average'
        ELSE 'Low - Healthy'
    END AS turnover_assessment
FROM turnover_stats;

-- =============================================
-- Expected Output:
-- | terminations | total_employees | turnover_rate | turnover_assessment |
-- |--------------|-----------------|---------------|---------------------|
-- | 3            | 23              | 13.04         | Average             |
-- =============================================

-- Turnover by department
SELECT
    department,
    COUNT(*) AS total_ever_employed,
    COUNT(CASE WHEN status = 'Active' THEN 1 END) AS current_active,
    COUNT(CASE WHEN status = 'Terminated' THEN 1 END) AS terminated,
    ROUND(COUNT(CASE WHEN status = 'Terminated' THEN 1 END) * 100.0 / COUNT(*), 2) AS turnover_rate,
    ROUND(AVG(CASE WHEN status = 'Terminated' THEN salary END), 2) AS avg_salary_of_leavers
FROM employees
GROUP BY department
ORDER BY turnover_rate DESC;

-- Turnover by tenure (when do people leave?)
SELECT
    CASE
        WHEN (JULIANDAY(termination_date) - JULIANDAY(hire_date)) / 365 < 1 THEN '< 1 year'
        WHEN (JULIANDAY(termination_date) - JULIANDAY(hire_date)) / 365 < 2 THEN '1-2 years'
        WHEN (JULIANDAY(termination_date) - JULIANDAY(hire_date)) / 365 < 3 THEN '2-3 years'
        ELSE '3+ years'
    END AS tenure_at_exit,
    COUNT(*) AS terminations,
    ROUND(AVG((JULIANDAY(termination_date) - JULIANDAY(hire_date)) / 30), 0) AS avg_months_employed
FROM employees
WHERE status = 'Terminated'
    AND termination_date IS NOT NULL
GROUP BY tenure_at_exit
ORDER BY MIN(JULIANDAY(termination_date) - JULIANDAY(hire_date));

-- Termination reasons analysis
SELECT
    termination_reason,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM employees WHERE status = 'Terminated'), 2) AS percentage,
    ROUND(AVG(salary), 2) AS avg_salary
FROM employees
WHERE status = 'Terminated'
GROUP BY termination_reason
ORDER BY count DESC;

-- Cost of turnover (estimated)
-- Assuming replacement cost = 50% of annual salary
SELECT
    department,
    COUNT(*) AS terminations,
    ROUND(SUM(salary), 2) AS total_salary_of_leavers,
    ROUND(SUM(salary) * 0.5, 2) AS estimated_replacement_cost,
    ROUND(AVG(JULIANDAY(termination_date) - JULIANDAY(hire_date)) / 365, 1) AS avg_tenure_years
FROM employees
WHERE status = 'Terminated'
GROUP BY department
ORDER BY estimated_replacement_cost DESC;

-- Monthly turnover trend
SELECT
    strftime('%Y-%m', termination_date) AS month,
    COUNT(*) AS terminations
FROM employees
WHERE status = 'Terminated'
    AND termination_date IS NOT NULL
GROUP BY strftime('%Y-%m', termination_date)
ORDER BY month DESC;

-- Flight risk indicators (patterns from those who left)
WITH leaver_profile AS (
    SELECT
        AVG((JULIANDAY(termination_date) - JULIANDAY(hire_date)) / 365) AS avg_tenure,
        AVG(salary) AS avg_salary,
        AVG(JULIANDAY('now') - JULIANDAY(birth_date)) / 365 AS avg_age
    FROM employees
    WHERE status = 'Terminated'
)
SELECT
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    e.department,
    ROUND((JULIANDAY('now') - JULIANDAY(e.hire_date)) / 365, 1) AS tenure_years,
    e.salary,
    CASE
        WHEN (JULIANDAY('now') - JULIANDAY(e.hire_date)) / 365 < (SELECT avg_tenure FROM leaver_profile)
             AND e.salary < (SELECT avg_salary FROM leaver_profile)
        THEN 'High Risk'
        WHEN (JULIANDAY('now') - JULIANDAY(e.hire_date)) / 365 < 2
        THEN 'Moderate Risk'
        ELSE 'Low Risk'
    END AS flight_risk
FROM employees e
WHERE e.status = 'Active'
ORDER BY flight_risk, tenure_years;
