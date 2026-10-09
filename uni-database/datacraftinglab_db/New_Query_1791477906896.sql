with daily_sales as (
    select sale_date, sum(total_amount) as ts from flourmills_sales
    group by sale_date
)
select * from daily_sales where ts > 3000000
order by ts desc
limit 5 

with category_sales as (
    select product_category, sum(total_amount) as total_sales
    from flourmills_sales
    group by product_category
)
select * from category_sales 
order by total_sales desc

with category_sales as (
    select product_category, product_name,
           sum(total_amount) as total_product_sales from flourmills_sales
    group by product_category, product_name
),
ranked_products as (
    select *, 
           rank() over (
               partition by product_category 
               order by total_product_sales desc
           ) as category_rank
    from category_sales
)
select * from ranked_products
where category_rank <= 3
order by product_category, category_rank

WITH customer_revenue AS (
    SELECT 
        customer_type,
        SUM(total_amount) AS revenue
    FROM flourmills_sales
    GROUP BY customer_type
),
total_calc AS (
    SELECT 
        customer_type,
        revenue,
        SUM(revenue) OVER () AS total_revenue,
        ROUND((revenue / SUM(revenue) OVER ()) * 100, 2) AS revenue_percentage
    FROM customer_revenue
)
SELECT 
    customer_type,
    revenue,
    total_revenue,
    revenue_percentage
FROM total_calc
ORDER BY revenue DESC;

WITH ranked_sales AS (
    SELECT 
        customer_id,
        product_name,
        sale_date,
        total_amount,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY sale_date DESC) AS rn
    FROM flourmills_sales
)
SELECT 
    customer_id,
    product_name,
    sale_date,
    total_amount
FROM ranked_sales
WHERE rn = 1
ORDER BY customer_id ASC;

WITH RECURSIVE date_range AS (
    SELECT MIN(sale_date)::date AS
     calendar_date, MAX(sale_date)::date AS max_date
    FROM flourmills_sales
    UNION ALL
    SELECT (calendar_date + INTERVAL '1 day')::date, max_date
    FROM date_range
    WHERE calendar_date < max_date
)
SELECT calendar_date
FROM date_range
ORDER BY calendar_date ASC;

WITH RECURSIVE monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', sale_date)::date AS month,
        SUM(total_amount) AS revenue
    FROM flourmills_sales
    GROUP BY DATE_TRUNC('month', sale_date)
),
ordered_months AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY month) AS rn,
        month,
        revenue
    FROM monthly_revenue
),
cumulative_target AS (
    SELECT 
        rn,
        month,
        revenue,
        revenue AS cumulative_revenue
    FROM ordered_months
    WHERE rn = 1
    
    UNION ALL
    
    SELECT 
        om.rn,
        om.month,
        om.revenue,
        ct.cumulative_revenue + om.revenue
    FROM cumulative_target ct
    JOIN ordered_months om ON om.rn = ct.rn + 1
    WHERE ct.cumulative_revenue < 500000000
)
SELECT 
    rn,
    month,
    revenue,
    cumulative_revenue
FROM cumulative_target
ORDER BY rn;

