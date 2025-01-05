-- 1.City level fare and trip summary report

WITH CTE AS (
SELECT 
	city_name city,
    COUNT(trip_id) AS total_trips, 
    ROUND(AVG(fare_amount/distance_travelled_km), 2) AS avg_fare_per_km,
    ROUND(AVG(fare_amount), 2) AS avg_fare_per_trip
FROM 
	fact_trips JOIN dim_city USING (city_id)
GROUP BY 
	city_name
)    
SELECT
	*, ROUND(total_trips * 100/ (SELECT count(*) FROM fact_trips), 2) AS total_trips_pct_contribution
FROM 
	CTE
ORDER BY
	total_trips DESC ;
  
  
-----------------------------------------------------------------------------------------------------------------------------------	

-- 2.Month and city level target performance report

WITH actual_trip AS (
SELECT
	city_id, monthname(date) AS month, count(trip_id) AS actual_trips 
FROM
	fact_trips
GROUP BY 
city_id, month
),
target_trip AS (
SELECT
	city_id, monthname(month) AS month, total_target_trips AS target_trips 
FROM
	targets_db.monthly_target_trips
)
SELECT 
	city_name AS city, month, actual_trips, target_trips,
	CASE WHEN actual_trips > target_trips THEN "Above Target" 
	WHEN actual_trips <= target_trips THEN "Below target"
	END performance_status,
	(actual_trips - target_trips) *100 / actual_trips AS pct_difference  
FROM 
	actual_trip 
		JOIN target_trip USING(city_id, month)
		JOIN dim_city USING (city_id)
ORDER BY
	city, month ;
 
 
-----------------------------------------------------------------------------------------------------------------------------------

-- 3.City level passenger trip frequency report

WITH CTE AS
(
SELECT city_id,
SUM(CASE WHEN trip_count = '2-Trips' THEN repeat_passenger_count END) AS 2_trips,
SUM(CASE WHEN trip_count = '3-Trips' THEN repeat_passenger_count END) AS 3_trips,
SUM(CASE WHEN trip_count = '4-Trips' THEN repeat_passenger_count END) AS 4_trips,
SUM(CASE WHEN trip_count = '5-Trips' THEN repeat_passenger_count END) AS 5_trips,
SUM(CASE WHEN trip_count = '6-Trips' THEN repeat_passenger_count END) AS 6_trips,
SUM(CASE WHEN trip_count = '7-Trips' THEN repeat_passenger_count END) AS 7_trips,
SUM(CASE WHEN trip_count = '8-Trips' THEN repeat_passenger_count END) AS 8_trips,
SUM(CASE WHEN trip_count = '9-Trips' THEN repeat_passenger_count END) AS 9_trips,
SUM(CASE WHEN trip_count = '10-Trips' THEN repeat_passenger_count END) AS 10_trips,
SUM(CASE WHEN trip_count IN('1-Trips','2-Trips','3-Trips','4-Trips','5-Trips','6-Trips','7-Trips','8-Trips','9-Trips','10-Trips') THEN repeat_passenger_count END) AS TOTAL
FROM 
	dim_repeat_trip_distribution
GROUP BY
	city_id)

SELECT city_name AS city,
ROUND(2_trips * 100/TOTAL,2) 2_trips,
ROUND(3_trips * 100/TOTAL,2) 3_trips,
ROUND(4_trips * 100/TOTAL,2) 4_trips,
ROUND(5_trips * 100/TOTAL,2) 5_trips,
ROUND(6_trips * 100/TOTAL,2) 6_trips,
ROUND(7_trips * 100/TOTAL,2) 7_trips,
ROUND(8_trips * 100/TOTAL,2) 8_trips,
ROUND(9_trips * 100/TOTAL,2) 9_trips,
ROUND(10_trips * 100/TOTAL,2) 10_trips
FROM 
	CTE JOIN dim_city USING (city_id) ;
 
 
-----------------------------------------------------------------------------------------------------------------------------------

-- 4. Cities with highest and lowest new passengers 

WITH new_passengers_count AS(
SELECT 
	city_name, 
	sum(new_passengers) AS total_new_passengers,
	dense_rank() over( order by sum(new_passengers) desc) AS rnk
FROM
	fact_passenger_summary JOIN dim_city USING(city_id)
GROUP BY
	city_name
)
(
SELECT
	city_name AS city, total_new_passengers,
	CASE WHEN rnk<=3 THEN "Top 3" END AS city_category
FROM
	new_passengers_count
WHERE rnk <=3
) 
UNION
(
SELECT
	city_name AS city, total_new_passengers,
	CASE WHEN rnk>=7 THEN "Bottom 3" END city_category
FROM new_passengers_count 
ORDER BY 
	rnk DESC 
LIMIT 3 ) ;


-----------------------------------------------------------------------------------------------------------------------------------

-- 5. Month with highest revenue for each city 

WITH month_level_revenue AS (
SELECT 
	city_id,
	monthname(date) AS month_name,
	sum(fare_amount) AS revenue
FROM
	fact_trips
GROUP BY 
	month_name, city_id
),
cte AS (
SELECT 
	city_id, month_name, revenue,
	revenue * 100/sum(revenue) OVER(PARTITION BY city_id) pct_contribution ,
	ROW_NUMBER() OVER(PARTITION BY city_id ORDER BY revenue DESC) rnumber
FROM 
	month_level_revenue 
)
SELECT
	city_name AS city, month_name AS month, revenue, pct_contribution 
FROM 
	cte JOIN dim_city USING (city_id)
WHERE rnumber = 1
ORDER BY city ;


----------------------------------------------------------------------------------------------------------------------------------- 

-- 6.Repeat passenger rate analysis 

WITH cte AS (
SELECT 
	city_name,
	month,
	total_passengers,
	repeat_passengers,
	ROUND(repeat_passengers * 100 /(SELECT sum(repeat_passengers) FROM fact_passenger_summary), 2) AS monthly_repeat_passenger_rate
FROM
	fact_passenger_summary JOIN dim_City USING (city_id)
)
SELECT
	*, 
    ROUND(SUM(monthly_repeat_passenger_rate) OVER(PARTITION BY city_name), 2) AS city_repeat_passenger_rate 
FROM 
	cte ;   