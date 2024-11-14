USE ezhire_booking_data;

SELECT * FROM booking_data;

SELECT
	delivery_location
    , FORMAT(COUNT(booking_id), 0) AS booking_count
FROM booking_data
GROUP BY 1 WITH ROLLUP
ORDER BY CAST(booking_count AS UNSIGNED) DESC;
