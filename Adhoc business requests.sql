/*

Ad-hoc business requests

 */
-- Adhoc 1 --

WITH revenue_by_campaign as
(
SELECT 
	campaign_name,
    sum(base_price * quantity_sold_before_promo) totalrevenue_before_promo,
	sum(base_price * quantity_sold_after_promo) totalrevenue_after_promo
FROM
	fact_events events JOIN 
	dim_campaigns campaigns ON 
	events.campaign_id = campaigns.campaign_id
    GROUP BY campaign_name
    )
SELECT
	campaign_name,
	concat(round(totalrevenue_before_promo / 1000000,0), " M") as revenue_before_promo,
	concat(round(totalrevenue_after_promo / 1000000,0), " M") as revenue_after_promo
FROM
	revenue_by_campaign
order by
	campaign_name;
    
----------------------------------------------------------------------------------------------------------
    
-- Adhoc_2
    
    SELECT 
    city, COUNT(store_id) AS store_count
FROM
    dim_stores
GROUP BY city
ORDER BY store_count DESC;

----------------------------------------------------------------------------------------------------------

-- Adhoc_3

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
    
----------------------------------------------------------------------------------------------------------

-- Adhoc_4

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
LIMIT 5;

----------------------------------------------------------------------------------------------------------

-- Adhoc_5

SELECT 
    product_name, base_price, promo_type
FROM
    fact_events events
        JOIN
    dim_products products ON events.product_code = products.product_code
WHERE
    base_price > 500 AND promo_type = 'BOGOF'
GROUP BY product_name, base_price, promo_type
ORDER BY base_price DESC;