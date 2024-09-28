SELECT 
	*,
	booking_id
FROM myproject.rental_charges
WHERE booking_id IN ("257685")
-- WHERE booking_id IN ("240667") -- possible extension
-- WHERE booking_id IN ('245689') -- refund
-- WHERE booking_id IN ('240668') -- possible extension
-- WHERE booking_id IN ('246165')
-- WHERE booking_id IN ("247086")
-- WHERE booking_id IN ('240685','244787','245399','245689','246867','246876','258479','258490','258491')
ORDER BY booking_id, from_date, charge_type_id
LIMIT 200;

-- FIND ONLY THE EXTENSION CHARGES (CODE 6) AND DISCOUNT CHARGES (CODE 14)
-- CREATED ON DATE NOT EQUAL TO THE MIN CREATED ON DATE
SELECT 
    *, booking_id
FROM
    myproject.rental_charges
WHERE
    booking_id IN ('257685')
	AND charge_type_id IN (6 , 14)
ORDER BY booking_id , from_date , charge_type_id
LIMIT 200;

-- ADJUST TO ELIMINATE THE MIN CREATED DATE AND CHARGE TYPE = 6
SELECT 
    rc.*, rc.booking_id
FROM
    myproject.rental_charges rc
JOIN (
    SELECT 
        booking_id, MIN(created_on) AS min_created_on
    FROM
        myproject.rental_charges
    WHERE
        booking_id IN ('257685')
            AND charge_type_id IN (6, 14)
    GROUP BY booking_id
) AS min_dates ON rc.booking_id = min_dates.booking_id
WHERE
    rc.booking_id IN ('257685')
        AND rc.charge_type_id IN (14)
        AND rc.created_on > min_dates.min_created_on
ORDER BY
    rc.booking_id, rc.from_date, rc.charge_type_id
LIMIT 200;

-- FIND 2024 DISCOUNTS
-- ADJUST TO ELIMINATE THE MIN CREATED DATE AND CHARGE TYPE = 6
-- FIND BOOKINGS WITH MULTIPLE CHARGE TYPE 6; GET THE MIN CREATED ON DATE
SELECT 
	booking_id, charge_type_id, COUNT(charge_type_id) AS count_charge_type, MIN(created_on) AS min_created_on
FROM
	myproject.rental_charges
WHERE
	created_on >= '2024-01-01'
	AND charge_type_id IN (6)
GROUP BY booking_id, charge_type_id
HAVING count_charge_type > 1;

-- SELECT 
--     rc.*, rc.booking_id
-- FROM
--     myproject.rental_charges rc
-- JOIN (
--     SELECT 
--         booking_id, charge_type_id, MIN(created_on) AS min_created_on
--     FROM
--         myproject.rental_charges
--     WHERE
--         created_on >= '2024-01-01'
--         AND charge_type_id IN (6)
--     GROUP BY booking_id, charge_type_id
-- ) AS min_dates ON rc.booking_id = min_dates.booking_id
--     AND rc.charge_type_id = min_dates.charge_type_id
-- WHERE
--     rc.created_on >= '2024-01-01'
--     AND rc.charge_type_id IN (14)
--     AND rc.created_on > min_dates.min_created_on
-- ORDER BY
--     rc.booking_id, rc.from_date, rc.charge_type_id
-- LIMIT 200;

-- SELECT 
-- 	SUM(total_charge) 
-- FROM myproject.rental_charges cc
-- WHERE cc.booking_id = b.id
-- AND cc.charge_type_id IN (1, 2, 8, 9, 13, 14, 20, 22, 24, 27, 28, 44, 45, 46, 47)) AS non_rental_charge,
-- 0 AS extension_charge,