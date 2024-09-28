SELECT 
    bd.booking_year AS booking_year,
    bd.booking_month AS booking_month,
    bd.booking_day_of_month AS booking_day_of_month,
    bd.booking_day_of_week_v2 AS booking_day_of_week,
    
    FORMAT(SUM(CASE WHEN bd.pickup_day_of_month = bd.booking_day_of_month THEN 1 ELSE 0 END), 0) AS 'SameDay',
    FORMAT(SUM(CASE WHEN bd.pickup_day_of_month = (bd.booking_day_of_month + 1) THEN 1 ELSE 0 END), 0) AS 'NextDay',
    FORMAT(SUM(CASE WHEN bd.pickup_day_of_month > (bd.booking_day_of_month + 1) THEN 1 ELSE 0 END), 0) AS 'BeyondNextDay',
    
    FORMAT(COUNT(bd.booking_datetime), 0) AS Total,
    FORMAT(COUNT(bd.booking_datetime) - COUNT(CASE WHEN bd.status = 'Cancelled by User' THEN 1 END), 0) AS 'T xCancel',
    
    FORMAT(SUM(CASE WHEN bd.pickup_day_of_month = bd.booking_day_of_month THEN 1 ELSE 0 END) / COUNT(bd.booking_datetime) * 100, 2) AS 'SameDay%',
    FORMAT(SUM(CASE WHEN bd.pickup_day_of_month = (bd.booking_day_of_month + 1) THEN 1 ELSE 0 END) / COUNT(bd.booking_datetime) * 100, 2) AS 'NextDay%',
    FORMAT(SUM(CASE WHEN bd.pickup_day_of_month > (bd.booking_day_of_month + 1) THEN 1 ELSE 0 END) / COUNT(bd.booking_datetime) * 100, 2) AS 'BeyondNextDay%',
    
    FORMAT( SUM(CASE WHEN bd.pickup_day_of_month = bd.booking_day_of_month THEN 1 ELSE 0 END) + 
            SUM(CASE WHEN bd.pickup_day_of_month = (bd.booking_day_of_month + 1) THEN 1 ELSE 0 END) + 
            SUM(CASE WHEN bd.pickup_day_of_month > (bd.booking_day_of_month + 1) THEN 1 ELSE 0 END)
            , 0) AS 'CheckCalculation',   
            
    FORMAT( ((
			SUM(CASE WHEN bd.pickup_day_of_month = bd.booking_day_of_month THEN 1 ELSE 0 END) + 
            SUM(CASE WHEN bd.pickup_day_of_month = (bd.booking_day_of_month + 1) THEN 1 ELSE 0 END) + 
            SUM(CASE WHEN bd.pickup_day_of_month > (bd.booking_day_of_month + 1) THEN 1 ELSE 0 END)
            )
            / COUNT(bd.booking_datetime) * 100)
            , 0) AS '%Check'
    
FROM ezhire_booking_data.booking_data bd
LEFT JOIN (
    SELECT 
        booking_year,
        booking_month,
        booking_day_of_month,
        booking_day_of_week_v2
    FROM ezhire_booking_data.booking_data
    WHERE status <> 'Cancelled by User'
    GROUP BY booking_year, booking_month, booking_day_of_month, booking_day_of_week_v2
) AS subquery ON bd.booking_year = subquery.booking_year 
    AND bd.booking_month = subquery.booking_month 
    AND bd.booking_day_of_month = subquery.booking_day_of_month 
    AND bd.booking_day_of_week_v2 = subquery.booking_day_of_week_v2

WHERE bd.status <> 'Cancelled by User'
GROUP BY bd.booking_year, bd.booking_month, bd.booking_day_of_month, bd.booking_day_of_week_v2
ORDER BY bd.booking_year DESC, bd.booking_month DESC, bd.booking_day_of_month DESC, bd.booking_day_of_week_v2;
