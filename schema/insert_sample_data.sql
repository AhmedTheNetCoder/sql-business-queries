-- =============================================
-- SQL Business Queries - Sample Data
-- Author: Ahmed
-- Description: Realistic sample data for testing queries
-- =============================================

-- =============================================
-- REGIONS DATA
-- =============================================
INSERT INTO regions (region_name, country, manager_name) VALUES
('Muscat', 'Oman', 'Ahmed Al-Rashid'),
('Dhofar', 'Oman', 'Fatima Al-Balushi'),
('Al Batinah', 'Oman', 'Mohammed Al-Habsi'),
('Al Sharqiyah', 'Oman', 'Salim Al-Rawahi'),
('Al Dakhiliyah', 'Oman', 'Khalid Al-Farsi');

-- =============================================
-- SUPPLIERS DATA
-- =============================================
INSERT INTO suppliers (supplier_name, contact_name, email, phone, city, country, payment_terms, rating) VALUES
('Gulf Electronics LLC', 'Ali Hassan', 'ali@gulfelectronics.com', '+968-2456-7890', 'Dubai', 'UAE', 30, 4.5),
('Oman Food Industries', 'Sara Al-Lawati', 'sara@omanfood.com', '+968-2234-5678', 'Muscat', 'Oman', 45, 4.8),
('Al Madina Trading', 'Yusuf Khan', 'yusuf@almadina.com', '+968-2345-6789', 'Salalah', 'Oman', 30, 4.2),
('Tech Solutions MENA', 'Ravi Sharma', 'ravi@techsolutions.com', '+971-4-567-8901', 'Dubai', 'UAE', 60, 4.0),
('National Paper Co', 'Aisha Mahmoud', 'aisha@nationalpaper.com', '+968-2456-1234', 'Sohar', 'Oman', 30, 4.6),
('Quality Furniture', 'Hassan Al-Kindi', 'hassan@qualityfurn.com', '+968-2567-8901', 'Muscat', 'Oman', 45, 4.3),
('Arabian Supplies', 'Mariam Said', 'mariam@arabiansupplies.com', '+968-2678-9012', 'Nizwa', 'Oman', 30, 4.7),
('Global Imports LLC', 'Chen Wei', 'chen@globalimports.com', '+971-4-789-0123', 'Sharjah', 'UAE', 60, 3.9);

-- =============================================
-- PRODUCTS DATA
-- =============================================
INSERT INTO products (product_name, category, subcategory, brand, unit_price, unit_cost, stock_quantity, reorder_level, supplier_id) VALUES
-- Electronics
('Laptop Pro 15"', 'Electronics', 'Computers', 'TechBrand', 450.00, 320.00, 45, 10, 1),
('Wireless Mouse', 'Electronics', 'Accessories', 'TechBrand', 25.00, 12.00, 200, 50, 1),
('USB-C Hub', 'Electronics', 'Accessories', 'TechBrand', 45.00, 22.00, 150, 30, 1),
('27" Monitor', 'Electronics', 'Displays', 'ViewMax', 280.00, 180.00, 35, 10, 4),
('Mechanical Keyboard', 'Electronics', 'Accessories', 'KeyMaster', 85.00, 45.00, 80, 20, 1),
('Webcam HD', 'Electronics', 'Accessories', 'ViewMax', 65.00, 35.00, 60, 15, 4),
('Printer All-in-One', 'Electronics', 'Printers', 'PrintPro', 220.00, 140.00, 25, 8, 4),
('External SSD 1TB', 'Electronics', 'Storage', 'DataSafe', 95.00, 55.00, 100, 25, 1),
-- Office Supplies
('A4 Paper (5 Ream)', 'Office Supplies', 'Paper', 'PaperMax', 18.00, 10.00, 500, 100, 5),
('Ballpoint Pens (Box)', 'Office Supplies', 'Writing', 'WritePro', 8.00, 3.50, 300, 50, 5),
('Stapler Heavy Duty', 'Office Supplies', 'Equipment', 'OfficeTool', 15.00, 7.00, 100, 20, 5),
('File Folders (Pack)', 'Office Supplies', 'Organization', 'FileMaster', 12.00, 5.00, 200, 40, 5),
('Whiteboard Large', 'Office Supplies', 'Presentation', 'BoardPro', 85.00, 45.00, 30, 5, 5),
-- Furniture
('Office Chair Ergonomic', 'Furniture', 'Seating', 'ComfortPlus', 320.00, 180.00, 40, 10, 6),
('Executive Desk', 'Furniture', 'Desks', 'WorkSpace', 450.00, 280.00, 20, 5, 6),
('Meeting Table 8-Person', 'Furniture', 'Tables', 'WorkSpace', 680.00, 420.00, 10, 3, 6),
('Filing Cabinet 4-Drawer', 'Furniture', 'Storage', 'SecureFile', 195.00, 110.00, 35, 8, 6),
('Reception Sofa', 'Furniture', 'Seating', 'ComfortPlus', 550.00, 320.00, 8, 2, 6),
-- Food & Beverages
('Arabic Coffee (1kg)', 'Food & Beverage', 'Beverages', 'OmanRoast', 25.00, 14.00, 150, 30, 2),
('Dates Premium (5kg)', 'Food & Beverage', 'Snacks', 'OmanDates', 35.00, 18.00, 200, 40, 2),
('Mineral Water (Case)', 'Food & Beverage', 'Beverages', 'PureWater', 8.00, 4.00, 400, 80, 2),
('Tea Bags (100 pack)', 'Food & Beverage', 'Beverages', 'TeaTime', 12.00, 6.00, 250, 50, 2),
-- Cleaning Supplies
('Hand Sanitizer (5L)', 'Cleaning', 'Hygiene', 'CleanSafe', 22.00, 11.00, 100, 20, 7),
('Cleaning Wipes (Pack)', 'Cleaning', 'Supplies', 'CleanSafe', 15.00, 7.00, 150, 30, 7),
('Floor Cleaner (5L)', 'Cleaning', 'Supplies', 'SparkleClean', 18.00, 9.00, 80, 15, 7);

