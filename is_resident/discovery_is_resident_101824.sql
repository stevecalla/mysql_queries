USE myproject;

SELECT * FROM rental_car_booking2;
SELECT * FROM rental_fuser;
SELECT * FROM rental_country;
SELECT * FROM rental_city;

SELECT
	is_resident
    , FORMAT(COUNT(user_ptr_id), 0) AS booking_count
FROM rental_fuser
GROUP BY 1 WITH ROLLUP
ORDER BY CAST(COUNT(user_ptr_id) AS UNSIGNED) DESC;

WITH determine_resident_category AS (
	SELECT 
		b.id AS booking_id
		, f.user_ptr_id
		, f.is_resident
		, co.code
        , co.name AS country_name
		, CASE
			WHEN f.is_resident = co.code THEN 'is_resident'
			WHEN f.is_resident <> co.code THEN 'is_non_resident'
			ELSE 'unknown'
		END AS resident_category
	FROM rental_car_booking2 b
		INNER JOIN rental_fuser f ON f.user_ptr_id = b.owner_id
		INNER JOIN rental_city rc ON rc.id = b.city_id
		INNER JOIN rental_country co ON co.id = rc.CountryID
)

-- SELECT * FROM determine_resident_category;
SELECT
	resident_category
    , FORMAT(COUNT(booking_id), 0) AS booking_count
FROM determine_resident_category
GROUP BY 1 WITH ROLLUP
ORDER BY CAST(COUNT(booking_id) AS UNSIGNED) DESC;
  