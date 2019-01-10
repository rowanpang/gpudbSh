\timing on
SELECT count(rate_code_id) FROM trips where rate_code_id < 100 and trip_id > 5 and pickup_longitude > 5 and extra < 5;
