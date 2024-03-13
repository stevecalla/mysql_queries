SELECT 
    COALESCE(booking_year, 'Total') AS booking_year,
    COALESCE(booking_month, 'Total') AS booking_month,
    COALESCE(booking_day_of_month, 'Total') AS booking_day_of_month,
    FORMAT(COUNT(CASE WHEN booking_type = 'Daily' THEN 1 END), 0) AS `daily`,
    FORMAT(COUNT(CASE WHEN booking_type = 'Weekly' THEN 1 END), 0) AS `weekly`,
    FORMAT(COUNT(CASE WHEN booking_type = 'Monthly' THEN 1 END), 0) AS `monthly`,
    FORMAT(COUNT(CASE WHEN booking_type = 'Subscription' THEN 1 END), 0) AS `sub`,
    FORMAT(COUNT(booking_datetime), 0) AS Total,
    FORMAT(COUNT(booking_datetime) - COUNT(CASE WHEN status = 'Cancelled by User' THEN 1 END), 0) AS Total
FROM ezhire_booking_data.booking_data
-- WHERE status <> "Cancelled by User"
GROUP BY booking_year, booking_month, booking_day_of_month WITH ROLLUP
ORDER BY booking_year DESC, booking_month DESC, booking_day_of_month DESC;

