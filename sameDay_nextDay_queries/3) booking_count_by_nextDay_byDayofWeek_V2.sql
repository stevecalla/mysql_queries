SELECT 
    COALESCE(booking_year, 'Total') AS booking_year,
    COALESCE(booking_month, 'Total') AS booking_month,
    COALESCE(DAYOFWEEK(booking_datetime), 'Total') AS day_of_week_number,
    
    FORMAT(SUM(CASE WHEN pickup_day_of_month = booking_day_of_month THEN 1 ELSE 0 END), 0) AS 'SameDay',
    FORMAT(SUM(CASE WHEN pickup_day_of_month <> booking_day_of_month THEN 1 ELSE 0 END), 0) AS 'NextDay+',
    
    FORMAT(SUM(CASE WHEN WEEKOFYEAR(pickup_datetime) = WEEKOFYEAR(booking_datetime) THEN 1 ELSE 0 END), 0) AS 'SameWeek',
    FORMAT(SUM(CASE WHEN WEEKOFYEAR(pickup_datetime) <> WEEKOFYEAR(booking_datetime) THEN 1 ELSE 0 END), 0) AS 'NexWeek+',
    
    FORMAT(SUM(CASE WHEN pickup_day_of_month = booking_day_of_month THEN 1 ELSE 0 END) / COUNT(booking_datetime) * 100, 2) AS 'SameDay%',
    FORMAT(SUM(CASE WHEN pickup_day_of_month <> booking_day_of_month THEN 1 ELSE 0 END) / COUNT(booking_datetime) * 100, 2) AS 'NextDay+%',
    
    FORMAT(COUNT(booking_datetime), 0) AS Total,
    
    -- Additional columns for total bookings including cancelled ones
    -- FORMAT(SUM(CASE WHEN status = 'Cancelled by User' THEN 1 ELSE 0 END), 0) AS 'Total Cancelled',
--     FORMAT(SUM(CASE WHEN status <> 'Cancelled by User' THEN 1 ELSE 0 END), 0) AS 'Total Bookings'

    FORMAT(SUM(CASE WHEN pickup_day_of_month = booking_day_of_month AND status <> 'Cancelled by User' THEN 1 ELSE 0 END), 0) AS 'SameDayXCancel',
    FORMAT(SUM(CASE WHEN pickup_day_of_month <> booking_day_of_month AND status <> 'Cancelled by User' THEN 1 ELSE 0 END), 0) AS 'NextDay+XCancel',
    
    FORMAT(COUNT(booking_datetime) - COUNT(CASE WHEN status = 'Cancelled by User' THEN 1 END), 0) AS 'T xCancel',
    
    FORMAT(SUM(CASE WHEN pickup_day_of_month = booking_day_of_month AND status <> 'Cancelled by User'  THEN 1 ELSE 0 END) / (COUNT(booking_datetime) - COUNT(CASE WHEN status = 'Cancelled by User' THEN 1 END)) * 100, 2) AS 'SameDayXCancel%',
    FORMAT(SUM(CASE WHEN pickup_day_of_month <> booking_day_of_month AND status <> 'Cancelled by User' THEN 1 ELSE 0 END) / (COUNT(booking_datetime) - COUNT(CASE WHEN status = 'Cancelled by User' THEN 1 END)) * 100, 2) AS 'NextDay+XCancel%'
    
FROM ezhire_booking_data.booking_data
GROUP BY booking_year, booking_month, day_of_week_number WITH ROLLUP
ORDER BY booking_year DESC, booking_month DESC, day_of_week_number DESC;