-- =============================================
-- EMPLOYEES DATA
-- =============================================
INSERT INTO employees (first_name, last_name, email, phone, hire_date, job_title, department, manager_id, salary, commission_rate, birth_date, gender, city, status) VALUES
-- Management
('Ahmed', 'Al-Rashid', 'ahmed.rashid@company.com', '+968-9123-4567', '2018-01-15', 'CEO', 'Executive', NULL, 8500.00, 0, '1975-03-20', 'Male', 'Muscat', 'Active'),
('Fatima', 'Al-Balushi', 'fatima.balushi@company.com', '+968-9234-5678', '2018-03-01', 'CFO', 'Finance', 1, 7000.00, 0, '1978-07-12', 'Female', 'Muscat', 'Active'),
('Mohammed', 'Al-Habsi', 'mohammed.habsi@company.com', '+968-9345-6789', '2018-06-15', 'Sales Director', 'Sales', 1, 6500.00, 0.02, '1980-11-25', 'Male', 'Muscat', 'Active'),
('Salim', 'Al-Rawahi', 'salim.rawahi@company.com', '+968-9456-7890', '2019-02-01', 'HR Director', 'Human Resources', 1, 5500.00, 0, '1982-04-18', 'Male', 'Muscat', 'Active'),
('Khalid', 'Al-Farsi', 'khalid.farsi@company.com', '+968-9567-8901', '2019-04-15', 'Operations Manager', 'Operations', 1, 5000.00, 0, '1983-09-30', 'Male', 'Sohar', 'Active'),
-- Sales Team
('Sara', 'Al-Lawati', 'sara.lawati@company.com', '+968-9678-9012', '2020-01-10', 'Senior Sales Rep', 'Sales', 3, 3200.00, 0.05, '1990-02-14', 'Female', 'Muscat', 'Active'),
('Yusuf', 'Al-Kindi', 'yusuf.kindi@company.com', '+968-9789-0123', '2020-03-20', 'Sales Representative', 'Sales', 3, 2500.00, 0.04, '1992-06-08', 'Male', 'Salalah', 'Active'),
('Aisha', 'Al-Harthi', 'aisha.harthi@company.com', '+968-9890-1234', '2020-06-01', 'Sales Representative', 'Sales', 3, 2500.00, 0.04, '1993-10-22', 'Female', 'Muscat', 'Active'),
('Hassan', 'Al-Busaidi', 'hassan.busaidi@company.com', '+968-9901-2345', '2021-01-15', 'Sales Representative', 'Sales', 3, 2300.00, 0.04, '1994-01-05', 'Male', 'Nizwa', 'Active'),
('Mariam', 'Al-Zadjali', 'mariam.zadjali@company.com', '+968-9012-3456', '2021-04-01', 'Junior Sales Rep', 'Sales', 6, 2000.00, 0.03, '1996-08-17', 'Female', 'Muscat', 'Active'),
-- Finance Team
('Rashid', 'Al-Hinai', 'rashid.hinai@company.com', '+968-9111-2222', '2019-08-01', 'Senior Accountant', 'Finance', 2, 3500.00, 0, '1988-05-10', 'Male', 'Muscat', 'Active'),
('Layla', 'Al-Mamari', 'layla.mamari@company.com', '+968-9222-3333', '2020-09-15', 'Accountant', 'Finance', 11, 2800.00, 0, '1991-12-03', 'Female', 'Muscat', 'Active'),
('Omar', 'Al-Wahaibi', 'omar.wahaibi@company.com', '+968-9333-4444', '2021-06-01', 'Junior Accountant', 'Finance', 11, 2200.00, 0, '1995-03-28', 'Male', 'Muscat', 'Active'),
-- HR Team
('Nadia', 'Al-Riyami', 'nadia.riyami@company.com', '+968-9444-5555', '2020-02-01', 'HR Specialist', 'Human Resources', 4, 2800.00, 0, '1989-07-14', 'Female', 'Muscat', 'Active'),
('Saeed', 'Al-Shukaili', 'saeed.shukaili@company.com', '+968-9555-6666', '2021-08-01', 'HR Coordinator', 'Human Resources', 14, 2200.00, 0, '1994-11-20', 'Male', 'Muscat', 'Active'),
-- Operations Team
('Hamad', 'Al-Hosni', 'hamad.hosni@company.com', '+968-9666-7777', '2019-10-01', 'Warehouse Supervisor', 'Operations', 5, 2800.00, 0, '1987-02-08', 'Male', 'Sohar', 'Active'),
('Zainab', 'Al-Mawali', 'zainab.mawali@company.com', '+968-9777-8888', '2020-04-15', 'Inventory Specialist', 'Operations', 16, 2400.00, 0, '1992-09-12', 'Female', 'Sohar', 'Active'),
('Ibrahim', 'Al-Ghafri', 'ibrahim.ghafri@company.com', '+968-9888-9999', '2021-03-01', 'Logistics Coordinator', 'Operations', 5, 2500.00, 0, '1993-04-25', 'Male', 'Muscat', 'Active'),
-- IT Team
('Tariq', 'Al-Nasseri', 'tariq.nasseri@company.com', '+968-9999-0000', '2020-07-01', 'IT Manager', 'IT', 1, 4200.00, 0, '1985-06-30', 'Male', 'Muscat', 'Active'),
('Huda', 'Al-Jabri', 'huda.jabri@company.com', '+968-9000-1111', '2021-09-15', 'IT Support', 'IT', 19, 2300.00, 0, '1995-12-18', 'Female', 'Muscat', 'Active'),
-- Terminated Employees (for turnover analysis)
('Abdullah', 'Al-Saadi', 'abdullah.saadi@company.com', '+968-9100-2222', '2020-05-01', 'Sales Representative', 'Sales', 3, 2400.00, 0.04, '1991-08-05', 'Male', 'Muscat', 'Terminated'),
('Muna', 'Al-Toqi', 'muna.toqi@company.com', '+968-9200-3333', '2021-02-15', 'Accountant', 'Finance', 11, 2600.00, 0, '1990-03-22', 'Female', 'Muscat', 'Terminated'),
('Fahad', 'Al-Ismaili', 'fahad.ismaili@company.com', '+968-9300-4444', '2019-11-01', 'Warehouse Staff', 'Operations', 16, 1800.00, 0, '1988-10-15', 'Male', 'Sohar', 'Terminated');

