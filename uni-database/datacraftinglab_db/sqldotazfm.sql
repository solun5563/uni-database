select * from flourmills_sales;
select sales_rep from flourmills_sales

select product_name, total_amount from flourmills_sales where total_amount > (select AVG(total_amount) from flourmills_sales)
ORDER BY total_amount DESC;

select * from flourmills_sales
where product_category = (
    select product_category
    from flourmills_sales
    GROUP BY product_category
    order BY sum(total_amount) DESC
    limit 1
)
order by sales_id asc

select product_name, total_amount, 
(select avg(total_amount) from flourmills_sales) as avgs from flourmills_sales

select product_name, total_amount,
total_amount/(select sum(total_amount) from flourmills_sales) as priemer from flourmills_sales

SELECT month, monthly_sales
FROM (
    SELECT DATE_PART('month', sale_date) AS month,
           SUM(total_amount) AS monthly_sales
    FROM flourmills_sales
    GROUP BY DATE_PART('month', sale_date)
) AS sub
ORDER BY monthly_sales DESC;

SELECT product_category, total_sales
FROM (
    SELECT product_category,
           SUM(total_amount) AS total_sales
    FROM flourmills_sales
    GROUP BY product_category
) AS sub
WHERE total_sales > 50000000
ORDER BY total_sales DESC;

SELECT product_name, product_category, total_amount
FROM flourmills_sales f1
WHERE total_amount > (
    SELECT AVG(total_amount)
    FROM flourmills_sales f2
    WHERE f2.product_category = f1.product_category
);

SELECT f1.product_name,
       f1.region,
       f1.total_amount,
       (
           SELECT MIN(f2.total_amount)
           FROM flourmills_sales f2
           WHERE f2.region = f1.region
       ) AS region_min_amount
FROM flourmills_sales f1
ORDER BY f1.sales_id ASC
LIMIT 5;

SELECT f1.*
FROM flourmills_sales f1
WHERE EXISTS (
    SELECT 1
    FROM flourmills_sales f2
    WHERE f2.product_name = f1.product_name
    HAVING COUNT(DISTINCT EXTRACT(MONTH FROM f2.sale_date)) > 1
);

SELECT f1.product_category,
       f1.product_name,
       f1.total_amount
FROM flourmills_sales f1
WHERE EXISTS (
    SELECT 1
    FROM flourmills_sales f2
    WHERE f2.product_category = f1.product_category
      AND f2.total_amount > 200000
)
ORDER BY f1.sales_id ASC;

SELECT DISTINCT f1.product_category
FROM flourmills_sales f1
WHERE EXISTS (
    SELECT 1
    FROM flourmills_sales f2
    WHERE f2.product_category = f1.product_category
    HAVING COUNT(DISTINCT f2.region) > 3
)
ORDER BY f1.product_category ASC;

SELECT f1.*
FROM flourmills_sales f1
WHERE EXISTS (
    SELECT 1
    FROM flourmills_sales f2
    WHERE f2.region = f1.region
      AND EXTRACT(YEAR FROM f2.sale_date) = 2024
);

SELECT DISTINCT f1.product_category
FROM flourmills_sales f1
WHERE NOT EXISTS (
    SELECT 1
    FROM flourmills_sales f2
    WHERE f2.product_category = f1.product_category
      AND f2.total_amount > 500000
);

SELECT DISTINCT f1.region
FROM flourmills_sales f1
WHERE NOT EXISTS (
    SELECT 1
    FROM flourmills_sales f2
    WHERE f2.region = f1.region
      AND f2.product_category = 'Flour'
);