select products.product_name,events.base_price,events.promo_type
from fact_events events join 
dim_products products on 
events.product_code = products.product_code
where events.base_price > 500 and events.promo_type = "BOGOF";