-- Update termination info
UPDATE employees SET termination_date = '2023-08-15', termination_reason = 'Resigned - Better Opportunity' WHERE employee_id = 21;
UPDATE employees SET termination_date = '2024-01-31', termination_reason = 'Resigned - Personal Reasons' WHERE employee_id = 22;
UPDATE employees SET termination_date = '2023-06-30', termination_reason = 'Performance' WHERE employee_id = 23;

-- =============================================
-- CUSTOMERS DATA
-- =============================================
INSERT INTO customers (customer_name, email, phone, city, region, customer_type, credit_limit, created_date) VALUES
-- Business Customers
('Oman National Bank', 'procurement@onb.com', '+968-2412-3456', 'Muscat', 'Muscat', 'Business', 50000.00, '2019-01-15'),
('Muscat Electricity', 'supplies@muscatelec.com', '+968-2423-4567', 'Muscat', 'Muscat', 'Government', 75000.00, '2019-02-20'),
('Salalah Port Services', 'admin@salalahport.com', '+968-2334-5678', 'Salalah', 'Dhofar', 'Business', 40000.00, '2019-03-10'),
('Al Maha Petroleum', 'office@almaha.com', '+968-2445-6789', 'Sohar', 'Al Batinah', 'Business', 60000.00, '2019-04-05'),
('Oman Tourism College', 'procurement@otc.edu.om', '+968-2456-7890', 'Muscat', 'Muscat', 'Government', 30000.00, '2019-05-15'),
('Gulf Contractors LLC', 'admin@gulfcontractors.com', '+968-2467-8901', 'Muscat', 'Muscat', 'Business', 45000.00, '2019-06-20'),
('Nizwa Medical Center', 'supplies@nizwamedical.com', '+968-2278-9012', 'Nizwa', 'Al Dakhiliyah', 'Business', 35000.00, '2019-07-10'),
('Sur Fisheries Co', 'office@surfisheries.com', '+968-2289-0123', 'Sur', 'Al Sharqiyah', 'Business', 25000.00, '2019-08-15'),
('Royal Oman Police HQ', 'logistics@rop.gov.om', '+968-2490-1234', 'Muscat', 'Muscat', 'Government', 100000.00, '2019-09-01'),
('Omantel', 'procurement@omantel.om', '+968-2401-2345', 'Muscat', 'Muscat', 'Business', 80000.00, '2019-10-10'),
-- Individual Customers
('Mohammed Al-Said', 'msaid@email.com', '+968-9112-3456', 'Muscat', 'Muscat', 'Individual', 5000.00, '2020-01-15'),
('Fatima Al-Rashdi', 'frashdi@email.com', '+968-9223-4567', 'Salalah', 'Dhofar', 'Individual', 5000.00, '2020-02-20'),
('Ahmed Al-Balushi', 'abalushi@email.com', '+968-9334-5678', 'Sohar', 'Al Batinah', 'Individual', 5000.00, '2020-03-10'),
('Sara Al-Busaidi', 'sbusaidi@email.com', '+968-9445-6789', 'Nizwa', 'Al Dakhiliyah', 'Individual', 5000.00, '2020-04-15'),
('Khalid Al-Lawati', 'klawati@email.com', '+968-9556-7890', 'Muscat', 'Muscat', 'Individual', 5000.00, '2020-05-20'),
('Mariam Al-Harthi', 'mharthi@email.com', '+968-9667-8901', 'Sur', 'Al Sharqiyah', 'Individual', 5000.00, '2020-06-10'),
('Hassan Al-Kindi', 'hkindi@email.com', '+968-9778-9012', 'Muscat', 'Muscat', 'Individual', 5000.00, '2020-07-15'),
('Aisha Al-Farsi', 'afarsi@email.com', '+968-9889-0123', 'Salalah', 'Dhofar', 'Individual', 5000.00, '2020-08-20'),
('Yusuf Al-Habsi', 'yhabsi@email.com', '+968-9990-1234', 'Sohar', 'Al Batinah', 'Individual', 5000.00, '2020-09-10'),
('Nadia Al-Zadjali', 'nzadjali@email.com', '+968-9001-2345', 'Muscat', 'Muscat', 'Individual', 5000.00, '2020-10-15'),
-- More business customers
('Dhofar Insurance', 'admin@dhofarins.com', '+968-2312-4567', 'Salalah', 'Dhofar', 'Business', 35000.00, '2020-11-01'),
('Sohar Aluminium', 'procurement@soharalum.com', '+968-2423-5678', 'Sohar', 'Al Batinah', 'Business', 55000.00, '2020-12-15'),
('Bank Muscat', 'supplies@bankmuscat.com', '+968-2434-6789', 'Muscat', 'Muscat', 'Business', 70000.00, '2021-01-10'),
('Oman Air', 'logistics@omanair.com', '+968-2445-7890', 'Muscat', 'Muscat', 'Business', 90000.00, '2021-02-20'),
('PDO', 'procurement@pdo.co.om', '+968-2456-8901', 'Muscat', 'Muscat', 'Business', 150000.00, '2021-03-15');

