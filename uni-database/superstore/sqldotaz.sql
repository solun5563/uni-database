SELECT * FROM customers;
select * from products;
select * from orders;
SELECT orders.order_id, customers.customer_name, orders.sales
FROM orders
JOIN customers ON orders.customer_id = customers.customer_id
WHERE orders.sales > 500
ORDER BY orders.sales DESC;


select orders.order_id, customers.customer_name, products.category, orders.sales 
from customers 
join orders on customers.customer_id = orders.customer_id join products on orders.product_id = products.product_id;

select region, sum(orders.sales) as total 
from customers 
left join orders on orders.customer_id=customers.customer_id 
group by customers.region

select products.product_name, sum(orders.sales) as total_sales
from products 
left join orders on orders.product_id = products.product_id 
left join customers on customers.customer_id = orders.customer_id
group by products.product_name 

select customer_name, order_id, sales
from products 
full OUTER join orders on orders.product_id = products.product_id 
full OUTER join customers on customers.customer_id = orders.customer_id

select region, sum(sales) as totall
from products
join orders on orders.product_id = products.product_id 
join customers on customers.customer_id = orders.customer_id
GROUP BY customers.region


SELECT customers.customer_name, COUNT(orders.order_id) AS pocet
FROM customers
LEFT JOIN orders ON orders.customer_id = customers.customer_id
GROUP BY customers.customer_name;

SELECT products.category, AVG(orders.discount) AS przl
FROM products
JOIN orders ON orders.product_id = products.product_id 
JOIN customers ON customers.customer_id = orders.customer_id
GROUP BY products.category;

SELECT customer_name, sum(sales) as celkom
FROM products
JOIN orders ON orders.product_id = products.product_id 
JOIN customers ON customers.customer_id = orders.customer_id
GROUP BY customer_name
HAVING sum(sales) > 2000

SELECT region,sum(sales) as celkom, avg(discount) as priemer, count(order_id) as pocet
FROM products
JOIN orders ON orders.product_id = products.product_id 
JOIN customers ON customers.customer_id = orders.customer_id
GROUP BY region

SELECT customers.region,COUNT(CASE WHEN orders.sales > 1000 THEN 1 END) AS high_value,
COUNT(CASE WHEN orders.sales <= 1000 THEN 1 END) AS low_value
FROM customers
JOIN orders ON customers.customer_id = orders.customer_id
GROUP BY customers.region;

SELECT customers.customer_name,SUM(orders.sales) AS celkovy_predaj,
AVG(orders.discount) AS priemerna_zlava,COUNT(orders.order_id) AS pocet_objednavok,
    CASE 
        WHEN SUM(orders.sales) > 2500 THEN 'VIP'
        ELSE 'REGULAR'
    END AS typ_zakaznika
FROM customers
JOIN orders ON customers.customer_id = orders.customer_id
GROUP BY customers.customer_name
ORDER BY celkovy_predaj DESC;