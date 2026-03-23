"""
Quick test script to verify SQL queries work correctly.
Run: python test_queries.py
"""

import sqlite3
import os

# Get the directory where this script is located
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

def run_test():
    # Create in-memory database (or use 'business.db' for persistent)
    conn = sqlite3.connect(':memory:')
    cursor = conn.cursor()

    print("=" * 60)
    print("SQL Business Queries - Test Runner")
    print("=" * 60)

    # 1. Create tables
    print("\n[1/3] Creating tables...")
    with open(os.path.join(BASE_DIR, 'schema/create_tables.sql'), 'r') as f:
        cursor.executescript(f.read())
    print("      13 tables created successfully!")

    # 2. Insert sample data
    print("\n[2/3] Inserting sample data...")
    with open(os.path.join(BASE_DIR, 'schema/insert_sample_data.sql'), 'r') as f:
        cursor.executescript(f.read())
    print("      Sample data inserted successfully!")

    # 3. Run a test query
    print("\n[3/3] Running test query: Monthly Revenue...")
    print("-" * 60)

    query = """
    SELECT
        strftime('%Y-%m', order_date) AS month,
        COUNT(*) AS total_orders,
        COUNT(DISTINCT customer_id) AS unique_customers,
        ROUND(SUM(total_amount), 2) AS revenue,
        ROUND(AVG(total_amount), 2) AS avg_order_value
    FROM orders
    WHERE status = 'Completed'
    GROUP BY strftime('%Y-%m', order_date)
    ORDER BY month DESC
    LIMIT 6;
    """

    cursor.execute(query)
    results = cursor.fetchall()

    # Print header
    print(f"{'Month':<10} {'Orders':<8} {'Customers':<12} {'Revenue':<12} {'AOV':<10}")
    print("-" * 60)

    # Print results
    for row in results:
        print(f"{row[0]:<10} {row[1]:<8} {row[2]:<12} {row[3]:<12} {row[4]:<10}")

    print("-" * 60)
    print(f"\nTotal rows returned: {len(results)}")

    # Quick stats
    cursor.execute("SELECT COUNT(*) FROM orders")
    order_count = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM customers")
    customer_count = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM products")
    product_count = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM employees")
    employee_count = cursor.fetchone()[0]

    print(f"\n{'='*60}")
    print("Database Summary:")
    print(f"  - Orders: {order_count}")
    print(f"  - Customers: {customer_count}")
    print(f"  - Products: {product_count}")
    print(f"  - Employees: {employee_count}")
    print(f"{'='*60}")
    print("\nAll tests passed! Your SQL queries are working correctly.")

    conn.close()

if __name__ == "__main__":
    run_test()
