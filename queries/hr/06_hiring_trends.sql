-- =============================================
-- Query: Hiring Trends Analysis
-- Category: HR Analytics
-- Difficulty: Beginner
--
-- Business Question:
-- What are our hiring patterns over time? Which departments
-- are growing? How has hiring evolved?
--
-- Use Case:
-- Workforce planning, recruitment budgeting, and
-- organizational growth analysis.
-- =============================================

-- Hiring by year
SELECT
    strftime('%Y', hire_date) AS year,
    COUNT(*) AS total_hires,
    COUNT(CASE WHEN status = 'Active' THEN 1 END) AS still_active,
    COUNT(CASE WHEN status = 'Terminated' THEN 1 END) AS since_left,
    ROUND(COUNT(CASE WHEN status = 'Active' THEN 1 END) * 100.0 / COUNT(*), 2) AS retention_rate
FROM employees
GROUP BY strftime('%Y', hire_date)
ORDER BY year DESC;

-- =============================================
-- Expected Output:
-- | year | total_hires | still_active | since_left | retention_rate |
-- |------|-------------|--------------|------------|----------------|
-- | 2024 | 0           | 0            | 0          | 0.00           |
-- | 2023 | 0           | 0            | 0          | 0.00           |
-- | 2021 | 5           | 4            | 1          | 80.00          |
-- | 2020 | 8           | 7            | 1          | 87.50          |
-- =============================================

-- Hiring by department and year
SELECT
    department,
    SUM(CASE WHEN strftime('%Y', hire_date) = '2019' THEN 1 ELSE 0 END) AS hires_2019,
    SUM(CASE WHEN strftime('%Y', hire_date) = '2020' THEN 1 ELSE 0 END) AS hires_2020,
    SUM(CASE WHEN strftime('%Y', hire_date) = '2021' THEN 1 ELSE 0 END) AS hires_2021,
    COUNT(*) AS total_hires
FROM employees
GROUP BY department
ORDER BY total_hires DESC;

-- Monthly hiring pattern (which months do we hire most?)
SELECT
    CAST(strftime('%m', hire_date) AS INTEGER) AS month_number,
    CASE CAST(strftime('%m', hire_date) AS INTEGER)
        WHEN 1 THEN 'January' WHEN 2 THEN 'February' WHEN 3 THEN 'March'
        WHEN 4 THEN 'April' WHEN 5 THEN 'May' WHEN 6 THEN 'June'
        WHEN 7 THEN 'July' WHEN 8 THEN 'August' WHEN 9 THEN 'September'
        WHEN 10 THEN 'October' WHEN 11 THEN 'November' WHEN 12 THEN 'December'
    END AS month_name,
    COUNT(*) AS hires,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM employees), 2) AS percent_of_total
FROM employees
GROUP BY month_number, month_name
ORDER BY month_number;

-- Time to fill analysis (gap between hires in department)
WITH hire_gaps AS (
    SELECT
        department,
        hire_date,
        LAG(hire_date) OVER (PARTITION BY department ORDER BY hire_date) AS prev_hire_date,
        JULIANDAY(hire_date) - JULIANDAY(LAG(hire_date) OVER (PARTITION BY department ORDER BY hire_date)) AS days_between
    FROM employees
)
SELECT
    department,
    COUNT(*) AS hires,
    ROUND(AVG(days_between), 0) AS avg_days_between_hires,
    MIN(days_between) AS min_gap,
    MAX(days_between) AS max_gap
FROM hire_gaps
WHERE days_between IS NOT NULL
GROUP BY department
ORDER BY avg_days_between_hires;

-- New hire salary trends
SELECT
    strftime('%Y', hire_date) AS year,
    COUNT(*) AS hires,
    ROUND(AVG(salary), 2) AS avg_starting_salary,
    ROUND(MIN(salary), 2) AS min_starting_salary,
    ROUND(MAX(salary), 2) AS max_starting_salary
FROM employees
GROUP BY strftime('%Y', hire_date)
ORDER BY year DESC;

-- Recent hires (last 12 months)
SELECT
    employee_id,
    first_name || ' ' || last_name AS employee_name,
    department,
    job_title,
    hire_date,
    ROUND((JULIANDAY('now') - JULIANDAY(hire_date)) / 30, 0) AS months_employed,
    salary,
    status
FROM employees
WHERE hire_date >= DATE('now', '-12 months')
ORDER BY hire_date DESC;

-- Hiring diversity analysis
SELECT
    strftime('%Y', hire_date) AS year,
    COUNT(*) AS total_hires,
    COUNT(CASE WHEN gender = 'Male' THEN 1 END) AS male_hires,
    COUNT(CASE WHEN gender = 'Female' THEN 1 END) AS female_hires,
    ROUND(COUNT(CASE WHEN gender = 'Female' THEN 1 END) * 100.0 / COUNT(*), 2) AS female_hire_percent
FROM employees
GROUP BY strftime('%Y', hire_date)
ORDER BY year DESC;
