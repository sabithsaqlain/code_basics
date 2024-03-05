WITH 
	CTE AS (
	SELECT category,
	sum(quantity_sold_after_promo) x,
    sum(quantity_sold_before_promo) y
FROM
	fact_events events JOIN 
	dim_products products ON 
	events.product_code = products.product_code
WHERE 
	campaign_id = "CAMP_DIW_01"
	GROUP BY category
    )
SELECT
	category,
    round((x-y) * 100/ y,1) ISU_Percentage,
    rank() over(order by  round((x-y) * 100/ y,1) desc) category_rank
FROM
	CTE;