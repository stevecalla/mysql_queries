USE myproject;

-- DISCOVERY REFEREE / REFERRAL TABLE
-- SELECT * FROM rental_referral;
-- SELECT COUNT(*), MIN(created_date) FROM rental_referral LIMIT 10;
-- SELECT DISTINCT(is_referral_voilated), COUNT(*) FROM rental_referral GROUP BY 1 ORDER BY 1 DESC LIMIT 10;
-- SELECT DISTINCT(referrer_flag), COUNT(*) FROM rental_referral GROUP BY 1 ORDER BY 1 DESC LIMIT 10;
-- SELECT DISTINCT(referee_flag), COUNT(*) FROM rental_referral GROUP BY 1 ORDER BY 1 DESC LIMIT 10;
-- SELECT DISTINCT(created_date), COUNT(*) FROM rental_referral GROUP BY 1 ORDER BY 1 DESC LIMIT 10;

-- STEP #0 - REVIEW TABLE AND COUNTS
SELECT * FROM rental_referral;
SELECT COUNT(*) FROM rental_referral;

-- STEP #0A - CREATE CTE JOINING KEY TABLES TO GET BOOKING DATA
WITH referral_bookings AS (
SELECT
    referrer AS referrer_id_rr
    , referee AS referee_id_rr
	, rr.created_date AS created_at_referrer-- might need to adjust date based on time
    , rb.id AS booking_id_rb
    , rb.status AS status_code
    , rs.status AS status_description
    , co.name AS deliver_country
    , DATE_FORMAT(rb.created_on, '%Y-%m-%d') AS booking_date -- date doesn't include time
FROM rental_referral rr
    LEFT JOIN rental_car_booking2 AS rb ON rr.referee = rb.owner_id
    LEFT JOIN rental_status AS rs ON rb.status = rs.id
    LEFT JOIN myproject.rental_city rc ON rc.id = rb.city_id
    LEFT JOIN myproject.rental_country co ON co.id = rc.CountryID
-- need status
-- LIMIT 10
)

-- # STEP #1: ALL DATA
-- SELECT * FROM referral_bookings;
-- SELECT DISTINCT(status_description), COUNT(*) FROM referral_bookings GROUP BY 1 WITH ROLLUP;

-- STEP #2: COUNTS REFERRERS, REFEREES, BOOKINGS BY TYPE
-- SELECT
-- 	COUNT(DISTINCT referrer_id_rr) AS count_referrer_rr
-- 	, COUNT(DISTINCT referee_id_rr) AS count_referee_rr
--     , COUNT(DISTINCT booking_id_rb) AS count_bookings_rb
--     , COUNT(*) as count_total_rows
-- FROM referral_bookings;

-- SELECT 
-- 	status_description
-- 	, COUNT(DISTINCT referrer_id_rr) AS count_referrer_rr
-- 	, COUNT(DISTINCT referee_id_rr) AS count_referee_rr
--     , COUNT(DISTINCT booking_id_rb) AS count_bookings_rb
--     , COUNT(*) as count_total_rows
-- FROM referral_bookings
-- GROUP BY status_description;

-- STEP #3: # OF REFERRERS CREATED BY DATE
-- SELECT 
-- 	created_at_referrer
-- 	, COUNT(DISTINCT referrer_id_rr) AS referrer_count_rr
-- FROM referral_bookings
-- GROUP BY created_at_referrer WITH ROLLUP
-- ORDER BY created_at_referrer DESC;

-- STEP #4: # OF BOOKINGS CREATED BY DATE BY REFEREES
SELECT 
    booking_date
    , COUNT(DISTINCT CASE WHEN status_description = 'Cancelled by User' THEN booking_id_rb END) AS count_status_cancelled
    , COUNT(DISTINCT CASE WHEN status_description = 'Rental Ended' THEN booking_id_rb END) AS count_status_rental_ended
    , COUNT(DISTINCT CASE WHEN status_description = 'Rental Started' THEN booking_id_rb END) AS count_status_rental_started
    , COUNT(DISTINCT CASE WHEN status_description = 'Vendor Assigned' THEN booking_id_rb END) AS count_status_vendor_assigned
    , COUNT(DISTINCT CASE WHEN status_description NOT IN ('Cancelled by User', 'Rental Ended', 'Rental Started', 'Vendor Assigned') THEN booking_id_rb END) AS count_status_other
    , COUNT(DISTINCT booking_id_rb) AS total_bookings
FROM  referral_bookings
GROUP BY booking_date WITH ROLLUP
ORDER BY booking_date DESC;
;