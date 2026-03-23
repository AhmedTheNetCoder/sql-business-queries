# Database Schema Description

This document describes the database schema used in the SQL Business Queries repository.

## Entity Relationship Overview

```
regions ─────────┬──────────────── customers ──────────── orders ──────────── order_items
                 │                     │                    │                      │
                 │                     │                    │                      │
                 │                     └──── invoices       │                      │
                 │                                          │                      │
suppliers ───────┴──────────────── products ───────────────┴──────────────────────┘
                                      │
                                      └──── inventory_transactions

employees ──────────── attendance
    │
    └──── orders (sales rep)
    │
    └──── expenses

budget ──────────── (standalone, links by department/category)

sales_targets ──────────── (standalone, links to employees)
```

## Tables

### 1. regions
Geographic regions for customer locations.

| Column | Type | Description |
|--------|------|-------------|
| region_id | INTEGER | Primary key |
| region_name | TEXT | Full name (e.g., "Muscat") |
| region_code | TEXT | Short code (e.g., "MSC") |
| country | TEXT | Country name |

### 2. customers
Business customers who purchase products.

| Column | Type | Description |
|--------|------|-------------|
| customer_id | INTEGER | Primary key |
| company_name | TEXT | Company name |
| contact_name | TEXT | Primary contact |
| email | TEXT | Contact email |
| phone | TEXT | Contact phone |
| address | TEXT | Street address |
| city | TEXT | City |
| region_id | INTEGER | FK to regions |
| customer_type | TEXT | SMB/Corporate/Enterprise |
| credit_limit | REAL | Credit limit in OMR |
| is_active | INTEGER | 1=active, 0=inactive |
| created_at | TEXT | Account creation date |

### 3. suppliers
Vendors who supply products.

| Column | Type | Description |
|--------|------|-------------|
| supplier_id | INTEGER | Primary key |
| supplier_name | TEXT | Company name |
| contact_name | TEXT | Primary contact |
| email | TEXT | Contact email |
| phone | TEXT | Contact phone |
| address | TEXT | Street address |
| city | TEXT | City |
| country | TEXT | Country |
| payment_terms | INTEGER | Payment terms in days |
| rating | REAL | Supplier rating (1-5) |
| is_active | INTEGER | 1=active, 0=inactive |

### 4. products
Products available for sale.

| Column | Type | Description |
|--------|------|-------------|
| product_id | INTEGER | Primary key |
| product_name | TEXT | Product name |
| sku | TEXT | Stock keeping unit |
| category | TEXT | Product category |
| unit_price | REAL | Selling price (OMR) |
| unit_cost | REAL | Cost price (OMR) |
| stock_quantity | INTEGER | Current stock level |
| reorder_level | INTEGER | Reorder threshold |
| supplier_id | INTEGER | FK to suppliers |
| is_active | INTEGER | 1=active, 0=inactive |
| created_at | TEXT | Product creation date |

### 5. employees
Company employees.

| Column | Type | Description |
|--------|------|-------------|
| employee_id | INTEGER | Primary key |
| first_name | TEXT | First name |
| last_name | TEXT | Last name |
| email | TEXT | Work email |
| phone | TEXT | Phone number |
| hire_date | TEXT | Date hired |
| department | TEXT | Department name |
| position | TEXT | Job title |
| salary | REAL | Monthly salary (OMR) |
| manager_id | INTEGER | FK to employees (self) |
| status | TEXT | Active/Inactive/On Leave |
| birth_date | TEXT | Date of birth |

### 6. orders
Customer orders (header).

| Column | Type | Description |
|--------|------|-------------|
| order_id | INTEGER | Primary key |
| order_number | TEXT | Order reference number |
| customer_id | INTEGER | FK to customers |
| employee_id | INTEGER | FK to employees (sales rep) |
| order_date | TEXT | Order date |
| status | TEXT | Pending/Processing/Completed/Cancelled |
| total_amount | REAL | Order total (OMR) |
| notes | TEXT | Order notes |

### 7. order_items
Line items within orders.

