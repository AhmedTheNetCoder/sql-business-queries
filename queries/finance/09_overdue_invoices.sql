-- =============================================
-- Query: Overdue Invoices Analysis
-- Category: Finance Analytics
-- Difficulty: Beginner
--
-- Business Question:
-- Which invoices are overdue? What is the total
-- outstanding amount at risk?
--
-- Use Case:
-- Collections management, credit risk assessment,
-- and accounts receivable prioritization.
-- =============================================

-- Overdue invoices list
SELECT
    i.invoice_id,
    i.invoice_number,
    c.company_name AS customer,
    c.customer_type,
    i.invoice_date,
    i.due_date,
    JULIANDAY('now') - JULIANDAY(i.due_date) AS days_overdue,
    i.total_amount,
    i.paid_amount,
    i.total_amount - i.paid_amount AS outstanding_amount,
    c.email,
    c.phone
FROM invoices i
INNER JOIN customers c ON i.customer_id = c.customer_id
WHERE i.status IN ('Overdue', 'Partial')
    AND i.due_date < DATE('now')
ORDER BY days_overdue DESC;

-- =============================================
-- Expected Output:
-- | invoice_number | customer          | days_overdue | outstanding_amount |
-- |----------------|-------------------|--------------|-------------------|
-- | INV-2024-0145  | Oman Trading Co   | 45           | 5,230.00          |
-- | INV-2024-0152  | Gulf Enterprises  | 32           | 3,150.00          |
-- =============================================

-- Overdue summary by aging bucket
SELECT
    CASE
        WHEN JULIANDAY('now') - JULIANDAY(due_date) <= 30 THEN '1-30 Days'
        WHEN JULIANDAY('now') - JULIANDAY(due_date) <= 60 THEN '31-60 Days'
        WHEN JULIANDAY('now') - JULIANDAY(due_date) <= 90 THEN '61-90 Days'
        ELSE '90+ Days'
    END AS aging_bucket,
    COUNT(*) AS invoice_count,
    ROUND(SUM(total_amount - paid_amount), 2) AS total_overdue,
    ROUND(AVG(total_amount - paid_amount), 2) AS avg_overdue,
    ROUND(AVG(JULIANDAY('now') - JULIANDAY(due_date)), 1) AS avg_days_overdue
FROM invoices
WHERE status IN ('Overdue', 'Partial')
    AND due_date < DATE('now')
GROUP BY aging_bucket
ORDER BY
    CASE aging_bucket
        WHEN '1-30 Days' THEN 1
        WHEN '31-60 Days' THEN 2
        WHEN '61-90 Days' THEN 3
        ELSE 4
    END;

-- Customer overdue summary
SELECT
    c.customer_id,
    c.company_name,
    c.customer_type,
    c.credit_limit,
    COUNT(*) AS overdue_invoices,
    ROUND(SUM(i.total_amount - i.paid_amount), 2) AS total_overdue,
    MAX(JULIANDAY('now') - JULIANDAY(i.due_date)) AS max_days_overdue,
    ROUND(SUM(i.total_amount - i.paid_amount) * 100.0 / c.credit_limit, 2) AS credit_utilization
FROM customers c
INNER JOIN invoices i ON c.customer_id = i.customer_id
WHERE i.status IN ('Overdue', 'Partial')
    AND i.due_date < DATE('now')
GROUP BY c.customer_id, c.company_name, c.customer_type, c.credit_limit
ORDER BY total_overdue DESC;

-- High-risk customers (multiple overdue or high amounts)
SELECT
    c.customer_id,
    c.company_name,
    c.customer_type,
    COUNT(*) AS overdue_count,
    ROUND(SUM(i.total_amount - i.paid_amount), 2) AS total_overdue,
    CASE
        WHEN COUNT(*) >= 3 OR SUM(i.total_amount - i.paid_amount) > 10000 THEN 'High Risk'
        WHEN COUNT(*) >= 2 OR SUM(i.total_amount - i.paid_amount) > 5000 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_level,
    CASE
        WHEN COUNT(*) >= 3 THEN 'Consider credit hold'
        WHEN MAX(JULIANDAY('now') - JULIANDAY(i.due_date)) > 60 THEN 'Escalate to collections'
        ELSE 'Send payment reminder'
    END AS recommended_action
FROM customers c
INNER JOIN invoices i ON c.customer_id = i.customer_id
WHERE i.status IN ('Overdue', 'Partial')
    AND i.due_date < DATE('now')
GROUP BY c.customer_id, c.company_name, c.customer_type
HAVING COUNT(*) >= 2 OR SUM(i.total_amount - i.paid_amount) > 3000
ORDER BY total_overdue DESC;

-- Weekly overdue trend
SELECT
    strftime('%Y-W%W', due_date) AS week_due,
    COUNT(*) AS invoices_became_overdue,
    ROUND(SUM(total_amount - paid_amount), 2) AS amount_became_overdue
FROM invoices
WHERE status IN ('Overdue', 'Partial')
    AND due_date < DATE('now')
    AND due_date >= DATE('now', '-12 weeks')
GROUP BY strftime('%Y-W%W', due_date)
ORDER BY week_due DESC;

-- Overdue by customer type
SELECT
    c.customer_type,
    COUNT(DISTINCT c.customer_id) AS customers_with_overdue,
    COUNT(*) AS total_overdue_invoices,
    ROUND(SUM(i.total_amount - i.paid_amount), 2) AS total_overdue_amount,
    ROUND(AVG(i.total_amount - i.paid_amount), 2) AS avg_overdue_per_invoice,
    ROUND(AVG(JULIANDAY('now') - JULIANDAY(i.due_date)), 1) AS avg_days_overdue
FROM customers c
INNER JOIN invoices i ON c.customer_id = i.customer_id
WHERE i.status IN ('Overdue', 'Partial')
    AND i.due_date < DATE('now')
GROUP BY c.customer_type
ORDER BY total_overdue_amount DESC;

-- Potential bad debt (90+ days overdue)
SELECT
    i.invoice_id,
    i.invoice_number,
    c.company_name,
    i.invoice_date,
    i.due_date,
    JULIANDAY('now') - JULIANDAY(i.due_date) AS days_overdue,
    i.total_amount - i.paid_amount AS outstanding,
    'Potential Write-off' AS status_recommendation
FROM invoices i
INNER JOIN customers c ON i.customer_id = c.customer_id
WHERE i.status IN ('Overdue', 'Partial')
    AND JULIANDAY('now') - JULIANDAY(i.due_date) > 90
ORDER BY days_overdue DESC;
