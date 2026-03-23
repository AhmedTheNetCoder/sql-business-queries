# SQL Business Queries Repository

A comprehensive collection of **50 production-ready SQL queries** for business analytics, organized by department and use case. Perfect for learning SQL, interview preparation, and building your data analytics portfolio.

![SQL](https://img.shields.io/badge/SQL-SQLite-blue)
![Queries](https://img.shields.io/badge/Queries-50-green)
![Categories](https://img.shields.io/badge/Categories-5-orange)

## Overview

This repository contains real-world business SQL queries that answer common questions asked in data analyst interviews and day-to-day business operations. Each query is documented with:

- Business question it answers
- Use case in practice
- Difficulty level
- Expected output format

## Quick Start

### 1. Set up the database

```bash
# Using SQLite
sqlite3 business.db < schema/create_tables.sql
sqlite3 business.db < schema/insert_sample_data.sql
```

### 2. Run a query

```bash
sqlite3 business.db < queries/sales/01_monthly_revenue.sql
```

### 3. Explore the queries

Browse the [Query Index](docs/query_index.md) to find queries by category and difficulty.

## Repository Structure

```
sql-business-queries/
├── README.md
├── LICENSE
├── .gitignore
├── schema/
│   ├── create_tables.sql      # Database schema (13 tables)
│   └── insert_sample_data.sql # Realistic Oman-based sample data
├── queries/
│   ├── sales/                 # 12 Sales analytics queries
│   ├── hr/                    # 10 HR analytics queries
│   ├── finance/               # 10 Finance analytics queries
│   ├── operations/            # 10 Operations analytics queries
│   └── advanced/              # 8 Advanced analytics queries
└── docs/
    ├── query_index.md         # Complete query catalog
    ├── schema_description.md  # Database documentation
    ├── sql_style_guide.md     # Coding standards
    └── business_context.md    # Business scenario explanation
```

## Query Categories

### Sales Analytics (12 queries)
Revenue tracking, customer analysis, product performance, and sales patterns.

| Query | Difficulty | Business Question |
|-------|------------|-------------------|
| Monthly Revenue | Beginner | What is our monthly revenue trend? |
| Regional Sales | Beginner | How do sales perform across regions? |
| Top Customers | Beginner | Who are our most valuable customers? |
| Product Performance | Intermediate | Which products perform best? |
| YoY Growth | Intermediate | How does this year compare to last? |

[View all Sales queries →](docs/query_index.md#sales-analytics)

### HR Analytics (10 queries)
Workforce analysis, compensation, turnover, and organizational metrics.

| Query | Difficulty | Business Question |
|-------|------------|-------------------|
| Employee Headcount | Beginner | What is our current workforce size? |
| Department Distribution | Beginner | How are employees distributed? |
| Salary Analysis | Intermediate | How are salaries distributed? |
| Turnover Rate | Intermediate | What is our employee turnover? |

[View all HR queries →](docs/query_index.md#hr-analytics)

### Finance Analytics (10 queries)
Accounts receivable, expenses, budgeting, cash flow, and profitability.

| Query | Difficulty | Business Question |
|-------|------------|-------------------|
| AR Aging | Beginner | How old are our receivables? |
| Budget vs Actual | Intermediate | How does spending compare to budget? |
| Profit Margins | Intermediate | What is product profitability? |
| Cash Flow | Intermediate | What is our cash position? |

[View all Finance queries →](docs/query_index.md#finance-analytics)

### Operations Analytics (10 queries)
Inventory management, order fulfillment, supplier performance, and logistics.

| Query | Difficulty | Business Question |
|-------|------------|-------------------|
| Inventory Status | Beginner | What is our current stock status? |
| Reorder Alerts | Beginner | What needs to be reordered? |
| Order Fulfillment | Intermediate | How efficient is fulfillment? |
| Supplier Performance | Intermediate | How are suppliers performing? |

[View all Operations queries →](docs/query_index.md#operations-analytics)

### Advanced Analytics (8 queries)
Cohort analysis, RFM segmentation, CLV, market basket analysis, and more.

| Query | Difficulty | Business Question |
|-------|------------|-------------------|
| Cohort Analysis | Advanced | How do customer cohorts behave? |
| RFM Segmentation | Advanced | How to segment customers by RFM? |
| Customer Lifetime Value | Advanced | What is customer LTV? |
| Market Basket Analysis | Advanced | What products are bought together? |
| Pareto Analysis | Advanced | What drives 80% of results? |

[View all Advanced queries →](docs/query_index.md#advanced-analytics)

## SQL Concepts Covered

### Beginner
- SELECT, FROM, WHERE, ORDER BY
- GROUP BY, HAVING
- INNER JOIN, LEFT JOIN
- Aggregate functions (SUM, COUNT, AVG)

### Intermediate
- CASE statements
- Multiple JOINs
- Subqueries
- UNION / UNION ALL
- Date functions

### Advanced
- Common Table Expressions (CTEs)
- Window Functions (ROW_NUMBER, RANK, LAG, LEAD, NTILE)
- Running totals and moving averages
- Self-joins
- Complex aggregations

## Database Schema

The sample database includes 13 interconnected tables:

- **regions** - Geographic regions
- **customers** - Business customers
- **suppliers** - Product vendors
- **products** - Product catalog
- **employees** - Company employees
- **orders** - Order headers
- **order_items** - Order line items
- **invoices** - Customer invoices
- **expenses** - Company expenses
- **budget** - Department budgets
- **inventory_transactions** - Stock movements
- **attendance** - Employee attendance
- **sales_targets** - Sales targets

[View full schema documentation →](docs/schema_description.md)

## Sample Data

The sample data represents a B2B distribution company operating in Oman with:

- Realistic company names (Oman National Bank, PDO, Omantel, etc.)
- Proper Oman phone numbers and cities
- Currency in Omani Rial (OMR)
- Data spanning 2023-2024

[Read business context →](docs/business_context.md)

## How to Use This Repository

### For Learning SQL
1. Start with Beginner queries in any category
2. Progress to Intermediate queries
3. Challenge yourself with Advanced analytics
4. Modify queries to answer your own questions

### For Interview Preparation
1. Practice explaining the business context
2. Walk through query logic step by step
3. Discuss optimization opportunities
4. Suggest follow-up analyses

### For Portfolio
1. Fork this repository
2. Run queries and document results
3. Create visualizations from query outputs
4. Add your own custom queries

## Tools Compatibility

These queries are written for **SQLite** and can be easily adapted for:

- PostgreSQL
- MySQL
- SQL Server
- BigQuery
- Snowflake

Key syntax differences are noted in the [SQL Style Guide](docs/sql_style_guide.md).

## Contributing

Contributions are welcome! Please:

1. Follow the existing query format and style
2. Include comprehensive header documentation
3. Test queries against the sample data
4. Update the query index if adding new queries

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Created as part of a Data Analytics portfolio project.

## Acknowledgments

- Sample data inspired by real GCC business scenarios
- Query patterns based on common interview questions and business needs
- SQL best practices from industry standards

---

**Star this repository** if you find it helpful for learning SQL and business analytics!
