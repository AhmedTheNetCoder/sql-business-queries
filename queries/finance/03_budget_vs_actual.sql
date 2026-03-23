-- =============================================
-- Query: Budget vs Actual Analysis
-- Category: Finance Analytics
-- Difficulty: Intermediate
--
-- Business Question:
-- How does our actual spending compare to budget?
-- Which departments are over or under budget?
--
-- Use Case:
-- Financial performance monitoring, variance analysis,
-- budget reforecasting, and accountability.
-- =============================================

-- Budget vs Actual by department
SELECT
    department,
    ROUND(SUM(budgeted_amount), 2) AS total_budget,
    ROUND(SUM(actual_amount), 2) AS total_actual,
    ROUND(SUM(budgeted_amount) - SUM(actual_amount), 2) AS variance,
    ROUND((SUM(actual_amount) / SUM(budgeted_amount)) * 100, 2) AS utilization_percent,
    CASE
        WHEN SUM(actual_amount) > SUM(budgeted_amount) * 1.1 THEN 'Significantly Over'
        WHEN SUM(actual_amount) > SUM(budgeted_amount) THEN 'Slightly Over'
        WHEN SUM(actual_amount) >= SUM(budgeted_amount) * 0.9 THEN 'On Track'
        ELSE 'Under Budget'
    END AS status
FROM budget
WHERE fiscal_year = CAST(strftime('%Y', 'now') AS INTEGER)
GROUP BY department
ORDER BY variance;

-- =============================================
-- Expected Output:
-- | department  | total_budget | total_actual | variance  | utilization_percent | status       |
-- |-------------|--------------|--------------|-----------|---------------------|--------------|
-- | IT          | 16,000.00    | 16,500.00    | -500.00   | 103.13              | Slightly Over|
-- | Sales       | 32,000.00    | 31,050.00    | 950.00    | 97.03               | On Track     |
-- =============================================

-- Monthly budget vs actual
SELECT
    fiscal_year,
    fiscal_month,
    ROUND(SUM(budgeted_amount), 2) AS budget,
    ROUND(SUM(actual_amount), 2) AS actual,
    ROUND(SUM(budgeted_amount) - SUM(actual_amount), 2) AS variance,
    ROUND((SUM(actual_amount) / SUM(budgeted_amount)) * 100, 2) AS utilization
FROM budget
GROUP BY fiscal_year, fiscal_month
ORDER BY fiscal_year DESC, fiscal_month DESC;

-- Category breakdown within departments
SELECT
    department,
    category,
    ROUND(SUM(budgeted_amount), 2) AS budget,
    ROUND(SUM(actual_amount), 2) AS actual,
    ROUND(SUM(budgeted_amount) - SUM(actual_amount), 2) AS variance,
    CASE
        WHEN SUM(actual_amount) > SUM(budgeted_amount) THEN 'Over'
        ELSE 'Under/On'
    END AS status
FROM budget
WHERE fiscal_year = CAST(strftime('%Y', 'now') AS INTEGER)
GROUP BY department, category
ORDER BY department, variance;

-- YTD Budget performance
SELECT
    department,
    ROUND(SUM(budgeted_amount), 2) AS ytd_budget,
    ROUND(SUM(actual_amount), 2) AS ytd_actual,
    ROUND(SUM(budgeted_amount) - SUM(actual_amount), 2) AS ytd_variance,
    ROUND(SUM(actual_amount) * 100.0 / SUM(budgeted_amount), 2) AS ytd_utilization
FROM budget
WHERE fiscal_year = CAST(strftime('%Y', 'now') AS INTEGER)
    AND fiscal_month <= CAST(strftime('%m', 'now') AS INTEGER)
GROUP BY department
ORDER BY ytd_variance;

-- Budget items over threshold (significant variances)
SELECT
    fiscal_year || '-' || printf('%02d', fiscal_month) AS period,
    department,
    category,
    ROUND(budgeted_amount, 2) AS budget,
    ROUND(actual_amount, 2) AS actual,
    ROUND(budgeted_amount - actual_amount, 2) AS variance,
    ROUND(ABS(budgeted_amount - actual_amount) * 100.0 / budgeted_amount, 2) AS variance_percent
FROM budget
WHERE ABS(budgeted_amount - actual_amount) > budgeted_amount * 0.1
ORDER BY ABS(variance) DESC
LIMIT 20;

-- Cumulative budget consumption
WITH monthly_cumulative AS (
    SELECT
        department,
        fiscal_month,
        budgeted_amount,
        actual_amount,
        SUM(budgeted_amount) OVER (PARTITION BY department ORDER BY fiscal_month) AS cumulative_budget,
        SUM(actual_amount) OVER (PARTITION BY department ORDER BY fiscal_month) AS cumulative_actual
    FROM budget
    WHERE fiscal_year = CAST(strftime('%Y', 'now') AS INTEGER)
)
SELECT
    department,
    fiscal_month,
    ROUND(cumulative_budget, 2) AS cumulative_budget,
    ROUND(cumulative_actual, 2) AS cumulative_actual,
    ROUND(cumulative_budget - cumulative_actual, 2) AS cumulative_variance,
    ROUND((cumulative_actual / cumulative_budget) * 100, 2) AS burn_rate
FROM monthly_cumulative
ORDER BY department, fiscal_month;

-- Forecast year-end based on current spend rate
WITH spending_rate AS (
    SELECT
        department,
        SUM(actual_amount) AS ytd_actual,
        COUNT(DISTINCT fiscal_month) AS months_elapsed,
        SUM(actual_amount) / COUNT(DISTINCT fiscal_month) AS monthly_rate
    FROM budget
    WHERE fiscal_year = CAST(strftime('%Y', 'now') AS INTEGER)
        AND fiscal_month <= CAST(strftime('%m', 'now') AS INTEGER)
    GROUP BY department
)
SELECT
    sr.department,
    ROUND(SUM(b.budgeted_amount), 2) AS annual_budget,
    ROUND(sr.ytd_actual, 2) AS ytd_actual,
    ROUND(sr.monthly_rate * 12, 2) AS projected_annual,
    ROUND(SUM(b.budgeted_amount) - sr.monthly_rate * 12, 2) AS projected_variance,
    CASE
        WHEN sr.monthly_rate * 12 > SUM(b.budgeted_amount) THEN 'Projected Over'
        ELSE 'On Track'
    END AS projection_status
FROM spending_rate sr
INNER JOIN budget b ON sr.department = b.department
WHERE b.fiscal_year = CAST(strftime('%Y', 'now') AS INTEGER)
GROUP BY sr.department, sr.ytd_actual, sr.monthly_rate
ORDER BY projected_variance;
