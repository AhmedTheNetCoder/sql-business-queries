-- =============================================
-- Query: Accounts Receivable Aging Report
-- Category: Finance Analytics
-- Difficulty: Intermediate
--
-- Business Question:
-- How much money is owed to us, and how long has it been
-- outstanding? Which customers have overdue payments?
--
-- Use Case:
-- Cash flow management, collections prioritization,
-- credit risk assessment, and financial reporting.
-- =============================================

-- AR Aging Summary by bucket
SELECT
    CASE
        WHEN JULIANDAY('now') - JULIANDAY(due_date) <= 0 THEN '1. Current'
        WHEN JULIANDAY('now') - JULIANDAY(due_date) <= 30 THEN '2. 1-30 Days'
        WHEN JULIANDAY('now') - JULIANDAY(due_date) <= 60 THEN '3. 31-60 Days'
        WHEN JULIANDAY('now') - JULIANDAY(due_date) <= 90 THEN '4. 61-90 Days'
        ELSE '5. Over 90 Days'
    END AS aging_bucket,
    COUNT(*) AS invoice_count,
    ROUND(SUM(amount - paid_amount), 2) AS total_outstanding,
    ROUND(AVG(amount - paid_amount), 2) AS avg_outstanding,
    ROUND(SUM(amount - paid_amount) * 100.0 /
          (SELECT SUM(amount - paid_amount) FROM invoices WHERE status != 'Paid'), 2) AS percent_of_total
FROM invoices
WHERE status != 'Paid'
    AND status != 'Cancelled'
GROUP BY aging_bucket
ORDER BY aging_bucket;

-- =============================================
-- Expected Output:
-- | aging_bucket    | invoice_count | total_outstanding | percent_of_total |
-- |-----------------|---------------|-------------------|------------------|
-- | 1. Current      | 3             | 45,200.00         | 45.50            |
-- | 2. 1-30 Days    | 2             | 22,500.00         | 22.65            |
-- | 3. 31-60 Days   | 1             | 12,300.00         | 12.38            |
-- =============================================

-- Detailed AR by customer
SELECT
    c.customer_id,
    c.customer_name,
    c.customer_type,
    i.invoice_number,
    i.invoice_date,
    i.due_date,
    ROUND(i.total_amount, 2) AS invoice_amount,
    ROUND(i.paid_amount, 2) AS paid_amount,
    ROUND(i.total_amount - i.paid_amount, 2) AS outstanding,
    ROUND(JULIANDAY('now') - JULIANDAY(i.due_date), 0) AS days_overdue,
    CASE
        WHEN JULIANDAY('now') - JULIANDAY(i.due_date) <= 0 THEN 'Current'
        WHEN JULIANDAY('now') - JULIANDAY(i.due_date) <= 30 THEN '1-30 Days'
        WHEN JULIANDAY('now') - JULIANDAY(i.due_date) <= 60 THEN '31-60 Days'
        WHEN JULIANDAY('now') - JULIANDAY(i.due_date) <= 90 THEN '61-90 Days'
        ELSE 'Over 90 Days'
    END AS aging_bucket,
    i.status
FROM invoices i
INNER JOIN customers c ON i.customer_id = c.customer_id
WHERE i.status NOT IN ('Paid', 'Cancelled')
ORDER BY days_overdue DESC;

-- Customer AR Summary
SELECT
    c.customer_id,
    c.customer_name,
    c.customer_type,
    c.credit_limit,
    COUNT(i.invoice_id) AS open_invoices,
    ROUND(SUM(i.total_amount - i.paid_amount), 2) AS total_outstanding,
    ROUND(SUM(i.total_amount - i.paid_amount) / c.credit_limit * 100, 2) AS credit_utilization,
    ROUND(MAX(JULIANDAY('now') - JULIANDAY(i.due_date)), 0) AS oldest_overdue_days,
    CASE
        WHEN SUM(i.total_amount - i.paid_amount) > c.credit_limit THEN 'Over Limit'
        WHEN MAX(JULIANDAY('now') - JULIANDAY(i.due_date)) > 60 THEN 'High Risk'
        WHEN MAX(JULIANDAY('now') - JULIANDAY(i.due_date)) > 30 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_level
FROM customers c
INNER JOIN invoices i ON c.customer_id = i.customer_id
WHERE i.status NOT IN ('Paid', 'Cancelled')
GROUP BY c.customer_id, c.customer_name, c.customer_type, c.credit_limit
ORDER BY total_outstanding DESC;

-- Collection effectiveness
SELECT
    strftime('%Y-%m', invoice_date) AS invoice_month,
    COUNT(*) AS invoices_issued,
    COUNT(CASE WHEN status = 'Paid' THEN 1 END) AS invoices_paid,
    ROUND(SUM(total_amount), 2) AS total_invoiced,
    ROUND(SUM(paid_amount), 2) AS total_collected,
    ROUND(SUM(paid_amount) * 100.0 / SUM(total_amount), 2) AS collection_rate,
    ROUND(AVG(CASE WHEN payment_date IS NOT NULL
              THEN JULIANDAY(payment_date) - JULIANDAY(invoice_date) END), 1) AS avg_days_to_pay
FROM invoices
WHERE status != 'Cancelled'
GROUP BY strftime('%Y-%m', invoice_date)
ORDER BY invoice_month DESC
LIMIT 12;

-- High priority collections (large amounts, overdue)
SELECT
    c.customer_name,
    i.invoice_number,
    i.due_date,
    ROUND(i.total_amount - i.paid_amount, 2) AS outstanding,
    ROUND(JULIANDAY('now') - JULIANDAY(i.due_date), 0) AS days_overdue,
    c.phone AS contact_phone,
    c.email AS contact_email
FROM invoices i
INNER JOIN customers c ON i.customer_id = c.customer_id
WHERE i.status IN ('Pending', 'Overdue', 'Partial')
    AND JULIANDAY('now') - JULIANDAY(i.due_date) > 0
ORDER BY (i.total_amount - i.paid_amount) * (JULIANDAY('now') - JULIANDAY(i.due_date)) DESC
LIMIT 10;
