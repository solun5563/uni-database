CREATE TABLE retail_sales(
    invoice_no VARCHAR(20),
    stock_code varchar(50),
    description VARCHAR,
    quantity int,
    invoice_date TIMESTAMP,
    unit_price numeric(10,2),
    customer_id int,
    country varchar(100)
);

ALTER DATABASE retail SET datestyle TO 'ISO, DMY';

select * from retail_sales