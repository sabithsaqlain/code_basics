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
	campaign_name