WITH temptable as (
SELECT
	category,product_name,
	base_price * quantity_sold_after_promo AS x,
	base_price * quantity_sold_before_promo AS y
FROM
	fact_events events join
	dim_products products on 
	events.product_code = products.product_code
    )
SELECT
	product_name, category,
    round((sum(x) - sum(y)) * 100/sum(y), 2) IR_percentage
FROM 
	temptable 
GROUP BY product_name, category
ORDER BY IR_percentage DESC
LIMIT 5