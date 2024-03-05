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