-- =============================================
-- ORDERS DATA (2023-2024)
-- =============================================
-- Generate diverse orders across different dates, customers, and amounts
INSERT INTO orders (customer_id, employee_id, order_date, required_date, ship_date, ship_mode, status, subtotal, discount_amount, tax_amount, shipping_cost, total_amount, region) VALUES
-- 2023 Q1
(1, 6, '2023-01-05', '2023-01-12', '2023-01-10', 'Standard', 'Completed', 2500.00, 125.00, 118.75, 25.00, 2518.75, 'Muscat'),
(2, 7, '2023-01-10', '2023-01-17', '2023-01-15', 'Express', 'Completed', 5800.00, 290.00, 275.50, 50.00, 5835.50, 'Muscat'),
(3, 8, '2023-01-15', '2023-01-22', '2023-01-20', 'Standard', 'Completed', 1200.00, 60.00, 57.00, 30.00, 1227.00, 'Dhofar'),
(4, 6, '2023-01-20', '2023-01-27', '2023-01-25', 'Express', 'Completed', 8500.00, 425.00, 403.75, 75.00, 8553.75, 'Al Batinah'),
(5, 9, '2023-01-25', '2023-02-01', '2023-01-30', 'Standard', 'Completed', 3200.00, 160.00, 152.00, 35.00, 3227.00, 'Muscat'),
(6, 6, '2023-02-05', '2023-02-12', '2023-02-10', 'Standard', 'Completed', 4500.00, 225.00, 213.75, 40.00, 4528.75, 'Muscat'),
(7, 7, '2023-02-10', '2023-02-17', '2023-02-15', 'Express', 'Completed', 2100.00, 105.00, 99.75, 30.00, 2124.75, 'Al Dakhiliyah'),
(8, 8, '2023-02-15', '2023-02-22', '2023-02-20', 'Economy', 'Completed', 850.00, 0.00, 42.50, 15.00, 907.50, 'Al Sharqiyah'),
(9, 6, '2023-02-20', '2023-02-27', '2023-02-25', 'Standard', 'Completed', 12500.00, 625.00, 593.75, 100.00, 12568.75, 'Muscat'),
(10, 9, '2023-02-28', '2023-03-07', '2023-03-05', 'Express', 'Completed', 7800.00, 390.00, 370.50, 65.00, 7845.50, 'Muscat'),
(11, 6, '2023-03-05', '2023-03-12', '2023-03-10', 'Standard', 'Completed', 450.00, 0.00, 22.50, 10.00, 482.50, 'Muscat'),
(12, 7, '2023-03-10', '2023-03-17', '2023-03-15', 'Standard', 'Completed', 1800.00, 90.00, 85.50, 25.00, 1820.50, 'Dhofar'),
(13, 8, '2023-03-15', '2023-03-22', '2023-03-20', 'Express', 'Completed', 3500.00, 175.00, 166.25, 45.00, 3536.25, 'Al Batinah'),
(14, 9, '2023-03-20', '2023-03-27', '2023-03-25', 'Standard', 'Completed', 2200.00, 110.00, 104.50, 30.00, 2224.50, 'Al Dakhiliyah'),
(15, 6, '2023-03-25', '2023-04-01', '2023-03-30', 'Economy', 'Completed', 680.00, 0.00, 34.00, 12.00, 726.00, 'Muscat'),
-- 2023 Q2
(1, 6, '2023-04-05', '2023-04-12', '2023-04-10', 'Standard', 'Completed', 4200.00, 210.00, 199.50, 40.00, 4229.50, 'Muscat'),
(3, 7, '2023-04-10', '2023-04-17', '2023-04-15', 'Express', 'Completed', 6500.00, 325.00, 308.75, 55.00, 6538.75, 'Dhofar'),
(5, 8, '2023-04-15', '2023-04-22', '2023-04-20', 'Standard', 'Completed', 1500.00, 75.00, 71.25, 20.00, 1516.25, 'Muscat'),
(2, 6, '2023-04-20', '2023-04-27', '2023-04-25', 'Express', 'Completed', 9200.00, 460.00, 437.00, 80.00, 9257.00, 'Muscat'),
(4, 9, '2023-04-25', '2023-05-02', '2023-04-30', 'Standard', 'Completed', 3800.00, 190.00, 180.50, 35.00, 3825.50, 'Al Batinah'),
(6, 6, '2023-05-05', '2023-05-12', '2023-05-10', 'Standard', 'Completed', 2800.00, 140.00, 133.00, 30.00, 2823.00, 'Muscat'),
(21, 7, '2023-05-10', '2023-05-17', '2023-05-15', 'Economy', 'Completed', 950.00, 0.00, 47.50, 15.00, 1012.50, 'Dhofar'),
(22, 8, '2023-05-15', '2023-05-22', '2023-05-20', 'Express', 'Completed', 11500.00, 575.00, 546.25, 95.00, 11566.25, 'Al Batinah'),
(23, 6, '2023-05-20', '2023-05-27', '2023-05-25', 'Standard', 'Completed', 5200.00, 260.00, 247.00, 45.00, 5232.00, 'Muscat'),
(24, 9, '2023-05-25', '2023-06-01', '2023-05-30', 'Express', 'Completed', 18500.00, 925.00, 878.75, 150.00, 18603.75, 'Muscat'),
(25, 6, '2023-06-05', '2023-06-12', '2023-06-10', 'Standard', 'Completed', 22000.00, 1100.00, 1045.00, 175.00, 22120.00, 'Muscat'),
(1, 7, '2023-06-10', '2023-06-17', '2023-06-15', 'Standard', 'Completed', 3600.00, 180.00, 171.00, 35.00, 3626.00, 'Muscat'),
(10, 8, '2023-06-15', '2023-06-22', '2023-06-20', 'Express', 'Completed', 7200.00, 360.00, 342.00, 60.00, 7242.00, 'Muscat'),
(15, 6, '2023-06-20', '2023-06-27', '2023-06-25', 'Economy', 'Completed', 520.00, 0.00, 26.00, 10.00, 556.00, 'Muscat'),
(17, 9, '2023-06-25', '2023-07-02', '2023-06-30', 'Standard', 'Completed', 1850.00, 92.50, 87.88, 25.00, 1870.38, 'Muscat'),
-- 2023 Q3
(2, 6, '2023-07-05', '2023-07-12', '2023-07-10', 'Express', 'Completed', 8800.00, 440.00, 418.00, 75.00, 8853.00, 'Muscat'),
(3, 7, '2023-07-10', '2023-07-17', '2023-07-15', 'Standard', 'Completed', 2400.00, 120.00, 114.00, 30.00, 2424.00, 'Dhofar'),
(9, 8, '2023-07-15', '2023-07-22', '2023-07-20', 'Standard', 'Completed', 15200.00, 760.00, 722.00, 120.00, 15282.00, 'Muscat'),
(4, 6, '2023-07-20', '2023-07-27', '2023-07-25', 'Express', 'Completed', 6100.00, 305.00, 289.75, 50.00, 6134.75, 'Al Batinah'),
(11, 9, '2023-07-25', '2023-08-01', '2023-07-30', 'Economy', 'Completed', 380.00, 0.00, 19.00, 8.00, 407.00, 'Muscat'),
(12, 6, '2023-08-05', '2023-08-12', '2023-08-10', 'Standard', 'Completed', 1650.00, 82.50, 78.38, 22.00, 1667.88, 'Dhofar'),
(5, 7, '2023-08-10', '2023-08-17', '2023-08-15', 'Express', 'Completed', 4800.00, 240.00, 228.00, 45.00, 4833.00, 'Muscat'),
(6, 8, '2023-08-15', '2023-08-22', '2023-08-20', 'Standard', 'Completed', 3100.00, 155.00, 147.25, 35.00, 3127.25, 'Muscat'),
(24, 6, '2023-08-20', '2023-08-27', '2023-08-25', 'Express', 'Completed', 14500.00, 725.00, 688.75, 115.00, 14578.75, 'Muscat'),
(25, 9, '2023-08-25', '2023-09-01', '2023-08-30', 'Standard', 'Completed', 19800.00, 990.00, 940.50, 160.00, 19910.50, 'Muscat'),
(1, 6, '2023-09-05', '2023-09-12', '2023-09-10', 'Standard', 'Completed', 5500.00, 275.00, 261.25, 50.00, 5536.25, 'Muscat'),
(10, 7, '2023-09-10', '2023-09-17', '2023-09-15', 'Express', 'Completed', 9500.00, 475.00, 451.25, 80.00, 9556.25, 'Muscat'),
(7, 8, '2023-09-15', '2023-09-22', '2023-09-20', 'Standard', 'Completed', 2850.00, 142.50, 135.38, 30.00, 2872.88, 'Al Dakhiliyah'),
(13, 6, '2023-09-20', '2023-09-27', '2023-09-25', 'Economy', 'Completed', 720.00, 0.00, 36.00, 12.00, 768.00, 'Al Batinah'),
(18, 9, '2023-09-25', '2023-10-02', '2023-09-30', 'Standard', 'Completed', 1980.00, 99.00, 94.05, 25.00, 2000.05, 'Dhofar'),
-- 2023 Q4
(2, 6, '2023-10-05', '2023-10-12', '2023-10-10', 'Express', 'Completed', 7600.00, 380.00, 361.00, 65.00, 7646.00, 'Muscat'),
(9, 7, '2023-10-10', '2023-10-17', '2023-10-15', 'Standard', 'Completed', 16500.00, 825.00, 783.75, 130.00, 16588.75, 'Muscat'),
(3, 8, '2023-10-15', '2023-10-22', '2023-10-20', 'Standard', 'Completed', 3200.00, 160.00, 152.00, 35.00, 3227.00, 'Dhofar'),
(23, 6, '2023-10-20', '2023-10-27', '2023-10-25', 'Express', 'Completed', 8900.00, 445.00, 422.75, 75.00, 8952.75, 'Muscat'),
(4, 9, '2023-10-25', '2023-11-01', '2023-10-30', 'Standard', 'Completed', 5400.00, 270.00, 256.50, 48.00, 5434.50, 'Al Batinah'),
(24, 6, '2023-11-05', '2023-11-12', '2023-11-10', 'Express', 'Completed', 21000.00, 1050.00, 997.50, 170.00, 21117.50, 'Muscat'),
(25, 7, '2023-11-10', '2023-11-17', '2023-11-15', 'Standard', 'Completed', 28500.00, 1425.00, 1353.75, 225.00, 28653.75, 'Muscat'),
(1, 8, '2023-11-15', '2023-11-22', '2023-11-20', 'Standard', 'Completed', 4100.00, 205.00, 194.75, 40.00, 4129.75, 'Muscat'),
(10, 6, '2023-11-20', '2023-11-27', '2023-11-25', 'Express', 'Completed', 11200.00, 560.00, 532.00, 95.00, 11267.00, 'Muscat'),
(5, 9, '2023-11-25', '2023-12-02', '2023-11-30', 'Standard', 'Completed', 2600.00, 130.00, 123.50, 30.00, 2623.50, 'Muscat'),
(6, 6, '2023-12-05', '2023-12-12', '2023-12-10', 'Express', 'Completed', 5800.00, 290.00, 275.50, 50.00, 5835.50, 'Muscat'),
(21, 7, '2023-12-10', '2023-12-17', '2023-12-15', 'Standard', 'Completed', 1450.00, 72.50, 68.88, 20.00, 1466.38, 'Dhofar'),
(22, 8, '2023-12-15', '2023-12-22', '2023-12-20', 'Express', 'Completed', 13800.00, 690.00, 655.50, 110.00, 13875.50, 'Al Batinah'),
(2, 6, '2023-12-20', '2023-12-27', '2023-12-24', 'Express', 'Completed', 9800.00, 490.00, 465.50, 85.00, 9860.50, 'Muscat'),
(9, 9, '2023-12-28', '2024-01-04', '2024-01-02', 'Standard', 'Completed', 18200.00, 910.00, 864.50, 145.00, 18299.50, 'Muscat'),
-- 2024 Q1
(25, 6, '2024-01-05', '2024-01-12', '2024-01-10', 'Express', 'Completed', 32000.00, 1600.00, 1520.00, 250.00, 32170.00, 'Muscat'),
(1, 7, '2024-01-10', '2024-01-17', '2024-01-15', 'Standard', 'Completed', 4800.00, 240.00, 228.00, 45.00, 4833.00, 'Muscat'),
(3, 8, '2024-01-15', '2024-01-22', '2024-01-20', 'Standard', 'Completed', 2900.00, 145.00, 137.75, 32.00, 2924.75, 'Dhofar'),
(24, 6, '2024-01-20', '2024-01-27', '2024-01-25', 'Express', 'Completed', 17500.00, 875.00, 831.25, 140.00, 17596.25, 'Muscat'),
(4, 9, '2024-01-25', '2024-02-01', '2024-01-30', 'Standard', 'Completed', 7200.00, 360.00, 342.00, 60.00, 7242.00, 'Al Batinah'),
(10, 6, '2024-02-05', '2024-02-12', '2024-02-10', 'Express', 'Completed', 12800.00, 640.00, 608.00, 105.00, 12873.00, 'Muscat'),
(5, 7, '2024-02-10', '2024-02-17', '2024-02-15', 'Standard', 'Completed', 3500.00, 175.00, 166.25, 38.00, 3529.25, 'Muscat'),
(23, 8, '2024-02-15', '2024-02-22', '2024-02-20', 'Express', 'Completed', 9600.00, 480.00, 456.00, 80.00, 9656.00, 'Muscat'),
(2, 6, '2024-02-20', '2024-02-27', '2024-02-25', 'Standard', 'Completed', 8200.00, 410.00, 389.50, 70.00, 8249.50, 'Muscat'),
(6, 9, '2024-02-28', '2024-03-06', '2024-03-04', 'Express', 'Completed', 4500.00, 225.00, 213.75, 42.00, 4530.75, 'Muscat'),
-- Pending/Processing Orders (for current status queries)
(25, 6, '2024-03-01', '2024-03-08', NULL, 'Express', 'Processing', 25000.00, 1250.00, 1187.50, 200.00, 25137.50, 'Muscat'),
(1, 7, '2024-03-05', '2024-03-12', NULL, 'Standard', 'Pending', 5500.00, 275.00, 261.25, 50.00, 5536.25, 'Muscat'),
(9, 8, '2024-03-08', '2024-03-15', NULL, 'Express', 'Processing', 14200.00, 710.00, 674.50, 115.00, 14279.50, 'Muscat'),
(3, 6, '2024-03-10', '2024-03-17', NULL, 'Standard', 'Pending', 3800.00, 190.00, 180.50, 35.00, 3825.50, 'Dhofar'),
-- Cancelled/Returned Orders (for analysis)
(15, 8, '2023-05-20', '2023-05-27', NULL, 'Standard', 'Cancelled', 1200.00, 60.00, 57.00, 20.00, 1217.00, 'Muscat'),
(19, 9, '2023-08-15', '2023-08-22', '2023-08-20', 'Express', 'Returned', 2800.00, 140.00, 133.00, 30.00, 2823.00, 'Al Batinah');

