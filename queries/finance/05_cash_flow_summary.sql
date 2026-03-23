-- =============================================
-- Query: Cash Flow Summary
-- Category: Finance Analytics
-- Difficulty: Intermediate
--
-- Business Question:
-- What is our cash position? What are the major
-- inflows and outflows affecting cash?
--
-- Use Case:
-- Cash management, liquidity planning, and
-- financial forecasting.
-- =============================================

-- Monthly cash flow summary
WITH cash_inflows AS (
    SELECT
        strftime('%Y-%m', payment_date) AS month,
        SUM(paid_amount) AS cash_received
    FROM invoices
    WHERE status = 'Paid'
        AND payment_date IS NOT NULL
    GROUP BY strftime('%Y-%m', payment_date)
),
cash_outflows AS (
    SELECT
        strftime('%Y-%m', expense_date) AS month,
        SUM(amount) AS cash_paid
    FROM expenses
    WHERE status = 'Paid'
    GROUP BY strftime('%Y-%m', expense_date)
)
SELECT
    COALESCE(ci.month, co.month) AS month,
    COALESCE(ci.cash_received, 0) AS cash_in,
    COALESCE(co.cash_paid, 0) AS cash_out,
    COALESCE(ci.cash_received, 0) - COALESCE(co.cash_paid, 0) AS net_cash_flow
FROM cash_inflows ci
FULL OUTER JOIN cash_outflows co ON ci.month = co.month
ORDER BY month DESC;

-- =============================================
-- Expected Output:
-- | month   | cash_in    | cash_out  | net_cash_flow |
-- |---------|------------|-----------|---------------|
-- | 2024-02 | 45,230.00  | 12,500.00 | 32,730.00     |
-- | 2024-01 | 62,180.00  | 15,280.00 | 46,900.00     |
-- =============================================

-- Cash inflow details (collections)
SELECT
    strftime('%Y-%m', payment_date) AS month,
    COUNT(*) AS invoices_collected,
    ROUND(SUM(paid_amount), 2) AS total_collected,
    ROUND(AVG(paid_amount), 2) AS avg_collection,
    ROUND(AVG(JULIANDAY(payment_date) - JULIANDAY(invoice_date)), 1) AS avg_days_to_collect
FROM invoices
WHERE status = 'Paid'
    AND payment_date IS NOT NULL
GROUP BY strftime('%Y-%m', payment_date)
ORDER BY month DESC
LIMIT 12;

-- Cash outflow by category
SELECT
    strftime('%Y-%m', expense_date) AS month,
    ROUND(SUM(CASE WHEN category = 'Rent' THEN amount ELSE 0 END), 2) AS rent,
    ROUND(SUM(CASE WHEN category = 'Utilities' THEN amount ELSE 0 END), 2) AS utilities,
    ROUND(SUM(CASE WHEN category = 'Marketing' THEN amount ELSE 0 END), 2) AS marketing,
    ROUND(SUM(CASE WHEN category = 'IT' THEN amount ELSE 0 END), 2) AS it,
    ROUND(SUM(CASE WHEN category NOT IN ('Rent', 'Utilities', 'Marketing', 'IT') THEN amount ELSE 0 END), 2) AS other,
    ROUND(SUM(amount), 2) AS total_outflow
FROM expenses
WHERE status = 'Paid'
GROUP BY strftime('%Y-%m', expense_date)
ORDER BY month DESC
LIMIT 12;

-- Outstanding receivables (future cash inflow)
SELECT
    'Accounts Receivable' AS category,
    COUNT(*) AS count,
    ROUND(SUM(total_amount - paid_amount), 2) AS amount
FROM invoices
WHERE status NOT IN ('Paid', 'Cancelled')

UNION ALL

-- Pending expenses (future cash outflow)
SELECT
    'Pending Expenses' AS category,
    COUNT(*) AS count,
    ROUND(SUM(amount), 2) AS amount
FROM expenses
WHERE status IN ('Pending', 'Approved');

-- Cash conversion cycle components
WITH metrics AS (
    -- Days Sales Outstanding (DSO)
    SELECT
        'DSO' AS metric,
        ROUND(AVG(JULIANDAY(payment_date) - JULIANDAY(invoice_date)), 1) AS days
    FROM invoices
    WHERE status = 'Paid' AND payment_date IS NOT NULL

    UNION ALL

    -- Days Payable Outstanding (simplified)
    SELECT
        'DPO' AS metric,
        30 AS days  -- Assuming 30-day payment terms
)
SELECT * FROM metrics;

-- Weekly cash flow (for short-term planning)
SELECT
    strftime('%Y-W%W', payment_date) AS week,
    ROUND(SUM(paid_amount), 2) AS collections
FROM invoices
WHERE status = 'Paid'
    AND payment_date >= DATE('now', '-8 weeks')
GROUP BY strftime('%Y-W%W', payment_date)
ORDER BY week DESC;

-- Cash position forecast (next 30 days)
SELECT
    'Expected Collections' AS item,
    ROUND(SUM(total_amount - paid_amount), 2) AS amount,
    'Inflow' AS type
FROM invoices
WHERE status IN ('Pending', 'Partial')
    AND due_date BETWEEN DATE('now') AND DATE('now', '+30 days')

UNION ALL

SELECT
    'Overdue Collections' AS item,
    ROUND(SUM(total_amount - paid_amount), 2) AS amount,
    'Inflow (Delayed)' AS type
FROM invoices
WHERE status IN ('Overdue', 'Partial')
    AND due_date < DATE('now')

UNION ALL

SELECT
    'Pending Expenses' AS item,
    ROUND(SUM(amount), 2) AS amount,
    'Outflow' AS type
FROM expenses
WHERE status IN ('Pending', 'Approved');
