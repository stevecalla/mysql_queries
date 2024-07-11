USE ezhire_booking_data;

-- ALL BOOKING DATA
SELECT * FROM ezhire_booking_data.booking_data;

-- ONLY BOOKING DATA WITH EARLY RETURN = 1
SELECT * 
FROM ezhire_booking_data.booking_data
WHERE early_return = 1;

-- ONLY BOOKING DATA WITH EARLY RETURN = 1 AND BOOKING CHARGE < 1
SELECT * 
FROM ezhire_booking_data.booking_data
WHERE early_return = 1 AND booking_charge = 0
ORDER BY booking_id ASC;

-- SELECT * FROM booking_data WHERE early_return IN (1);
-- SELECT * FROM booking_data WHERE early_return IN (1) AND booking_charge < 1 ORDER BY return_date ASC;
