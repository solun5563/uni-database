create Table flourmills_sales(
    sales_id int primary key,
    sale_date date not null,
    region VARCHAR(100),
    state VARCHAR(100),
    product_category VARCHAR(100),
    product_name VARCHAR(150),
    customer_type VARCHAR(100),
    customer_id int,
    quantity_sold int,
    unit_price decimal(10,2),
    discount_rate INT,
    payment_method VARCHAR(100),
    sales_rep VARCHAR(150),
    warehouse VARCHAR(100),
    delivery_status VARCHAR(100),
    order_channel varchar(100),
    batch_number INT,
    production_date date,
    total_amount decimal(10,2)
);
select * from flourmills_sales;