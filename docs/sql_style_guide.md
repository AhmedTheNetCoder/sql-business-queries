# SQL Style Guide

This document outlines the SQL coding standards used throughout this repository.

## General Formatting

### Keywords
- SQL keywords are written in **UPPERCASE**
- Examples: `SELECT`, `FROM`, `WHERE`, `GROUP BY`, `ORDER BY`

### Indentation
- Use 4 spaces for indentation (not tabs)
- Indent columns in SELECT, conditions in WHERE, etc.

### Line Length
- Keep lines under 100 characters when possible
- Break long lines at logical points

## Naming Conventions

### Tables and Columns
- Use **snake_case** for table and column names
- Examples: `customer_id`, `order_date`, `total_amount`

### Aliases
- Use meaningful single-letter or short aliases
- Common patterns:
  - `c` for customers
  - `o` for orders
  - `p` for products
  - `e` for employees
  - `oi` for order_items

```sql
SELECT
    c.customer_id,
    c.company_name,
    o.order_date
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
```

## Query Structure

### SELECT Statement
```sql
SELECT
    column1,
    column2,
    ROUND(column3, 2) AS calculated_column
FROM table_name
WHERE condition = 'value'
GROUP BY column1, column2
ORDER BY column1 DESC;
```

### JOINs
- Put each JOIN on its own line
- Include the join type explicitly (`INNER JOIN`, not just `JOIN`)

```sql
SELECT
    c.company_name,
    o.total_amount
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN regions r ON c.region_id = r.region_id
WHERE o.status = 'Completed'
```

### Subqueries
- Indent subqueries
- Use CTEs for complex queries (preferred over nested subqueries)

```sql
-- Good: Using CTE
WITH monthly_totals AS (
    SELECT
        strftime('%Y-%m', order_date) AS month,
        SUM(total_amount) AS revenue
    FROM orders
    WHERE status = 'Completed'
    GROUP BY strftime('%Y-%m', order_date)
)
SELECT * FROM monthly_totals ORDER BY month;

-- Avoid: Deeply nested subqueries
SELECT *
FROM (
    SELECT *
    FROM (
        SELECT * FROM orders
    )
)
```

## Common Patterns

### Aggregations with ROUND
Always round monetary values to 2 decimal places:
```sql
ROUND(SUM(total_amount), 2) AS total_revenue
ROUND(AVG(total_amount), 2) AS avg_order_value
```

### Date Formatting (SQLite)
```sql
strftime('%Y-%m', order_date) AS month      -- 2024-01
strftime('%Y', order_date) AS year          -- 2024
strftime('%m', order_date) AS month_num     -- 01
strftime('%w', order_date) AS day_of_week   -- 0-6 (Sunday=0)
DATE('now') AS today                        -- Current date
DATE('now', '-30 days') AS thirty_days_ago  -- Date arithmetic
```

### CASE Statements
```sql
CASE
    WHEN condition1 THEN 'Result 1'
    WHEN condition2 THEN 'Result 2'
    ELSE 'Default'
END AS category
```

### Window Functions
```sql
-- Running total
SUM(revenue) OVER (ORDER BY month) AS cumulative_revenue

-- Moving average
AVG(revenue) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS ma_3

-- Ranking
ROW_NUMBER() OVER (ORDER BY total_amount DESC) AS rank

-- Previous/Next values
LAG(revenue) OVER (ORDER BY month) AS prev_month
LEAD(revenue) OVER (ORDER BY month) AS next_month

-- Percentiles
NTILE(5) OVER (ORDER BY total_amount) AS quintile
```

### NULL Handling
```sql
COALESCE(nullable_column, 0) AS safe_value
NULLIF(divisor, 0) -- Prevent division by zero
```

## Query Documentation

Each query file includes a header comment:

```sql
-- =============================================
-- Query: [Query Name]
-- Category: [Category]
-- Difficulty: [Beginner/Intermediate/Advanced]
--
-- Business Question:
-- [What business question does this answer?]
--
-- Use Case:
-- [How would this be used in practice?]
-- =============================================
```

## Performance Considerations

### Indexes
- The schema includes indexes on commonly filtered columns
- Consider adding indexes for frequently joined columns

### Filtering Early
```sql
-- Good: Filter in subquery
SELECT *
FROM (
    SELECT * FROM orders WHERE status = 'Completed'
) o
INNER JOIN customers c ON o.customer_id = c.customer_id

-- Avoid: Filter late
SELECT *
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
WHERE o.status = 'Completed'
```

### Using LIMIT
For exploratory queries, always use LIMIT:
```sql
SELECT * FROM large_table LIMIT 100;
```

## Common Mistakes to Avoid

1. **Missing GROUP BY columns**: All non-aggregated columns in SELECT must be in GROUP BY
2. **Division by zero**: Always use NULLIF to protect against zero divisors
3. **Incorrect date comparisons**: Use proper date functions, not string comparisons
4. **Forgetting NULL handling**: Remember that NULL comparisons require IS NULL/IS NOT NULL
5. **Ambiguous column names**: Always qualify column names when joining tables

## SQLite-Specific Notes

This repository uses SQLite syntax. Key differences from other databases:

- Date functions: `strftime()` instead of `DATE_FORMAT()` or `TO_CHAR()`
- String concatenation: `||` operator
- FULL OUTER JOIN: Supported in SQLite 3.39.0+
- No `TOP` keyword: Use `LIMIT` instead
- Boolean values: Use 0 and 1, not TRUE/FALSE
