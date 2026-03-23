-- =============================================
-- Query: Sales Target Achievement Analysis
-- Category: Sales Analytics
-- Difficulty: Intermediate
--
-- Business Question:
-- Are sales teams meeting their targets? Who is overperforming
-- or underperforming against goals?
--
-- Use Case:
-- Sales management for performance reviews, commission
-- calculations, and resource allocation.
-- =============================================

-- Monthly target achievement by region
SELECT
    st.fiscal_year,
    st.fiscal_month,
    st.region,
    ROUND(st.target_amount, 2) AS target,
    ROUND(st.achieved_amount, 2) AS achieved,
    ROUND(st.achieved_amount - st.target_amount, 2) AS variance,
    ROUND((st.achieved_amount / st.target_amount) * 100, 2) AS achievement_percent,
    CASE
        WHEN st.achieved_amount >= st.target_amount THEN 'Met'
        WHEN st.achieved_amount >= st.target_amount * 0.9 THEN 'Near Miss'
        ELSE 'Missed'
    END AS status
FROM sales_targets st
WHERE st.region IS NOT NULL
ORDER BY st.fiscal_year DESC, st.fiscal_month DESC, st.region;

-- =============================================
-- Expected Output:
-- | fiscal_year | fiscal_month | region     | target    | achieved  | achievement_percent | status   |
-- |-------------|--------------|------------|-----------|-----------|---------------------|----------|
-- | 2024        | 3            | Muscat     | 60,000.00 | 45,000.00 | 75.00               | Missed   |
-- | 2024        | 2            | Muscat     | 55,000.00 | 58,000.00 | 105.45              | Met      |
-- =============================================

-- Sales rep performance against targets
SELECT
    e.employee_id,
    e.first_name || ' ' || e.last_name AS sales_rep,
    st.fiscal_year,
    st.fiscal_month,
    ROUND(st.target_amount, 2) AS target,
    ROUND(st.achieved_amount, 2) AS achieved,
    ROUND((st.achieved_amount / st.target_amount) * 100, 2) AS achievement_percent,
    e.commission_rate,
    ROUND(st.achieved_amount * e.commission_rate, 2) AS estimated_commission
FROM sales_targets st
INNER JOIN employees e ON st.employee_id = e.employee_id
WHERE st.employee_id IS NOT NULL
ORDER BY st.fiscal_year DESC, st.fiscal_month DESC, achievement_percent DESC;

-- YTD target summary
SELECT
    st.fiscal_year,
    st.region,
    ROUND(SUM(st.target_amount), 2) AS ytd_target,
    ROUND(SUM(st.achieved_amount), 2) AS ytd_achieved,
    ROUND(SUM(st.achieved_amount) - SUM(st.target_amount), 2) AS ytd_variance,
    ROUND((SUM(st.achieved_amount) / SUM(st.target_amount)) * 100, 2) AS ytd_achievement_percent
FROM sales_targets st
WHERE st.region IS NOT NULL
    AND st.fiscal_year = strftime('%Y', 'now')
GROUP BY st.fiscal_year, st.region
ORDER BY ytd_achievement_percent DESC;

-- Gap analysis - how much more needed to hit target
SELECT
    st.region,
    st.fiscal_month,
    ROUND(st.target_amount, 2) AS target,
    ROUND(st.achieved_amount, 2) AS achieved,
    ROUND(st.target_amount - st.achieved_amount, 2) AS gap_to_target,
    CASE
        WHEN st.achieved_amount >= st.target_amount THEN 'Target Met'
        ELSE ROUND((st.target_amount - st.achieved_amount) / st.target_amount * 100, 1) || '% gap'
    END AS gap_analysis
FROM sales_targets st
WHERE st.fiscal_year = strftime('%Y', 'now')
    AND st.region IS NOT NULL
    AND st.fiscal_month = CAST(strftime('%m', 'now') AS INTEGER)
ORDER BY gap_to_target DESC;

-- Trend: achievement rate over time
SELECT
    fiscal_year || '-' || printf('%02d', fiscal_month) AS period,
    ROUND(SUM(target_amount), 2) AS total_target,
    ROUND(SUM(achieved_amount), 2) AS total_achieved,
    ROUND((SUM(achieved_amount) / SUM(target_amount)) * 100, 2) AS achievement_rate
FROM sales_targets
WHERE region IS NOT NULL
GROUP BY fiscal_year, fiscal_month
ORDER BY period DESC
LIMIT 12;
