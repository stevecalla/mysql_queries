SELECT DISTINCT 
	-- booking_day_of_week_v2,
    -- booking_day_of_week
    -- extension_charge
    total_lifetime_booking_revenue
FROM ezhire_booking_data.booking_data
ORDER BY total_lifetime_booking_revenue
LIMIT 100;