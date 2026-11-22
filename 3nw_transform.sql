\set ON_ERROR_STOP on
\encoding UTF8

BEGIN;

CREATE SCHEMA IF NOT EXISTS gold;

CREATE TABLE IF NOT EXISTS gold.dim_category (
    category_key INT PRIMARY KEY,
    category_name VARCHAR(25) NOT NULL
);

CREATE TABLE IF NOT EXISTS gold.dim_supplier (
    supplier_key INT PRIMARY KEY,
    supplier_name VARCHAR(50) NOT NULL,
    country VARCHAR(15)
);

CREATE TABLE IF NOT EXISTS gold.dim_product (
    product_key INT PRIMARY KEY,
    product_name VARCHAR(50) NOT NULL,
    category_key INT NOT NULL REFERENCES gold.dim_category(category_key),
    supplier_key INT NOT NULL REFERENCES gold.dim_supplier(supplier_key)
);

CREATE TABLE IF NOT EXISTS gold.dim_customer (
    customer_key INT PRIMARY KEY,
    customer_name VARCHAR(50) NOT NULL,
    city VARCHAR(20),
    country VARCHAR(15)
);

CREATE TABLE IF NOT EXISTS gold.dim_employee (
    employee_key INT PRIMARY KEY,
    first_name VARCHAR(15) NOT NULL,
    last_name VARCHAR(15) NOT NULL
);

CREATE TABLE IF NOT EXISTS gold.dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE NOT NULL,
    day SMALLINT,
    month SMALLINT,
    quarter SMALLINT,
    year SMALLINT
);

CREATE TABLE IF NOT EXISTS gold.fact_sales (
    sales_key INT PRIMARY KEY,
    date_key INT NOT NULL REFERENCES gold.dim_date(date_key),
    customer_key INT NOT NULL REFERENCES gold.dim_customer(customer_key),
    product_key INT NOT NULL REFERENCES gold.dim_product(product_key),
    employee_key INT NOT NULL REFERENCES gold.dim_employee(employee_key),
    quantity INT NOT NULL,
    sales_amount DECIMAL(12,2) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_fact_sales_date ON gold.fact_sales(date_key);
CREATE INDEX IF NOT EXISTS idx_fact_sales_customer ON gold.fact_sales(customer_key);
CREATE INDEX IF NOT EXISTS idx_fact_sales_product ON gold.fact_sales(product_key);
CREATE INDEX IF NOT EXISTS idx_fact_sales_employee ON gold.fact_sales(employee_key);

TRUNCATE gold.fact_sales, gold.dim_product, gold.dim_category, gold.dim_supplier,
         gold.dim_customer, gold.dim_employee, gold.dim_date;

INSERT INTO gold.dim_category (category_key, category_name)
SELECT category_id, category_name
FROM silver.stg_categories
ORDER BY category_id;

INSERT INTO gold.dim_supplier (supplier_key, supplier_name, country)
SELECT supplier_id, supplier_name, country
FROM silver.stg_suppliers
ORDER BY supplier_id;

INSERT INTO gold.dim_product (product_key, product_name, category_key, supplier_key)
SELECT product_id, product_name, category_id, supplier_id
FROM silver.stg_products
ORDER BY product_id;

INSERT INTO gold.dim_customer (customer_key, customer_name, city, country)
SELECT customer_id, customer_name, city, country
FROM silver.stg_customers
ORDER BY customer_id;

INSERT INTO gold.dim_employee (employee_key, first_name, last_name)
SELECT employee_id, first_name, last_name
FROM silver.stg_employees
ORDER BY employee_id;

INSERT INTO gold.dim_date (date_key, full_date, day, month, quarter, year)
SELECT TO_CHAR(d, 'YYYYMMDD')::INT,
       d,
       EXTRACT(day FROM d)::INT,
       EXTRACT(month FROM d)::INT,
       EXTRACT(quarter FROM d)::INT,
       EXTRACT(year FROM d)::INT
FROM (
    SELECT GENERATE_SERIES(
        (SELECT MIN(order_date) FROM silver.stg_orders),
        (SELECT MAX(order_date) FROM silver.stg_orders),
        INTERVAL '1 day')::DATE AS d
) s;

INSERT INTO gold.fact_sales (sales_key, date_key, customer_key, product_key, employee_key, quantity, sales_amount)
SELECT od.order_detail_id,
       TO_CHAR(o.order_date, 'YYYYMMDD')::INT,
       o.customer_id,
       od.product_id,
       o.employee_id,
       od.quantity,
       od.quantity * p.price
FROM silver.stg_order_details od
JOIN silver.stg_orders o ON o.order_id = od.order_id
JOIN silver.stg_products p ON p.product_id = od.product_id;

COMMIT;