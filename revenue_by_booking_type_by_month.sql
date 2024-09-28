SELECT 
    COALESCE(booking_year, 'Total') AS booking_year,
    COALESCE(booking_month, 'Total') AS booking_month,
    -- COALESCE(booking_day_of_month, 'Total') AS booking_day_of_month,
    FORMAT(SUM(CASE WHEN booking_type = 'Daily' THEN booking_charge_less_discount END), 0) AS `daily`,
    FORMAT(SUM(CASE WHEN booking_type = 'Weekly' THEN booking_charge_less_discount END), 0) AS `weekly`,
    FORMAT(SUM(CASE WHEN booking_type = 'Monthly' THEN booking_charge_less_discount END), 0) AS `monthly`,
    FORMAT(SUM(CASE WHEN booking_type = 'Subscription' THEN booking_charge_less_discount END), 0) AS `sub`,
    CONCAT('$', FORMAT(SUM(booking_charge), 0)) AS booking_charge,
    CONCAT('$', FORMAT(SUM(booking_charge_less_discount), 0)) AS booking_charge_less_discount
FROM ezhire_booking_data.booking_data
-- WHERE status <> "Cancelled by User"
GROUP BY booking_year, booking_month  WITH ROLLUP
ORDER BY booking_year DESC, booking_month DESC;

