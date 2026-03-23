-- =============================================
-- Query: Monthly Expenses Analysis
-- Category: Finance Analytics
-- Difficulty: Beginner
--
-- Business Question:
-- What are our monthly expenses? How are they distributed
-- across categories and departments?
--
-- Use Case:
-- Budget monitoring, cost control, expense forecasting,
-- and financial planning.
-- =============================================

-- Monthly expense summary
SELECT
    strftime('%Y-%m', expense_date) AS month,
    COUNT(*) AS expense_count,
    ROUND(SUM(amount), 2) AS total_expenses,
    ROUND(AVG(amount), 2) AS avg_expense,
    ROUND(MIN(amount), 2) AS min_expense,
    ROUND(MAX(amount), 2) AS max_expense
FROM expenses
WHERE status IN ('Approved', 'Paid')
GROUP BY strftime('%Y-%m', expense_date)
ORDER BY month DESC;

-- =============================================
-- Expected Output:
-- | month   | expense_count | total_expenses | avg_expense |
-- |---------|---------------|----------------|-------------|
-- | 2024-03 | 2             | 1,550.00       | 775.00      |
-- | 2024-02 | 3             | 8,000.00       | 2,666.67    |
-- | 2024-01 | 4             | 8,280.00       | 2,070.00    |
-- =============================================

-- Expenses by category
SELECT
    category,
    COUNT(*) AS expense_count,
    ROUND(SUM(amount), 2) AS total_amount,
    ROUND(AVG(amount), 2) AS avg_amount,
    ROUND(SUM(amount) * 100.0 / (SELECT SUM(amount) FROM expenses WHERE status IN ('Approved', 'Paid')), 2) AS percent_of_total
FROM expenses
WHERE status IN ('Approved', 'Paid')
GROUP BY category
ORDER BY total_amount DESC;

-- Expenses by department
SELECT
    department,
    COUNT(*) AS expense_count,
    ROUND(SUM(amount), 2) AS total_expenses,
    ROUND(AVG(amount), 2) AS avg_expense,
    ROUND(SUM(amount) * 100.0 / (SELECT SUM(amount) FROM expenses WHERE status IN ('Approved', 'Paid')), 2) AS percent_of_total
FROM expenses
WHERE status IN ('Approved', 'Paid')
GROUP BY department
ORDER BY total_expenses DESC;

-- Category breakdown by department
SELECT
    department,
    category,
    COUNT(*) AS count,
    ROUND(SUM(amount), 2) AS total_amount
FROM expenses
WHERE status IN ('Approved', 'Paid')
GROUP BY department, category
ORDER BY department, total_amount DESC;

-- Expense trend over time
SELECT
    strftime('%Y-%m', expense_date) AS month,
    ROUND(SUM(CASE WHEN category = 'Rent' THEN amount ELSE 0 END), 2) AS rent,
    ROUND(SUM(CASE WHEN category = 'Utilities' THEN amount ELSE 0 END), 2) AS utilities,
    ROUND(SUM(CASE WHEN category = 'Marketing' THEN amount ELSE 0 END), 2) AS marketing,
    ROUND(SUM(CASE WHEN category = 'IT' THEN amount ELSE 0 END), 2) AS it,
    ROUND(SUM(CASE WHEN category = 'Travel' THEN amount ELSE 0 END), 2) AS travel,
    ROUND(SUM(CASE WHEN category NOT IN ('Rent', 'Utilities', 'Marketing', 'IT', 'Travel') THEN amount ELSE 0 END), 2) AS other,
    ROUND(SUM(amount), 2) AS total
FROM expenses
WHERE status IN ('Approved', 'Paid')
GROUP BY strftime('%Y-%m', expense_date)
ORDER BY month DESC
LIMIT 12;

-- Top expenses (individual transactions)
SELECT
    expense_id,
    expense_date,
    category,
    subcategory,
    description,
    ROUND(amount, 2) AS amount,
    department,
    status
FROM expenses
WHERE status IN ('Approved', 'Paid')
ORDER BY amount DESC
LIMIT 15;

-- Month-over-month expense change
WITH monthly_expenses AS (
    SELECT
        strftime('%Y-%m', expense_date) AS month,
        SUM(amount) AS total
    FROM expenses
    WHERE status IN ('Approved', 'Paid')
    GROUP BY strftime('%Y-%m', expense_date)
)
SELECT
    month,
    ROUND(total, 2) AS expenses,
    ROUND(LAG(total) OVER (ORDER BY month), 2) AS prev_month,
    ROUND(total - LAG(total) OVER (ORDER BY month), 2) AS change,
    ROUND(
        CASE
            WHEN LAG(total) OVER (ORDER BY month) > 0
            THEN ((total - LAG(total) OVER (ORDER BY month)) / LAG(total) OVER (ORDER BY month)) * 100
            ELSE NULL
        END,
    2) AS change_percent
FROM monthly_expenses
ORDER BY month DESC
LIMIT 12;