-- =============================================
-- ORDER ITEMS DATA
-- =============================================
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_percent, line_total) VALUES
-- Order 1
(1, 1, 3, 450.00, 5, 1282.50),
(1, 2, 10, 25.00, 5, 237.50),
(1, 9, 20, 18.00, 5, 342.00),
-- Order 2
(2, 14, 8, 320.00, 5, 2432.00),
(2, 15, 4, 450.00, 5, 1710.00),
(2, 4, 5, 280.00, 5, 1330.00),
-- Order 3
(3, 19, 15, 25.00, 5, 356.25),
(3, 20, 10, 35.00, 5, 332.50),
(3, 21, 30, 8.00, 5, 228.00),
-- Order 4 (large order)
(4, 1, 10, 450.00, 5, 4275.00),
(4, 4, 8, 280.00, 5, 2128.00),
(4, 8, 15, 95.00, 5, 1353.75),
-- Continue with more order items...
(5, 14, 5, 320.00, 5, 1520.00),
(5, 16, 2, 680.00, 5, 1292.00),
(6, 1, 5, 450.00, 5, 2137.50),
(6, 5, 10, 85.00, 5, 807.50),
(6, 6, 15, 65.00, 5, 926.25),
(7, 19, 30, 25.00, 5, 712.50),
(7, 22, 50, 12.00, 5, 570.00),
(8, 10, 50, 8.00, 0, 400.00),
(8, 9, 25, 18.00, 0, 450.00),
(9, 1, 15, 450.00, 5, 6412.50),
(9, 4, 12, 280.00, 5, 3192.00),
(9, 7, 8, 220.00, 5, 1672.00),
(10, 14, 12, 320.00, 5, 3648.00),
(10, 15, 6, 450.00, 5, 2565.00),
(10, 17, 5, 195.00, 5, 926.25);

