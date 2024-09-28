SELECT 
    COALESCE(booking_year, 'Total') AS booking_year,
    COALESCE(booking_month, 'Total') AS booking_month,
	
    -- by day_of_month
    COALESCE(booking_day_of_month, 'Total') AS booking_day_of_month,
    
    -- by day_of_week_number
    -- COALESCE(DAYOFWEEK(booking_datetime), 'Total') AS day_of_week_number,
    
    FORMAT(SUM(CASE WHEN pickup_day_of_month = booking_day_of_month THEN 1 ELSE 0 END), 0) AS 'Same_Day',
    FORMAT(SUM(CASE WHEN pickup_day_of_month <> booking_day_of_month THEN 1 ELSE 0 END), 0) AS 'Next_Day+',
    
    FORMAT(SUM(CASE WHEN WEEKOFYEAR(pickup_datetime) = WEEKOFYEAR(booking_datetime) THEN 1 ELSE 0 END), 0) AS 'Same_Week',
    FORMAT(SUM(CASE WHEN WEEKOFYEAR(pickup_datetime) <> WEEKOFYEAR(booking_datetime) THEN 1 ELSE 0 END), 0) AS 'Next_Week+',
    
    FORMAT(SUM(CASE WHEN MONTH(pickup_datetime) = MONTH(booking_datetime) THEN 1 ELSE 0 END), 0) AS 'Same_Month',
    FORMAT(SUM(CASE WHEN MONTH(pickup_datetime) <> MONTH(booking_datetime) THEN 1 ELSE 0 END), 0) AS 'Next_Month+',
    
    FORMAT(SUM(CASE WHEN DATEDIFF(pickup_datetime, booking_datetime) <= 0 THEN 1 ELSE 0 END), 0) AS 'Same_Day',
    FORMAT(SUM(CASE WHEN DATEDIFF(pickup_datetime, booking_datetime) = 1 THEN 1 ELSE 0 END), 0) AS 'Next_Day',
    FORMAT(SUM(CASE WHEN DATEDIFF(pickup_datetime, booking_datetime) BETWEEN 2 AND 7 THEN 1 ELSE 0 END), 0) AS 'Within_A_Week',
    FORMAT(SUM(CASE WHEN DATEDIFF(pickup_datetime, booking_datetime) > 7 THEN 1 ELSE 0 END), 0) AS 'More_Than_A_Week',
    
    FORMAT(SUM(CASE WHEN pickup_day_of_month = booking_day_of_month THEN 1 ELSE 0 END) / COUNT(booking_datetime) * 100, 2) AS 'Same_Day%',
    FORMAT(SUM(CASE WHEN pickup_day_of_month <> booking_day_of_month THEN 1 ELSE 0 END) / COUNT(booking_datetime) * 100, 2) AS 'NextDay+%',
    
    FORMAT(COUNT(booking_datetime), 0) AS Total,
    
    -- Additional columns for total bookings including cancelled ones
    -- FORMAT(SUM(CASE WHEN status = 'Cancelled by User' THEN 1 ELSE 0 END), 0) AS 'Total Cancelled',
--     FORMAT(SUM(CASE WHEN status <> 'Cancelled by User' THEN 1 ELSE 0 END), 0) AS 'Total Bookings'

    FORMAT(SUM(CASE WHEN pickup_day_of_month = booking_day_of_month AND status <> 'Cancelled by User' THEN 1 ELSE 0 END), 0) AS 'Same_DayXCancel',
    FORMAT(SUM(CASE WHEN pickup_day_of_month <> booking_day_of_month AND status <> 'Cancelled by User' THEN 1 ELSE 0 END), 0) AS 'Next_Day+XCancel',
    
    FORMAT(COUNT(booking_datetime) - COUNT(CASE WHEN status = 'Cancelled by User' THEN 1 END), 0) AS 'T xCancel',
    
    FORMAT(SUM(CASE WHEN pickup_day_of_month = booking_day_of_month AND status <> 'Cancelled by User'  THEN 1 ELSE 0 END) / (COUNT(booking_datetime) - COUNT(CASE WHEN status = 'Cancelled by User' THEN 1 END)) * 100, 2) AS 'SameDayXCancel%',
    FORMAT(SUM(CASE WHEN pickup_day_of_month <> booking_day_of_month AND status <> 'Cancelled by User' THEN 1 ELSE 0 END) / (COUNT(booking_datetime) - COUNT(CASE WHEN status = 'Cancelled by User' THEN 1 END)) * 100, 2) AS 'NextDay+XCancel%'
    
FROM ezhire_booking_data.booking_data

-- WHERE status <> "Cancelled by User"

-- by day_of_month
GROUP BY booking_year, booking_month, booking_day_of_month WITH ROLLUP
ORDER BY booking_year DESC, booking_month DESC, booking_day_of_month DESC;

-- by day_of_week_number
-- GROUP BY booking_year, booking_month, day_of_week_number WITH ROLLUP
-- ORDER BY booking_year DESC, booking_month DESC, day_of_week_number DESC;
