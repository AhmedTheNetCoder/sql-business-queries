-- =============================================
-- SQL Business Queries - Database Schema
-- Author: Ahmed
-- Description: Complete database schema for business analytics
-- Database: SQLite (compatible with PostgreSQL/MySQL with minor changes)
-- =============================================

-- Drop tables if they exist (for clean recreation)
DROP TABLE IF EXISTS inventory_transactions;
DROP TABLE IF EXISTS attendance;
DROP TABLE IF EXISTS sales_targets;
DROP TABLE IF EXISTS budget;
DROP TABLE IF EXISTS expenses;
DROP TABLE IF EXISTS invoices;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS suppliers;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS regions;

-- =============================================
-- REGIONS TABLE
-- =============================================
CREATE TABLE regions (
    region_id INTEGER PRIMARY KEY AUTOINCREMENT,
    region_name VARCHAR(50) NOT NULL,
    country VARCHAR(50) DEFAULT 'Oman',
    manager_name VARCHAR(100),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- CUSTOMERS TABLE
-- =============================================
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    address VARCHAR(200),
    city VARCHAR(50),
    region VARCHAR(50),
    country VARCHAR(50) DEFAULT 'Oman',
    customer_type VARCHAR(20) CHECK (customer_type IN ('Individual', 'Business', 'Government')),
    credit_limit DECIMAL(12, 2) DEFAULT 5000.00,
    created_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT 1,
    notes TEXT
);

-- =============================================
-- SUPPLIERS TABLE
-- =============================================
CREATE TABLE suppliers (
    supplier_id INTEGER PRIMARY KEY AUTOINCREMENT,
    supplier_name VARCHAR(100) NOT NULL,
    contact_name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    address VARCHAR(200),
    city VARCHAR(50),
    country VARCHAR(50),
    payment_terms INTEGER DEFAULT 30,
    rating DECIMAL(3, 2) CHECK (rating >= 0 AND rating <= 5),
    is_active BOOLEAN DEFAULT 1,
    created_date DATE DEFAULT CURRENT_DATE
);