-- =============================================
-- INVOICES DATA
-- =============================================
INSERT INTO invoices (invoice_number, order_id, customer_id, invoice_date, due_date, amount, tax_amount, total_amount, paid_amount, status, payment_date, payment_method) VALUES
-- Paid invoices
('INV-2023-001', 1, 1, '2023-01-10', '2023-02-09', 2393.75, 125.00, 2518.75, 2518.75, 'Paid', '2023-02-05', 'Bank Transfer'),
('INV-2023-002', 2, 2, '2023-01-15', '2023-02-14', 5560.50, 275.00, 5835.50, 5835.50, 'Paid', '2023-02-10', 'Bank Transfer'),
('INV-2023-003', 3, 3, '2023-01-20', '2023-02-19', 1170.00, 57.00, 1227.00, 1227.00, 'Paid', '2023-02-18', 'Cheque'),
('INV-2023-004', 4, 4, '2023-01-25', '2023-02-24', 8150.00, 403.75, 8553.75, 8553.75, 'Paid', '2023-02-20', 'Bank Transfer'),
('INV-2023-005', 5, 5, '2023-01-30', '2023-03-01', 3075.00, 152.00, 3227.00, 3227.00, 'Paid', '2023-02-28', 'Bank Transfer'),
-- More paid invoices
('INV-2023-010', 10, 10, '2023-03-05', '2023-04-04', 7475.00, 370.50, 7845.50, 7845.50, 'Paid', '2023-04-01', 'Bank Transfer'),
('INV-2023-025', 25, 25, '2023-06-10', '2023-07-10', 21075.00, 1045.00, 22120.00, 22120.00, 'Paid', '2023-07-08', 'Bank Transfer'),
('INV-2023-051', 51, 24, '2023-11-10', '2023-12-10', 20120.00, 997.50, 21117.50, 21117.50, 'Paid', '2023-12-05', 'Bank Transfer'),
('INV-2023-052', 52, 25, '2023-11-15', '2023-12-15', 27300.00, 1353.75, 28653.75, 28653.75, 'Paid', '2023-12-12', 'Bank Transfer'),
-- Pending/Partial invoices (for AR aging)
('INV-2024-001', 66, 25, '2024-01-10', '2024-02-09', 30650.00, 1520.00, 32170.00, 20000.00, 'Partial', NULL, NULL),
('INV-2024-005', 70, 10, '2024-02-10', '2024-03-11', 12265.00, 608.00, 12873.00, 0, 'Pending', NULL, NULL),
('INV-2024-008', 73, 2, '2024-02-25', '2024-03-26', 7860.00, 389.50, 8249.50, 0, 'Pending', NULL, NULL),
('INV-2024-010', 75, 25, '2024-03-05', '2024-04-04', 23950.00, 1187.50, 25137.50, 0, 'Pending', NULL, NULL),
-- Overdue invoices
('INV-2023-045', 45, 5, '2023-08-15', '2023-09-14', 4600.00, 228.00, 4828.00, 0, 'Overdue', NULL, NULL),
('INV-2023-048', 48, 3, '2023-10-20', '2023-11-19', 3070.00, 157.00, 3227.00, 1500.00, 'Overdue', NULL, NULL);

