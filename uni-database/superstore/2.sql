create view high_value_customers1 as
select c.customer_id,
c.customer_name,
sum(o.sales) as total_sales
from customers c join orders o on c.customer_id = o.customer_id
group by c.customer_id, c.customer_name
having sum(o.sales) > 2000;

create view regional_monthly_sales1 as 
select c.region,
date_trunc('month', o.order_date) as mesiac,
sum(o.sales) as total_sales
from customers c join orders o on c.customer_id = o.customer_id
where c.region = 'West'
group by  c.region , date_trunc('month', o.order_date)

create view analyst_orders as 
select order_id,
customer_id,
product_id,
sales,
quantity,
discount
from orders

select * from analyst_orders

explain select * from orders where customer_id = 'C12345';

create INDEX idx_orders_customer_id on orders(customer_id);
select * from orders where customer_id = 'C001';
explain select * from orders where customer_id = 'C001';

create index idx_orders_order_date on orders(order_date)

select date_trunc('month', order_date)as mesiac, sum(sales) from orders
group by date_trunc('month', order_date) order by date_trunc('month', order_date) asc


create index idx_orders_region_category on orders(customer_id, order_date)

select c.region, date_trunc('month',order_date ), c.customer_name, o.profit from customers c 
join orders o on c.customer_id = o.customer_id
where c.region = 'West' and date_trunc('month', order_date) >= '2024-01-01' 
group by c.region, date_trunc('month', order_date), customer_name, o.profit


EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE customer_id = 'C001';




