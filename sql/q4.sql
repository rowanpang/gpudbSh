\timing on
SELECT passenger_count, cast( extract(year from pickup_datetime) as integer) AS pickup_year, cast(trip_distance as int) AS distance, count(*) AS the_count FROM trips GROUP BY passenger_count, pickup_year, distance ORDER BY pickup_year, the_count desc;
