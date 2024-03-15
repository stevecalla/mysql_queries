SELECT 
	-- *,
    booking_id,
    booking_datetime,
    pickup_datetime,
	-- assign each record a sameDay or nextDay field
    CASE
		WHEN DAYOFMONTH(pickup_datetime) = DAYOFMONTH(booking_datetime) THEN 'SameDay'
		WHEN DAYOFMONTH(pickup_datetime) <> DAYOFMONTH(booking_datetime) THEN 'NextDay+'
		ELSE 'Other'
	END AS advance_category_day,
    
    -- assign each record a sameWeek or nextWeek field
    CASE
		WHEN WEEKOFYEAR(pickup_datetime) = WEEKOFYEAR(booking_datetime) THEN 'SameWeek'
		WHEN WEEKOFYEAR(pickup_datetime) <> WEEKOFYEAR(booking_datetime) THEN 'NextWeek+'
		ELSE 'Other'
	END AS advance_category_week,
    
    -- assign each record a sameMonth or nextMonth field
    CASE
		WHEN MONTH(pickup_datetime) = MONTH(booking_datetime) THEN 'SameMonth'
		WHEN MONTH(pickup_datetime) <> MONTH(booking_datetime) THEN 'NextMonth+'
		ELSE 'Other'
	END AS advance_category_month,
    
    -- assign each record a s
    CASE
		WHEN DATEDIFF(pickup_datetime, booking_datetime) <= 0 THEN 'SameDay'
		WHEN DATEDIFF(pickup_datetime, booking_datetime) = 1 THEN 'NextDay'
		WHEN DATEDIFF(pickup_datetime, booking_datetime) BETWEEN 2 AND 7 THEN 'WithinAWeek'
		WHEN DATEDIFF(pickup_datetime, booking_datetime) > 7 THEN 'MoreThanAWeek'
		ELSE 'Other'
	END AS advance_category_date_diff,
    
    -- calc the date difference between pickup and dropoff
    DATEDIFF(pickup_datetime, booking_datetime) AS advance_pickup_booking_date_diff
    
FROM ezhire_booking_data.booking_data
LIMIT 10;