-- =============================================
-- EXPENSES DATA
-- =============================================
INSERT INTO expenses (expense_date, category, subcategory, description, amount, department, employee_id, approved_by, status, payment_method) VALUES
-- 2023 Expenses
('2023-01-15', 'Rent', 'Office Space', 'Monthly office rent - Muscat HQ', 4500.00, 'Administration', NULL, 1, 'Paid', 'Bank Transfer'),
('2023-01-15', 'Utilities', 'Electricity', 'Monthly electricity bill', 850.00, 'Administration', NULL, 2, 'Paid', 'Bank Transfer'),
('2023-01-20', 'Marketing', 'Advertising', 'Google Ads campaign - January', 1200.00, 'Sales', 3, 1, 'Paid', 'Credit Card'),
('2023-01-25', 'Travel', 'Transportation', 'Client visit to Salalah', 350.00, 'Sales', 7, 3, 'Paid', 'Cash'),
('2023-02-15', 'Rent', 'Office Space', 'Monthly office rent - Muscat HQ', 4500.00, 'Administration', NULL, 1, 'Paid', 'Bank Transfer'),
('2023-02-15', 'Utilities', 'Electricity', 'Monthly electricity bill', 920.00, 'Administration', NULL, 2, 'Paid', 'Bank Transfer'),
('2023-02-20', 'IT', 'Software', 'Annual Microsoft 365 subscription', 2400.00, 'IT', 19, 1, 'Paid', 'Credit Card'),
('2023-02-28', 'HR', 'Training', 'Sales team training workshop', 1800.00, 'Human Resources', 4, 1, 'Paid', 'Bank Transfer'),
('2023-03-15', 'Rent', 'Office Space', 'Monthly office rent - Muscat HQ', 4500.00, 'Administration', NULL, 1, 'Paid', 'Bank Transfer'),
('2023-03-20', 'Marketing', 'Events', 'Trade show booth rental', 3500.00, 'Sales', 3, 1, 'Paid', 'Bank Transfer'),
('2023-04-15', 'Rent', 'Office Space', 'Monthly office rent - Muscat HQ', 4500.00, 'Administration', NULL, 1, 'Paid', 'Bank Transfer'),
('2023-04-20', 'Maintenance', 'Equipment', 'Printer repair and service', 280.00, 'Operations', 5, 2, 'Paid', 'Cash'),
('2023-05-15', 'Rent', 'Office Space', 'Monthly office rent - Muscat HQ', 4500.00, 'Administration', NULL, 1, 'Paid', 'Bank Transfer'),
('2023-05-25', 'IT', 'Hardware', 'New laptops for sales team (3)', 4200.00, 'IT', 19, 1, 'Paid', 'Bank Transfer'),
('2023-06-15', 'Rent', 'Office Space', 'Monthly office rent - Muscat HQ', 4500.00, 'Administration', NULL, 1, 'Paid', 'Bank Transfer'),
('2023-06-20', 'HR', 'Recruitment', 'Job posting fees - LinkedIn', 450.00, 'Human Resources', 4, 1, 'Paid', 'Credit Card'),
-- 2024 Expenses
('2024-01-15', 'Rent', 'Office Space', 'Monthly office rent - Muscat HQ', 4800.00, 'Administration', NULL, 1, 'Paid', 'Bank Transfer'),
('2024-01-15', 'Utilities', 'Electricity', 'Monthly electricity bill', 980.00, 'Administration', NULL, 2, 'Paid', 'Bank Transfer'),
('2024-01-20', 'Marketing', 'Advertising', 'Social media campaign Q1', 2500.00, 'Sales', 3, 1, 'Paid', 'Credit Card'),
('2024-02-15', 'Rent', 'Office Space', 'Monthly office rent - Muscat HQ', 4800.00, 'Administration', NULL, 1, 'Paid', 'Bank Transfer'),
('2024-02-20', 'IT', 'Software', 'CRM system upgrade', 3200.00, 'IT', 19, 1, 'Approved', 'Bank Transfer'),
('2024-03-01', 'Travel', 'Accommodation', 'Client meeting - Dubai trip', 1200.00, 'Sales', 6, 3, 'Pending', NULL),
('2024-03-05', 'Office Supplies', 'Stationery', 'Monthly office supplies', 350.00, 'Administration', NULL, 2, 'Pending', NULL);

