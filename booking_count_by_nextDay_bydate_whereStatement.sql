SELECT 
    COALESCE(booking_year, 'Total') AS booking_year,
    COALESCE(booking_month, 'Total') AS booking_month,
    COALESCE(booking_day_of_month, 'Total') AS booking_day_of_month,
    
    FORMAT(SUM(CASE WHEN pickup_day_of_month = booking_day_of_month THEN 1 ELSE 0 END), 0) AS 'SameDay',
    FORMAT(SUM(CASE WHEN pickup_day_of_month <> (booking_day_of_month) THEN 1 ELSE 0 END), 0) AS 'NextDay+',
    
    FORMAT(SUM(CASE WHEN pickup_day_of_month = booking_day_of_month THEN 1 ELSE 0 END) / COUNT(booking_datetime) * 100, 2) AS 'SameDay%',
    FORMAT(SUM(CASE WHEN pickup_day_of_month <> (booking_day_of_month) THEN 1 ELSE 0 END) / COUNT(booking_datetime) * 100, 2) AS 'NextDay+%',
    
    FORMAT(COUNT(booking_datetime), 0) AS Total,
    FORMAT(COUNT(booking_datetime) - COUNT(CASE WHEN status = 'Cancelled by User' THEN 1 END), 0) AS 'T xCancel'
    
FROM ezhire_booking_data.booking_data
-- WHERE status <> "Cancelled by User"
GROUP BY booking_year, booking_month, booking_day_of_month WITH ROLLUP
ORDER BY booking_year DESC, booking_month DESC, booking_day_of_month DESC;

    -- FORMAT( SUM(CASE WHEN pickup_day_of_month = booking_day_of_month THEN 1 ELSE 0 END) + 
--             SUM(CASE WHEN pickup_day_of_month <> (booking_day_of_month + 1) THEN 1 ELSE 0 END)
--             , 0) AS 'CheckCalculation',   
            
    -- FORMAT( ((
-- 			SUM(CASE WHEN pickup_day_of_month = booking_day_of_month THEN 1 ELSE 0 END) + 
--             SUM(CASE WHEN pickup_day_of_month <> (booking_day_of_month) THEN 1 ELSE 0 END)
--             )
--             / COUNT(booking_datetime) * 100)
--             , 0) AS '%Check'
