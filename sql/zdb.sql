Query 1	SELECT rate_code_id, count(*) FROM trips GROUP BY rate_code_id;
Query 2	SELECT passenger_count, avg(total_amount) FROM trips GROUP BY passenger_count;
Query 3 SELECT passenger_count, cast( extract(year from pickup_datetime) as integer) AS pickup_year, count(*) FROM trips GROUP BY passenger_count, pickup_year;	
Query 4	SELECT passenger_count, cast( extract(year from pickup_datetime) as integer) AS pickup_year, cast(trip_distance as int) AS distance, count(*) AS the_count FROM trips GROUP BY passenger_count, pickup_year, distance ORDER BY pickup_year, the_count desc;
