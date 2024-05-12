SELECT
    id AS car_id,
    user_id AS vendor_id,
    plate_number,
    city_id,
    car_vendor_code AS Vendor_name,
    indication_date_new
FROM rental_car
-- where
--     user_id = 234555 -- user_id/vendorid = 234555 Dispatch Center
WHERE plate_code NOT LIKE("%test%")
AND car_vendor_code IS NOT NULL
AND indication_date_new IS NOT NULL
AND status = 1;-- active cars

-- NOTES:
-- This is the query we used to check the historical number of cars that we have in our invesntory (Dispatch center only). Ones you have the result with you then you need to take cumulative sum to get the total numbers unique cars that we have in our investory.
-- You can join this query with your booking query to get the cars that were assigned against the booking for DC only.
-- Note: Since we don't have the accurate information for Markletplace, so we can't calcuLate car per booking against Marketplace model.
-- SOURCE: https://ezhire.slack.com/archives/D06KMLAFH25/p1713511799234629?thread_ts=1713447935.844599&cid=D06KMLAFH25