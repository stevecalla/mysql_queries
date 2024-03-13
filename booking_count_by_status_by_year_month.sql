SELECT 
    COALESCE(booking_year, 'Total') AS booking_year,
    COALESCE(booking_month, 'Total') AS booking_month,
    COALESCE(booking_day_of_month, 'Total') AS booking_day_of_month,
    FORMAT(COUNT(CASE WHEN status = 'Rental Started' THEN 1 END), 0) AS `Rental Started`,
    FORMAT(COUNT(CASE WHEN status = 'Rental Ended' THEN 1 END), 0) AS `Rental Ended`,
    FORMAT(COUNT(CASE WHEN status = 'Cancelled by User' THEN 1 END), 0) AS `Cancelled by User`,
    FORMAT(COUNT(CASE WHEN status = 'Vendor Assigned' THEN 1 END), 0) AS `Vendor Assigned`,
    FORMAT(COUNT(CASE WHEN status = 'Collect' THEN 1 END), 0) AS `Collect`,
    FORMAT(COUNT(CASE WHEN status = 'Collection on the way' THEN 1 END), 0) AS `Collection on the way`,
    FORMAT(COUNT(CASE WHEN status = 'Collection Driver Assigned' THEN 1 END), 0) AS `Collection Driver Assigned`,
    FORMAT(COUNT(CASE WHEN status = 'Car Assigned' THEN 1 END), 0) AS `Car Assigned`,
    FORMAT(COUNT(CASE WHEN status = 'Driver Arrived Collection' THEN 1 END), 0) AS `Driver Arrived Collection`,
    FORMAT(COUNT(CASE WHEN status = 'On the Way Delivery' THEN 1 END), 0) AS `On the Way Delivery`,
    FORMAT(COUNT(CASE WHEN status = 'Arrived For Delivery' THEN 1 END), 0) AS `Arrived For Delivery`,
    FORMAT(COUNT(booking_datetime), 0) AS Total,
    FORMAT(COUNT(booking_datetime) - COUNT(CASE WHEN status = 'Cancelled by User' THEN 1 END), 0) AS 'Total xCancel'
FROM ezhire_booking_data.booking_data
-- WHERE status <> "Cancelled by User"
GROUP BY booking_year, booking_month, booking_day_of_month WITH ROLLUP
ORDER BY booking_year DESC, booking_month DESC, booking_day_of_month DESC;

