USE myproject;

-- ALL FIELDS IN THE rental_car TABLE
SELECT
    *
FROM rental_car;   

-- DISTINCT STATUS HAS VALUES 0 AND 1
-- ASSUME 0 IS NOT IN SERVICE AND 1 IS IN SERVICE
SELECT
    DISTINCT(status)
FROM rental_car
ORDER BY status;  

-- RECONSTRUCT ORIGINAL STARTER QUERY fleet_starter_query_041924.sql WITH DATE ADJUSTMENTS
-- The goal is to reconstruct fleet count for each calendar date starting from 1/1/2023 to present. 
-- To do so, is there a date in which a vehicle is in the rentable inventory and a date (or combination of fields) to determine when a vehicle is no longer in the rental inventory?  
-- COULD NOT FIND A DATE THAT SHOWED WHEN A VEHICLE IS NO LONGER IN THE RENTAL FLEET
-- https://ezhire.slack.com/archives/D06KMLAFH25/p1713562726994689?thread_ts=1713447935.844599&cid=D06KMLAFH25
-- Point 1 - user_id = 234555 means cars that belongs to Dispatch center.
-- Point 2 - Yes, indication_date_new indicates that when the car is added in the inventory. Regarding the car’s availability is_active field inform us that the car is available in our inventory or not. However, there isn’t specific date that indicates vehicle is active or not.
-- Point 3 - Unfortunately, we don’t have this specific date available for when a vehicle goes in or out of service or when it is no longer in the rental inventory. 
SELECT
    indication_date_new,
    CASE
        WHEN STR_TO_DATE(rcar.indication_date_new, '%d/%m/%Y') THEN STR_TO_DATE(rcar.indication_date_new, '%d/%m/%Y')
        WHEN STR_TO_DATE(rcar.indication_date_new, '%m/%d/%Y') THEN STR_TO_DATE(rcar.indication_date_new, '%m/%d/%Y')
        ELSE NULL
    END AS rcar_indication_date_new_formatted
    -- , rcar.updated_on
    , DATE_ADD(rcar.updated_on, INTERVAL 4 HOUR) AS rcar_updated_on_gst
    , rcar.status
    , rcar.id    
    , rcar.plate_number
    , rcar.user_id AS vendor_id
    , rcar.car_vendor_code AS vendor_name
    , rcar.city_id
    , rcity.name
FROM rental_car rcar
    INNER JOIN rental_city rcity ON rcity.id = rcar.city_id
WHERE rcar.plate_code NOT LIKE("%test%")
    -- AND rcar.user_id = 234555 -- user_id/vendorid = 234555 Dispatch Center
    AND rcar.car_vendor_code IS NOT NULL
    AND rcar.indication_date_new IS NOT NULL
    AND rcar.indication_date_new <> 'NaN/NaN/0NaN'
    AND status = 1 -- active cars
ORDER BY STR_TO_DATE(rcar.indication_date_new, '%d/%m/%Y');  

-- PIVOT CARS BY USER ID / VENDOR ID BY AVAILABILITY STATUS
SELECT
    -- rcar.user_id AS vendor_id,
    -- rcar.status,
    CASE 
        WHEN rcar.user_id = 234555 THEN 'eZhire Dispatch'
        ELSE 'Other'
    END AS vendor_name
    , FORMAT(SUM(CASE WHEN rcar.status = 1 THEN 1 ELSE 0 END), 0) AS active_count
    , FORMAT(SUM(CASE WHEN rcar.status = 0 THEN 1 ELSE 0 END), 0) AS inactive_count
    , FORMAT(COUNT(*), 0) AS total_cars
FROM rental_car rcar
    INNER JOIN rental_city rcity ON rcity.id = rcar.city_id
WHERE rcar.plate_code NOT LIKE("%test%")
    -- AND rcar.user_id = 234555 -- user_id/vendorid = 234555 Dispatch Center
    AND rcar.car_vendor_code IS NOT NULL
    AND rcar.indication_date_new IS NOT NULL
    AND rcar.indication_date_new <> 'NaN/NaN/0NaN'
    -- AND status = 0 -- active cars
GROUP BY vendor_name WITH ROLLUP
ORDER BY vendor_name; 
-- GROUP BY user_id, status, vendor_name WITH ROLLUP
-- ORDER BY user_id; 

-- COUNT OF BOOKINGS BY RENTAL STATUS PIVOTED BY DISPATCH/MARKETPLACE
SELECT
    rcb.status
    , rs.status
    , FORMAT(SUM(CASE WHEN rcb.vendor_id = 234555 THEN 1 ELSE 0 END), 0) AS dispatch
    , FORMAT(SUM(CASE WHEN rcb.vendor_id <> 234555 THEN 1 ELSE 0 END), 0) AS marketplace
    , FORMAT(COUNT(*), 0) AS total_bookings
FROM rental_car_booking2 AS rcb
INNER JOIN rental_status AS rs ON rs.id = rcb.status
-- WHERE status = 
GROUP BY rs.status WITH ROLLUP
ORDER BY rs.status; 