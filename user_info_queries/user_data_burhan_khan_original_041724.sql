SELECT DISTINCT
    f.user_ptr_id AS user_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    cnt.Country AS resident_country,
    ct.name AS renting_in_city,	
    DATE_FORMAT(f.date_join, '%d/%m/%Y') AS date_join,
    CASE
        WHEN DATE_FORMAT(r.last_return, '%d/%m/%Y') IS NULL THEN 'no bookings'
        ELSE DATE_FORMAT(r.last_return, '%d/%m/%Y')
    END AS last_return,
    r.total_bookings
FROM
    rental_fuser AS f
    LEFT JOIN (
        SELECT
            MAX(STR_TO_DATE(return_date_string, '%d/%m/%Y')) AS last_return,
            owner_id,
            COUNT(id) AS total_bookings
        FROM
            rental_car_booking2
        GROUP BY
            2
    ) AS r ON r.owner_id = f.user_ptr_id
    LEFT JOIN rental_city AS ct ON f.renting_in = ct.id
    LEFT JOIN (
        SELECT
            id,
            first_name,
            last_name
        FROM
            myproject.auth_user
    ) AS u ON f.user_ptr_id = u.id
    LEFT JOIN rental_country_code AS cnt ON f.is_resident = cnt.residence_join
WHERE
    f.is_resident != 0
    AND last_return > (CURDATE() - INTERVAL 730 DAY)
    AND date_join IS NOT NULL
ORDER BY
    user_ptr_id DESC;