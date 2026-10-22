select current_database();

select customer_id, invoice_no, invoice_date,quantity, unit_price,
(quantity*unit_price) as revenue,
sum(quantity*unit_price)
over(PARTITION BY customer_id order by invoice_date
range between interval '14 days' preceding and CURRENT ROW ) 
as revenue_last_14_days
from retail_sales
where customer_id is not null
order by customer_id, invoice_date
limit 3

select stock_code, country, invoice_date, quantity,
round(avg(quantity) over(
    partition by stock_code, country order by invoice_date
    range between INTERVAL '7 days' preceding and current row
),2) as priemer
from retail_sales
where quantity>1
order by stock_code, country, invoice_date

with orders as (
    select distinct customer_id, invoice_no, invoice_date::date as invoice_date
    from retail_sales where customer_id is not null),
w_next as (
    select customer_id, invoice_no, invoice_date, 
    lead(invoice_date) over (partition by customer_id order by invoice_date)  
    as next_invoice_date from orders)
select customer_id, invoice_no, invoice_date,next_invoice_date,
next_invoice_date- invoice_date as days_to
from w_next
where next_invoice_date is not NULL
order by days_to desc
limit 4


with price_differ as (
    select stock_code, invoice_no, invoice_date,unit_price,
    lag(unit_price) over (PARTITION BY stock_code order by invoice_date
    ) as previus_price from retail_sales
)
select stock_code, invoice_no, invoice_date, previus_price,
unit_price as current_price, (unit_price - previus_price) as price_diffrence
from price_differ where previus_price is not NULL and 
unit_price != previus_price
order by invoice_date 
limit 20

with zosk as (
    select customer_id, sum((quantity * unit_price)) as total_ammount
    from retail_sales
    where customer_id is not null 
    group by customer_id
    
)
select customer_id, total_ammount,  
ntile(4) over( order by total_ammount desc)
as sales_quartile
from zosk
order by  total_ammount desc 

with celkom as (
    select country,date_trunc('month',invoice_date) as month,
    sum((quantity*unit_price)) as total_ammount
    from retail_sales
    group by date_trunc('month',invoice_date), country
)
select country, month, total_ammount,
ntile(4) over(partition by country ORDER by total_ammount desc) 
as sales_quartile
from celkom
order by country, month 

with rr as (select customer_id, invoice_no, invoice_date, stock_code, description, 
quantity, unit_price ,
ROW_NUMBER() over (partition by customer_id order by invoice_date ) as ra
from retail_sales)
select customer_id, invoice_no, invoice_date, stock_code, description, 
quantity, unit_price from rr
where ra =1
order by customer_id asc

with idk as (
    select invoice_no, stock_code, description, quantity, unit_price, 
    (quantity*unit_price)as ammount, 
    ROW_NUMBER() over (partition by invoice_no order by 
    (quantity*unit_price) desc )
    as row_num
    from retail_sales
)
select invoice_no, stock_code, description, quantity, unit_price,
ammount,row_num from idk 
where row_num <4
order by invoice_no

with asd as(
    select country, date_trunc('month',invoice_date) as mesiac, customer_id,
    sum((quantity*unit_price)) as total_ammount
    from retail_sales
    where customer_id is not null 
    group by customer_id, country, date_trunc('month',invoice_date), customer_id
    
),
asdf as (
    select country, mesiac, customer_id, total_ammount,
    dense_rank() over (partition by mesiac, country order by total_ammount desc) as qwe
    from asd
    
)
select country, mesiac, customer_id, total_ammount, qwe 
from asdf 
where qwe<6
order by country, mesiac, qwe ,customer_id asc

with zxc as (
    select invoice_no, stock_code, description, quantity, unit_price,
    dense_rank() over(partition by invoice_no order by unit_price desc )
    as price_rank
    from retail_sales
)
select invoice_no, stock_code, description, quantity, unit_price, price_rank
from zxc 
where price_rank <6
order by invoice_no,price_rank, stock_code

