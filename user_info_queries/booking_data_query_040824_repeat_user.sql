USE myproject;

SET @str_date = '2024-01-01',@end_date = '2024-01-01';

SELECT 
        b.id AS booking_id,
        b.owner_id,
        au.id,
        
         -- this CASE statement categorizes owners as 'YES' if they have more than one booking in the 
         -- rental_car_booking2 table, and 'NO' if they have one or zero bookings. It's a way to 
         -- identify repeated users based on the number of bookings they have.
            (CASE
                WHEN
                    (SELECT 
                            COUNT(1)
                        FROM
                            myproject.rental_car_booking2 bb
                        WHERE
                            bb.owner_id = b.owner_id) > 1
                THEN
                    'YES'
                ELSE 'NO'
            END) repeated_user,

            IFNULL((SELECT 
                    COUNT(1)
                FROM
                    myproject.rental_car_booking2 bb
                WHERE
                    bb.owner_id = b.owner_id), 0) AS no_of_bookings,

            IFNULL((SELECT 
                    COUNT(1)
                FROM
                    myproject.rental_car_booking2 bb
                WHERE
                    bb.owner_id = b.owner_id
                        AND bb.status = 8), 0) AS no_of_cancel_bookings,

            IFNULL((SELECT 
                    COUNT(1)
                FROM
                    myproject.rental_car_booking2 bb
                WHERE
                    bb.owner_id = b.owner_id
                        AND bb.status = 9), 0) AS no_of_completed_bookings,

            IFNULL((SELECT 
                    COUNT(1)
                FROM
                    myproject.rental_car_booking2 bb
                WHERE
                    bb.owner_id = b.owner_id
                        AND bb.status NOT IN (8 , 9)), 0) AS no_of_started_bookings,

            b.owner_id AS customer_id,
            au.first_name AS first_name,
            au.last_name AS last_name,
            au.email as email,
            au.username as user_name,
            f.date_of_birth,
            TIMESTAMPDIFF(YEAR, STR_TO_DATE(f.date_of_birth, '%d/%m/%Y'), NOW()) age
                
    FROM myproject.rental_car_booking2 b
    INNER JOIN myproject.rental_fuser f ON f.user_ptr_id = b.owner_id
    LEFT JOIN myproject.auth_user au ON au.id = b.owner_id
	-- FOR USE IN MYSQL WITH VARIABLES IN LINE 1
	WHERE 
        DATE(DATE_ADD(b.created_on, INTERVAL 4 HOUR)) BETWEEN @str_date AND @end_date
		AND COALESCE(b.vendor_id,'') NOT IN (33, 5 , 218, 23086) -- LOGIC TO EXCLUDE TEST BOOKINGS
		AND (LOWER(au.first_name) NOT LIKE '%test%' AND LOWER(au.last_name) NOT LIKE '%test%' AND LOWER(au.username) NOT LIKE '%test%' AND LOWER(au.email) NOT LIKE '%test%')
    ORDER BY b.id
    LIMIT 10