-- =============================================
-- PRODUCTS TABLE
-- =============================================
CREATE TABLE products (
    product_id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    subcategory VARCHAR(50),
    brand VARCHAR(50),
    unit_price DECIMAL(10, 2) NOT NULL,
    unit_cost DECIMAL(10, 2) NOT NULL,
    stock_quantity INTEGER DEFAULT 0,
    reorder_level INTEGER DEFAULT 10,
    reorder_quantity INTEGER DEFAULT 50,
    supplier_id INTEGER,
    is_active BOOLEAN DEFAULT 1,
    created_date DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

-- =============================================
-- EMPLOYEES TABLE
-- =============================================
CREATE TABLE employees (
    employee_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    hire_date DATE NOT NULL,
    job_title VARCHAR(100),
    department VARCHAR(50),
    manager_id INTEGER,
    salary DECIMAL(10, 2),
    commission_rate DECIMAL(5, 4) DEFAULT 0,
    birth_date DATE,
    gender VARCHAR(10) CHECK (gender IN ('Male', 'Female', 'Other')),
    address VARCHAR(200),
    city VARCHAR(50),
    status VARCHAR(20) DEFAULT 'Active' CHECK (status IN ('Active', 'On Leave', 'Terminated')),
    termination_date DATE,
    termination_reason VARCHAR(100),
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);

-- =============================================
-- ORDERS TABLE
-- =============================================
CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER NOT NULL,
    employee_id INTEGER,
    order_date DATE NOT NULL,
    required_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(20) CHECK (ship_mode IN ('Standard', 'Express', 'Same Day', 'Economy')),
    status VARCHAR(20) DEFAULT 'Pending' CHECK (status IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Completed', 'Cancelled', 'Returned')),
    subtotal DECIMAL(12, 2),
    discount_amount DECIMAL(10, 2) DEFAULT 0,
    tax_amount DECIMAL(10, 2) DEFAULT 0,
    shipping_cost DECIMAL(10, 2) DEFAULT 0,
    total_amount DECIMAL(12, 2),
    region VARCHAR(50),
    shipping_address VARCHAR(200),
    notes TEXT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- =============================================
-- ORDER ITEMS TABLE
-- =============================================
CREATE TABLE order_items (
    item_id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL,
    discount_percent DECIMAL(5, 2) DEFAULT 0 CHECK (discount_percent >= 0 AND discount_percent <= 100),
    line_total DECIMAL(12, 2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- =============================================
-- INVOICES TABLE
-- =============================================
CREATE TABLE invoices (
    invoice_id INTEGER PRIMARY KEY AUTOINCREMENT,
    invoice_number VARCHAR(20) UNIQUE,
    order_id INTEGER,
    customer_id INTEGER,
    invoice_date DATE NOT NULL,
    due_date DATE NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    tax_amount DECIMAL(10, 2) DEFAULT 0,
    total_amount DECIMAL(12, 2),
    paid_amount DECIMAL(12, 2) DEFAULT 0,
    status VARCHAR(20) DEFAULT 'Pending' CHECK (status IN ('Pending', 'Partial', 'Paid', 'Overdue', 'Cancelled')),
    payment_date DATE,
    payment_method VARCHAR(30),
    notes TEXT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- =============================================
-- EXPENSES TABLE
-- =============================================
CREATE TABLE expenses (
    expense_id INTEGER PRIMARY KEY AUTOINCREMENT,
    expense_date DATE NOT NULL,
    category VARCHAR(50),
    subcategory VARCHAR(50),
    description VARCHAR(200),
    amount DECIMAL(10, 2) NOT NULL,
    department VARCHAR(50),
    employee_id INTEGER,
    approved_by INTEGER,
    status VARCHAR(20) DEFAULT 'Pending' CHECK (status IN ('Pending', 'Approved', 'Rejected', 'Paid')),
    payment_method VARCHAR(30),
    receipt_number VARCHAR(50),
    notes TEXT,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (approved_by) REFERENCES employees(employee_id)
);

-- =============================================
-- BUDGET TABLE
-- =============================================
CREATE TABLE budget (
    budget_id INTEGER PRIMARY KEY AUTOINCREMENT,
    fiscal_year INTEGER NOT NULL,
    fiscal_month INTEGER NOT NULL CHECK (fiscal_month >= 1 AND fiscal_month <= 12),
    department VARCHAR(50),
    category VARCHAR(50),
    budgeted_amount DECIMAL(12, 2) NOT NULL,
    actual_amount DECIMAL(12, 2) DEFAULT 0,
    variance DECIMAL(12, 2),
    notes TEXT,
    UNIQUE(fiscal_year, fiscal_month, department, category)
);

-- =============================================
-- INVENTORY TRANSACTIONS TABLE
-- =============================================
CREATE TABLE inventory_transactions (
    transaction_id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER NOT NULL,
    transaction_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    transaction_type VARCHAR(20) CHECK (transaction_type IN ('IN', 'OUT', 'ADJUST', 'RETURN', 'DAMAGED')),
    quantity INTEGER NOT NULL,
    unit_cost DECIMAL(10, 2),
    reference_type VARCHAR(20),
    reference_id INTEGER,
    performed_by INTEGER,
    notes VARCHAR(200),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (performed_by) REFERENCES employees(employee_id)
);

-- =============================================
-- ATTENDANCE TABLE
-- =============================================
CREATE TABLE attendance (
    attendance_id INTEGER PRIMARY KEY AUTOINCREMENT,
    employee_id INTEGER NOT NULL,
    attendance_date DATE NOT NULL,
    check_in TIME,
    check_out TIME,
    status VARCHAR(20) DEFAULT 'Present' CHECK (status IN ('Present', 'Absent', 'Late', 'Half Day', 'On Leave', 'Holiday', 'Weekend')),
    hours_worked DECIMAL(4, 2),
    overtime_hours DECIMAL(4, 2) DEFAULT 0,
    notes VARCHAR(200),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    UNIQUE(employee_id, attendance_date)
);

-- =============================================
-- SALES TARGETS TABLE
-- =============================================
CREATE TABLE sales_targets (
    target_id INTEGER PRIMARY KEY AUTOINCREMENT,
    fiscal_year INTEGER NOT NULL,
    fiscal_month INTEGER NOT NULL CHECK (fiscal_month >= 1 AND fiscal_month <= 12),
    region VARCHAR(50),
    employee_id INTEGER,
    target_amount DECIMAL(12, 2) NOT NULL,
    achieved_amount DECIMAL(12, 2) DEFAULT 0,
    achievement_percent DECIMAL(6, 2),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- =============================================
-- INDEXES FOR PERFORMANCE
-- =============================================
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);
CREATE INDEX idx_employees_department ON employees(department);
CREATE INDEX idx_employees_status ON employees(status);
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_invoices_status ON invoices(status);
CREATE INDEX idx_invoices_due_date ON invoices(due_date);
CREATE INDEX idx_expenses_date ON expenses(expense_date);
CREATE INDEX idx_expenses_department ON expenses(department);
CREATE INDEX idx_attendance_employee ON attendance(employee_id);
CREATE INDEX idx_attendance_date ON attendance(attendance_date);