| Column | Type | Description |
|--------|------|-------------|
| order_item_id | INTEGER | Primary key |
| order_id | INTEGER | FK to orders |
| product_id | INTEGER | FK to products |
| quantity | INTEGER | Quantity ordered |
| unit_price | REAL | Price at time of order |
| discount_percent | REAL | Discount applied |
| line_total | REAL | Line item total |

### 8. invoices
Invoices generated from orders.

| Column | Type | Description |
|--------|------|-------------|
| invoice_id | INTEGER | Primary key |
| invoice_number | TEXT | Invoice reference |
| order_id | INTEGER | FK to orders |
| customer_id | INTEGER | FK to customers |
| invoice_date | TEXT | Invoice date |
| due_date | TEXT | Payment due date |
| total_amount | REAL | Invoice total |
| paid_amount | REAL | Amount paid so far |
| status | TEXT | Pending/Partial/Paid/Overdue/Cancelled |
| payment_date | TEXT | Date payment received |

### 9. expenses
Company expenses.

| Column | Type | Description |
|--------|------|-------------|
| expense_id | INTEGER | Primary key |
| department | TEXT | Department incurring expense |
| category | TEXT | Expense category |
| description | TEXT | Expense description |
| amount | REAL | Amount (OMR) |
| expense_date | TEXT | Date of expense |
| employee_id | INTEGER | FK to employees (submitter) |
| status | TEXT | Pending/Approved/Paid/Rejected |

### 10. budget
Department budgets by category and year.

| Column | Type | Description |
|--------|------|-------------|
| budget_id | INTEGER | Primary key |
| department | TEXT | Department name |
| category | TEXT | Budget category |
| fiscal_year | INTEGER | Fiscal year |
| budget_amount | REAL | Budgeted amount (OMR) |
| notes | TEXT | Budget notes |

### 11. inventory_transactions
Stock movement records.

| Column | Type | Description |
|--------|------|-------------|
| transaction_id | INTEGER | Primary key |
| product_id | INTEGER | FK to products |
| transaction_type | TEXT | IN/OUT/ADJUSTMENT |
| quantity | INTEGER | Quantity moved |
| transaction_date | TEXT | Date of transaction |
| reference_id | INTEGER | Related order/PO ID |
| notes | TEXT | Transaction notes |

### 12. attendance
Employee attendance records.

| Column | Type | Description |
|--------|------|-------------|
| attendance_id | INTEGER | Primary key |
| employee_id | INTEGER | FK to employees |
| attendance_date | TEXT | Date |
| status | TEXT | Present/Absent/Late/Half-day |
| check_in | TEXT | Check-in time |
| check_out | TEXT | Check-out time |

### 13. sales_targets
Sales targets for employees.

| Column | Type | Description |
|--------|------|-------------|
| target_id | INTEGER | Primary key |
| employee_id | INTEGER | FK to employees |
| target_month | TEXT | Target month (YYYY-MM) |
| target_amount | REAL | Target amount (OMR) |
| achieved_amount | REAL | Amount achieved |

## Indexes

The schema includes indexes on frequently queried columns:

```sql
-- Customer queries
CREATE INDEX idx_customers_region ON customers(region_id);
CREATE INDEX idx_customers_type ON customers(customer_type);

-- Order queries
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_status ON orders(status);

-- Order items
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);

-- Products
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_supplier ON products(supplier_id);

-- Employees
CREATE INDEX idx_employees_department ON employees(department);

-- Invoices
CREATE INDEX idx_invoices_customer ON invoices(customer_id);
CREATE INDEX idx_invoices_status ON invoices(status);

-- Expenses
CREATE INDEX idx_expenses_department ON expenses(department);
CREATE INDEX idx_expenses_date ON expenses(expense_date);
```

## Relationships Summary

| Parent Table | Child Table | Relationship |
|--------------|-------------|--------------|
| regions | customers | 1:N |
| suppliers | products | 1:N |
| customers | orders | 1:N |
| employees | orders | 1:N |
| orders | order_items | 1:N |
| products | order_items | 1:N |
| orders | invoices | 1:1 |
| customers | invoices | 1:N |
| employees | expenses | 1:N |
| employees | attendance | 1:N |
| employees | sales_targets | 1:N |
| products | inventory_transactions | 1:N |
| employees | employees | 1:N (manager) |
