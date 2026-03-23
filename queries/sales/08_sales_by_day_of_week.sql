-- =============================================
-- Query: Sales by Day of Week Analysis
-- Category: Sales Analytics
-- Difficulty: Beginner
--
-- Business Question:
-- Which days of the week generate the most sales?
-- Should we adjust staffing or promotions based on daily patterns?
--
-- Use Case:
-- Operations teams use this for staffing decisions.
-- Marketing teams use it to time promotional campaigns.
-- =============================================

-- Sales by day of week
SELECT
    CASE CAST(strftime('%w', order_date) AS INTEGER)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END AS day_name,
    CAST(strftime('%w', order_date) AS INTEGER) AS day_number,
    COUNT(*) AS total_orders,
    ROUND(SUM(total_amount), 2) AS total_revenue,
    ROUND(AVG(total_amount), 2) AS avg_order_value,
    ROUND(SUM(total_amount) * 100.0 /
          (SELECT SUM(total_amount) FROM orders WHERE status = 'Completed'), 2) AS revenue_share
FROM orders
WHERE status = 'Completed'
GROUP BY day_name, day_number
ORDER BY day_number;

-- =============================================
-- Expected Output:
-- | day_name  | total_orders | total_revenue | avg_order_value | revenue_share |
-- |-----------|--------------|---------------|-----------------|---------------|
-- | Sunday    | 8            | 45,230.00     | 5,653.75        | 10.38         |
-- | Monday    | 15           | 82,450.00     | 5,496.67        | 18.92         |
-- | Tuesday   | 12           | 65,800.00     | 5,483.33        | 15.10         |
-- =============================================

-- Weekday vs Weekend comparison
SELECT
    CASE
        WHEN CAST(strftime('%w', order_date) AS INTEGER) IN (0, 6) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    COUNT(*) AS total_orders,
    ROUND(SUM(total_amount), 2) AS total_revenue,
    ROUND(AVG(total_amount), 2) AS avg_order_value,
    ROUND(COUNT(*) * 1.0 /
          CASE
              WHEN CAST(strftime('%w', order_date) AS INTEGER) IN (0, 6) THEN 2
              ELSE 5
          END, 1) AS avg_orders_per_day
FROM orders
WHERE status = 'Completed'
GROUP BY day_type;

-- Day of week trend by month
SELECT
    strftime('%Y-%m', order_date) AS month,
    SUM(CASE WHEN CAST(strftime('%w', order_date) AS INTEGER) = 0 THEN total_amount ELSE 0 END) AS sunday,
    SUM(CASE WHEN CAST(strftime('%w', order_date) AS INTEGER) = 1 THEN total_amount ELSE 0 END) AS monday,
    SUM(CASE WHEN CAST(strftime('%w', order_date) AS INTEGER) = 2 THEN total_amount ELSE 0 END) AS tuesday,
    SUM(CASE WHEN CAST(strftime('%w', order_date) AS INTEGER) = 3 THEN total_amount ELSE 0 END) AS wednesday,
    SUM(CASE WHEN CAST(strftime('%w', order_date) AS INTEGER) = 4 THEN total_amount ELSE 0 END) AS thursday,
    SUM(CASE WHEN CAST(strftime('%w', order_date) AS INTEGER) = 5 THEN total_amount ELSE 0 END) AS friday,
    SUM(CASE WHEN CAST(strftime('%w', order_date) AS INTEGER) = 6 THEN total_amount ELSE 0 END) AS saturday
FROM orders
WHERE status = 'Completed'
GROUP BY strftime('%Y-%m', order_date)
ORDER BY month DESC
LIMIT 6;

-- Best performing day by region
WITH regional_daily AS (
    SELECT
        region,
        CASE CAST(strftime('%w', order_date) AS INTEGER)
            WHEN 0 THEN 'Sunday'
            WHEN 1 THEN 'Monday'
            WHEN 2 THEN 'Tuesday'
            WHEN 3 THEN 'Wednesday'
            WHEN 4 THEN 'Thursday'
            WHEN 5 THEN 'Friday'
            WHEN 6 THEN 'Saturday'
        END AS day_name,
        SUM(total_amount) AS revenue,
        ROW_NUMBER() OVER (PARTITION BY region ORDER BY SUM(total_amount) DESC) AS rank
    FROM orders
    WHERE status = 'Completed'
    GROUP BY region, day_name
)
SELECT
    region,
    day_name AS best_day,
    ROUND(revenue, 2) AS revenue
FROM regional_daily
WHERE rank = 1
ORDER BY revenue DESC;
