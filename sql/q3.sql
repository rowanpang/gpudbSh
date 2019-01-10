\timing on
SELECT passenger_count, cast( extract(year from pickup_datetime) as integer) AS pickup_year, count(*) FROM trips GROUP BY passenger_count, pickup_year;	