-- =============================================
-- BUDGET DATA
-- =============================================
INSERT INTO budget (fiscal_year, fiscal_month, department, category, budgeted_amount, actual_amount) VALUES
-- 2024 Budget
(2024, 1, 'Sales', 'Salaries', 25000.00, 24500.00),
(2024, 1, 'Sales', 'Marketing', 5000.00, 4700.00),
(2024, 1, 'Sales', 'Travel', 2000.00, 1850.00),
(2024, 1, 'Finance', 'Salaries', 15000.00, 14800.00),
(2024, 1, 'Finance', 'Software', 1000.00, 950.00),
(2024, 1, 'Human Resources', 'Salaries', 8000.00, 7800.00),
(2024, 1, 'Human Resources', 'Training', 2000.00, 1500.00),
(2024, 1, 'Operations', 'Salaries', 12000.00, 11500.00),
(2024, 1, 'Operations', 'Equipment', 3000.00, 2800.00),
(2024, 1, 'IT', 'Salaries', 10000.00, 9800.00),
(2024, 1, 'IT', 'Infrastructure', 4000.00, 3500.00),
(2024, 1, 'Administration', 'Rent', 5000.00, 4800.00),
(2024, 1, 'Administration', 'Utilities', 1500.00, 1200.00),
-- February 2024
(2024, 2, 'Sales', 'Salaries', 25000.00, 24800.00),
(2024, 2, 'Sales', 'Marketing', 5000.00, 5500.00),
(2024, 2, 'Sales', 'Travel', 2000.00, 2200.00),
(2024, 2, 'Finance', 'Salaries', 15000.00, 14800.00),
(2024, 2, 'Human Resources', 'Salaries', 8000.00, 7800.00),
(2024, 2, 'Operations', 'Salaries', 12000.00, 12000.00),
(2024, 2, 'IT', 'Salaries', 10000.00, 9800.00),
(2024, 2, 'IT', 'Software', 2000.00, 3200.00),
(2024, 2, 'Administration', 'Rent', 5000.00, 4800.00);

-- =============================================
-- ATTENDANCE DATA (Sample for one month)
-- =============================================
INSERT INTO attendance (employee_id, attendance_date, check_in, check_out, status, hours_worked, overtime_hours) VALUES
-- Week 1 - March 2024
(6, '2024-03-03', '08:00', '17:00', 'Present', 8.0, 0),
(6, '2024-03-04', '08:15', '17:30', 'Late', 8.25, 0),
(6, '2024-03-05', '08:00', '18:00', 'Present', 9.0, 1.0),
(6, '2024-03-06', '08:00', '17:00', 'Present', 8.0, 0),
(6, '2024-03-07', '08:00', '17:00', 'Present', 8.0, 0),
(7, '2024-03-03', '08:00', '17:00', 'Present', 8.0, 0),
(7, '2024-03-04', '08:00', '17:00', 'Present', 8.0, 0),
(7, '2024-03-05', NULL, NULL, 'Absent', 0, 0),
(7, '2024-03-06', '08:00', '17:00', 'Present', 8.0, 0),
(7, '2024-03-07', '08:30', '17:00', 'Late', 7.5, 0),
(8, '2024-03-03', '08:00', '17:00', 'Present', 8.0, 0),
(8, '2024-03-04', '08:00', '17:00', 'Present', 8.0, 0),
(8, '2024-03-05', '08:00', '17:00', 'Present', 8.0, 0),
(8, '2024-03-06', '08:00', '13:00', 'Half Day', 4.0, 0),
(8, '2024-03-07', '08:00', '19:00', 'Present', 10.0, 2.0),
(11, '2024-03-03', '08:00', '17:00', 'Present', 8.0, 0),
(11, '2024-03-04', '08:00', '17:00', 'Present', 8.0, 0),
(11, '2024-03-05', '08:00', '17:00', 'Present', 8.0, 0),
(11, '2024-03-06', NULL, NULL, 'On Leave', 0, 0),
(11, '2024-03-07', NULL, NULL, 'On Leave', 0, 0);

-- =============================================
-- SALES TARGETS DATA
-- =============================================
INSERT INTO sales_targets (fiscal_year, fiscal_month, region, employee_id, target_amount, achieved_amount) VALUES
-- 2024 Targets
(2024, 1, 'Muscat', 6, 50000.00, 52500.00),
(2024, 1, 'Dhofar', 7, 30000.00, 28000.00),
(2024, 1, 'Al Batinah', 8, 35000.00, 33500.00),
(2024, 1, 'Al Dakhiliyah', 9, 25000.00, 26200.00),
(2024, 1, NULL, NULL, 150000.00, 148500.00),
(2024, 2, 'Muscat', 6, 55000.00, 58000.00),
(2024, 2, 'Dhofar', 7, 32000.00, 30500.00),
(2024, 2, 'Al Batinah', 8, 38000.00, 39200.00),
(2024, 2, 'Al Dakhiliyah', 9, 28000.00, 27500.00),
(2024, 2, NULL, NULL, 160000.00, 163200.00),
(2024, 3, 'Muscat', 6, 60000.00, 45000.00),
(2024, 3, 'Dhofar', 7, 35000.00, 22000.00),
(2024, 3, 'Al Batinah', 8, 40000.00, 28000.00),
(2024, 3, 'Al Dakhiliyah', 9, 30000.00, 18000.00),
(2024, 3, NULL, NULL, 175000.00, 120000.00);

-- =============================================
-- INVENTORY TRANSACTIONS DATA
-- =============================================
INSERT INTO inventory_transactions (product_id, transaction_date, transaction_type, quantity, unit_cost, reference_type, reference_id, performed_by, notes) VALUES
-- Stock receipts
(1, '2024-01-05', 'IN', 50, 320.00, 'Purchase', 1001, 16, 'Stock replenishment'),
(2, '2024-01-05', 'IN', 200, 12.00, 'Purchase', 1001, 16, 'Stock replenishment'),
(9, '2024-01-10', 'IN', 500, 10.00, 'Purchase', 1002, 16, 'Bulk paper order'),
(14, '2024-01-15', 'IN', 30, 180.00, 'Purchase', 1003, 16, 'New chair shipment'),
-- Sales (stock out)
(1, '2024-01-10', 'OUT', 3, 320.00, 'Order', 67, 17, 'Order fulfillment'),
(2, '2024-01-10', 'OUT', 10, 12.00, 'Order', 67, 17, 'Order fulfillment'),
(14, '2024-01-15', 'OUT', 8, 180.00, 'Order', 68, 17, 'Order fulfillment'),
-- Adjustments
(5, '2024-02-01', 'ADJUST', -2, 45.00, 'Audit', NULL, 16, 'Inventory count adjustment'),
(21, '2024-02-15', 'DAMAGED', -5, 4.00, 'Damage', NULL, 17, 'Water damage in warehouse'),
-- Returns
(1, '2024-02-20', 'RETURN', 1, 320.00, 'Order', 80, 17, 'Customer return - defective');
