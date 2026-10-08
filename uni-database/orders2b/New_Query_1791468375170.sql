create Table orders(
    order_id varchar(20) PRIMARY KEY,
    customer_id  varchar(20) not null,
    product_id  varchar(20) not null,
    order_date  date not null,
    region  VARCHAR(20) not NULL,
    category  VARCHAR(50) not NULL,
    ship_mode  VARCHAR(30) NOT NULL,
    sales  numeric(10,2) not null,
    profit  numeric(10,2) not NULL
)

alter DATABASE retail_sales set datestyle to 'ISO, MDY';

select * from orders

create procedure get_customer_sales1(p_customer_id varchar(20))
language plpgsql
as $procedure$
declare p_total_sales numeric(10,2);
begin
    select sum(sales) 
    into p_total_sales
    from orders
    where customer_id = p_customer_id;
    raise notice 'Total sales for customer %: %', p_customer_id, p_total_sales;

end;
$procedure$;

call get_customer_sales1('C001');


create Procedure apply_regional_discount(p_region_name varchar(20), p_discount_rate numeric(10,2))
language plpgsql
as $procedure$
begin 
update orders
set sales = sales * (1 - p_discount_rate)
where region = p_region_name;
raise notice 'discount in % set for %', p_region_name, p_discount_rate;
end;
$procedure$;

call apply_regional_discount('West', 0.1);

call apply_regional_discount('West', 0.1);

select sales from orders where region = 'West' limit 5

create Procedure get_sales_between (p_start_date date, p_end_date date)
language plpgsql
as $procedure$
declare p_sales numeric(10,2);
begin
select sum(sales) 
into p_sales
from orders 
where order_date BETWEEN p_start_date AND p_end_date;
raise NOTICE 'total sales between % and % are %',
p_start_date, p_end_date, p_sales;

end;
$procedure$;

call  get_sales_between('2024-01-01', '2024-03-31');

