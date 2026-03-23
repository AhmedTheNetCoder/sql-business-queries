# Business Context

This document provides the business context for the sample data and queries in this repository.

## Company Overview

The sample data represents a **B2B distribution company** operating in Oman and the GCC region. The company:

- Sells office equipment, electronics, and furniture to businesses
- Operates across multiple regions in Oman
- Has a diverse customer base from SMBs to large enterprises
- Works with multiple suppliers for product sourcing

## Business Model

### Revenue Streams
- **Product Sales**: Primary revenue from selling products to business customers
- **Customer Segments**: SMB, Corporate, and Enterprise tiers with different pricing and credit terms

### Key Metrics Tracked
- Revenue and order volume
- Customer acquisition and retention
- Product profitability
- Operational efficiency

## Data Entities

### Customers
Business customers are classified into three tiers:
- **SMB (Small/Medium Business)**: Smaller companies, lower credit limits
- **Corporate**: Mid-size companies with moderate credit
- **Enterprise**: Large organizations with high credit limits and volume

### Products
Products are organized into categories:
- **Electronics**: Laptops, monitors, accessories
- **Furniture**: Desks, chairs, office furniture
- **Supplies**: Office supplies and consumables

### Regions
The company operates across Oman's governorates:
- Muscat (capital, highest volume)
- Al Batinah North & South
- Dhofar
- Al Dakhiliyah
- Al Sharqiyah North & South
- Al Dhahirah
- Musandam
- Al Buraimi
- Al Wusta

### Suppliers
Multiple suppliers provide products with varying:
- Payment terms (15, 30, 45, 60 days)
- Quality ratings (1-5 scale)
- Product specializations

## Business Processes

### Order-to-Cash
1. Customer places order
2. Order is processed (status: Pending → Processing)
3. Order is fulfilled (status: Completed)
4. Invoice is generated
5. Payment is collected

### Procure-to-Pay
1. Inventory levels monitored
2. Reorder alerts triggered
3. Purchase orders created
4. Stock received and updated
5. Supplier invoices processed

### Employee Management
- Departments: Sales, Operations, HR, Finance, IT, Marketing
- Attendance tracking
- Salary management
- Performance monitoring

## Key Business Questions by Department

### Sales Department
- What is our monthly revenue trend?
- Who are our top customers?
- Which products sell best?
- Are we meeting sales targets?
- How do new customers compare to returning customers?

### Finance Department
- What is our accounts receivable aging?
- How does actual spending compare to budget?
- What is our cash flow position?
- Which products have the best margins?
- What are our financial ratios?

### Operations Department
- What is our current inventory status?
- Which products need reordering?
- How efficient is order fulfillment?
- How are suppliers performing?
- What is our warehouse efficiency?

### HR Department
- What is our current headcount?
- What is our turnover rate?
- How are salaries distributed?
- What are the hiring trends?
- What is our absenteeism rate?

### Executive Team
- What are the key performance indicators?
- Which customers/products drive most revenue (80/20)?
- What is customer lifetime value?
- Which customers are at risk of churning?
- What are the trends over time?

## Sample Data Characteristics

### Time Period
- Orders span 2023-2024
- Sufficient data for trend analysis and YoY comparisons

### Volume
- ~80 orders
- ~20 customers
- ~25 products
- ~15 employees
- ~10 suppliers

### Data Quality
- Realistic Oman-based company and contact names
- Appropriate currency (OMR - Omani Rial)
- Realistic pricing and salary ranges
- Proper phone number formats

## Using This Data

### For Learning
- Practice SQL queries on realistic business data
- Understand common business metrics
- Learn to translate business questions into SQL

### For Demonstrations
- Show query results in interviews
- Demonstrate analytical thinking
- Present business insights

### For Portfolio
- Showcase SQL skills
- Demonstrate understanding of business analytics
- Show ability to work with real-world scenarios

## Currency and Regional Notes

- **Currency**: Omani Rial (OMR)
- **Date Format**: ISO 8601 (YYYY-MM-DD)
- **Work Week**: Sunday-Thursday (Oman standard)
- **Language**: English (business language in GCC)
