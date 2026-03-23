-- =============================================
-- Query: Employee Age Distribution Analysis
-- Category: HR Analytics
-- Difficulty: Beginner
--
-- Business Question:
-- What is the age distribution of our workforce?
-- Do we have succession planning concerns?
--
-- Use Case:
-- Succession planning, benefits planning, diversity
-- analysis, and retirement forecasting.
-- =============================================

-- Overall age statistics
SELECT
    COUNT(*) AS total_employees,
    ROUND(AVG((JULIANDAY('now') - JULIANDAY(birth_date)) / 365), 1) AS avg_age,
    ROUND(MIN((JULIANDAY('now') - JULIANDAY(birth_date)) / 365), 1) AS youngest,
    ROUND(MAX((JULIANDAY('now') - JULIANDAY(birth_date)) / 365), 1) AS oldest,
    ROUND(MAX((JULIANDAY('now') - JULIANDAY(birth_date)) / 365) -
          MIN((JULIANDAY('now') - JULIANDAY(birth_date)) / 365), 1) AS age_range
FROM employees
WHERE status = 'Active'
    AND birth_date IS NOT NULL;

-- =============================================
-- Expected Output:
-- | total_employees | avg_age | youngest | oldest | age_range |
-- |-----------------|---------|----------|--------|-----------|
-- | 20              | 35.8    | 28       | 49     | 21        |
-- =============================================

-- Age distribution by generation
SELECT
    CASE
        WHEN (JULIANDAY('now') - JULIANDAY(birth_date)) / 365 < 28 THEN 'Gen Z (< 28)'
        WHEN (JULIANDAY('now') - JULIANDAY(birth_date)) / 365 < 44 THEN 'Millennial (28-43)'
        WHEN (JULIANDAY('now') - JULIANDAY(birth_date)) / 365 < 60 THEN 'Gen X (44-59)'
        ELSE 'Boomer (60+)'
    END AS generation,
    COUNT(*) AS employee_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM employees WHERE status = 'Active'), 2) AS percentage,
    ROUND(AVG(salary), 2) AS avg_salary,
    ROUND(AVG((JULIANDAY('now') - JULIANDAY(hire_date)) / 365), 1) AS avg_tenure
FROM employees
WHERE status = 'Active'
    AND birth_date IS NOT NULL
GROUP BY generation
ORDER BY MIN((JULIANDAY('now') - JULIANDAY(birth_date)) / 365);

-- Age by department
SELECT
    department,
    COUNT(*) AS employees,
    ROUND(AVG((JULIANDAY('now') - JULIANDAY(birth_date)) / 365), 1) AS avg_age,
    ROUND(MIN((JULIANDAY('now') - JULIANDAY(birth_date)) / 365), 1) AS youngest,
    ROUND(MAX((JULIANDAY('now') - JULIANDAY(birth_date)) / 365), 1) AS oldest
FROM employees
WHERE status = 'Active'
    AND birth_date IS NOT NULL
GROUP BY department
ORDER BY avg_age DESC;

-- Age bands distribution
SELECT
    CASE
        WHEN (JULIANDAY('now') - JULIANDAY(birth_date)) / 365 < 25 THEN '< 25'
        WHEN (JULIANDAY('now') - JULIANDAY(birth_date)) / 365 < 30 THEN '25-29'
        WHEN (JULIANDAY('now') - JULIANDAY(birth_date)) / 365 < 35 THEN '30-34'
        WHEN (JULIANDAY('now') - JULIANDAY(birth_date)) / 365 < 40 THEN '35-39'
        WHEN (JULIANDAY('now') - JULIANDAY(birth_date)) / 365 < 45 THEN '40-44'
        WHEN (JULIANDAY('now') - JULIANDAY(birth_date)) / 365 < 50 THEN '45-49'
        ELSE '50+'
    END AS age_band,
    COUNT(*) AS employee_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM employees WHERE status = 'Active'), 2) AS percentage
FROM employees
WHERE status = 'Active'
    AND birth_date IS NOT NULL
GROUP BY age_band
ORDER BY MIN((JULIANDAY('now') - JULIANDAY(birth_date)) / 365);

-- Approaching retirement (within 10 years of 60)
SELECT
    employee_id,
    first_name || ' ' || last_name AS employee_name,
    department,
    job_title,
    ROUND((JULIANDAY('now') - JULIANDAY(birth_date)) / 365, 0) AS current_age,
    60 - ROUND((JULIANDAY('now') - JULIANDAY(birth_date)) / 365, 0) AS years_to_retirement,
    ROUND((JULIANDAY('now') - JULIANDAY(hire_date)) / 365, 1) AS tenure_years
FROM employees
WHERE status = 'Active'
    AND birth_date IS NOT NULL
    AND (JULIANDAY('now') - JULIANDAY(birth_date)) / 365 >= 50
ORDER BY years_to_retirement;

-- Age vs salary analysis
SELECT
    CASE
        WHEN (JULIANDAY('now') - JULIANDAY(birth_date)) / 365 < 30 THEN '< 30'
        WHEN (JULIANDAY('now') - JULIANDAY(birth_date)) / 365 < 40 THEN '30-39'
        WHEN (JULIANDAY('now') - JULIANDAY(birth_date)) / 365 < 50 THEN '40-49'
        ELSE '50+'
    END AS age_group,
    COUNT(*) AS employees,
    ROUND(AVG(salary), 2) AS avg_salary,
    ROUND(AVG((JULIANDAY('now') - JULIANDAY(hire_date)) / 365), 1) AS avg_tenure
FROM employees
WHERE status = 'Active'
    AND birth_date IS NOT NULL
GROUP BY age_group
ORDER BY MIN((JULIANDAY('now') - JULIANDAY(birth_date)) / 365);
