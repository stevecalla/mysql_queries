SELECT 
    booking_id,
    DATE(booking_datetime)
FROM ezhire_booking_data.booking_data
WHERE DATE(booking_datetime) = '2024-03-13'
ORDER BY booking_datetime DESC;

-- ***** 
SELECT
    DATE(booking_datetime),
    COUNT(booking_id)
FROM ezhire_booking_data.booking_data
-- WHERE DATE(booking_datetime) = '2024-03-13'
GROUP BY DATE(booking_datetime)
ORDER BY DATE(booking_datetime) DESC;

#1) *****************************************
SELECT 
	booking_id,
    DATE(booking_datetime) AS booking_date,
    booking_day_of_week_v2,
    
    CASE
        WHEN ((DateDiff(AddDate(Current_Date(), 0), DATE(booking_datetime)) < 28) AND (DateDiff(Current_Date(), DATE(booking_datetime)) >= 0)) THEN 'yes'
        WHEN ((DateDiff(AddDate(Current_Date(), 0), DATE(booking_datetime)) < (28 + 28)) AND (DateDiff(Current_Date(), DATE(booking_datetime)) >= 28)) THEN 'yes'
        WHEN ((DateDiff(AddDate(Current_Date(), 0),DATE(booking_datetime)) < (28 + (52 * 7))) AND (DateDiff(Current_Date(),DATE(booking_datetime)) >= (52 * 7))) THEN 'yes'
        ELSE 'no'
    END AS comparison_28_days,
    
    CASE
        WHEN ((DateDiff(AddDate(Current_Date(), 0), DATE(booking_datetime)) < 28) AND (DateDiff(Current_Date(), DATE(booking_datetime)) >= 0)) THEN 'Current_28_Days'
        WHEN ((DateDiff(AddDate(Current_Date(), 0), DATE(booking_datetime)) < (28 + 28)) AND (DateDiff(Current_Date(), DATE(booking_datetime)) >= 28)) THEN '4_Weeks_Prior'
        WHEN ((DateDiff(AddDate(Current_Date(), 0),DATE(booking_datetime)) < (28 + (52 * 7))) AND (DateDiff(Current_Date(),DATE(booking_datetime)) >= (52 * 7))) THEN '52_Weeks_Prior'
        ELSE 'other'
    END AS comparison_period,
    
	CASE  
		WHEN ((DateDiff(AddDate(Current_Date(), 0), DATE(booking_datetime)) < 28) AND (DateDiff(Current_Date(), DATE(booking_datetime)) >= 0)) THEN DATE(booking_datetime)
		WHEN ((DateDiff(AddDate(Current_Date(), 0), DATE(booking_datetime)) < (28 + 28)) AND (DateDiff(Current_Date(), DATE(booking_datetime)) >= 28)) THEN AddDate(DATE(booking_datetime), 28) 
		WHEN ((DateDiff(AddDate(Current_Date(), 0), DATE(booking_datetime)) < (28 + (52 * 7))) AND (DateDiff(Current_Date(), DATE(booking_datetime)) >= (52 * 7))) THEN AddDate(DATE(booking_datetime), (52 * 7))
	END AS comparison_common_date,
    
    CASE WHEN (DateDiff(AddDate(Current_Date(), 0), DATE(booking_datetime)) < 28) AND (DateDiff(Current_Date(), DATE(booking_datetime)) >= 0) THEN 1  ELSE 0 END AS `Current_28_Days`,
    CASE WHEN (DateDiff(AddDate(Current_Date(), 0), DATE(booking_datetime)) < (28 + 28)) AND (DateDiff(Current_Date(), DATE(booking_datetime)) >= 28) THEN 1  ELSE 0 END AS `4_Weeks_Prior`,
    CASE WHEN (DateDiff(AddDate(Current_Date(), 0), DATE(booking_datetime)) < (28 + (52 * 7))) AND (DateDiff(Current_Date(), DATE(booking_datetime)) >= (52 * 7)) THEN 1  ELSE 0 END AS `52_Weeks_Prior`
    
FROM ezhire_booking_data.booking_data 
-- WHERE booking_year IN (YEAR(Current_Date()), YEAR(subdate(Current_Date(), (52 * 7))))
-- AND status <> 'Cancelled by User'
HAVING comparison_28_days = "yes"
ORDER BY booking_date ASC;

-- #2) *****************************************
WITH DateCounts AS (
SELECT 
    DATE(booking_datetime) AS booking_date,
    booking_day_of_week_v2,
    CASE
        WHEN ((DateDiff(AddDate(Current_Date(), 0), DATE(booking_datetime)) < 28) AND (DateDiff(Current_Date(), DATE(booking_datetime)) >= 0)) THEN 'Current 28 Days'
        WHEN ((DateDiff(AddDate(Current_Date(), 0), DATE(booking_datetime)) < (28 + 28)) AND (DateDiff(Current_Date(), DATE(booking_datetime)) >= 28)) THEN '4 Weeks Prior'
        WHEN ((DateDiff(AddDate(Current_Date(), 0),DATE(booking_datetime)) < (28 + (52 * 7))) AND (DateDiff(Current_Date(),DATE(booking_datetime)) >= (52 * 7))) THEN '52 Weeks Prior'
        ELSE 'no'
    END AS date_period,
    
	CASE  
		WHEN ((DateDiff(AddDate(Current_Date(), 0), DATE(booking_datetime)) < 28) AND (DateDiff(Current_Date(), DATE(booking_datetime)) >= 0)) THEN DATE(booking_datetime)
		WHEN ((DateDiff(AddDate(Current_Date(), 0), DATE(booking_datetime)) < (28 + 28)) AND (DateDiff(Current_Date(), DATE(booking_datetime)) >= 28)) THEN AddDate(DATE(booking_datetime), 28) 
		WHEN ((DateDiff(AddDate(Current_Date(), 0), DATE(booking_datetime)) < (28 + (52 * 7))) AND (DateDiff(Current_Date(), DATE(booking_datetime)) >= (52 * 7))) THEN AddDate(DATE(booking_datetime), (52 * 7))
	END AS common_date,
    
    COUNT(booking_id) AS booking_count
    
FROM ezhire_booking_data.booking_data 
WHERE booking_year IN (YEAR(Current_Date()), YEAR(subdate(Current_Date(), (52 * 7))))
	AND status <> 'Cancelled by User'
GROUP BY DATE(booking_datetime), booking_day_of_week_v2, date_period, common_date
HAVING date_period <> 'no'
ORDER BY booking_date DESC
)

SELECT 
    booking_date,
	DATE_FORMAT(booking_date, '%a, %c/%e/%y') AS formatted_date,
    SUM(CASE WHEN date_period = 'Current 28 Days' THEN booking_count ELSE 0 END) AS `Current 28 Days`,
    SUM(CASE WHEN date_period = '4 Weeks Prior' THEN booking_count ELSE 0 END) AS `4 Weeks Prior`,
    SUM(CASE WHEN date_period = '52 Weeks Prior' THEN booking_count ELSE 0 END) AS `52 Weeks Prior`
FROM DateCounts
WHERE date_period <> 'no'
GROUP BY booking_date
ORDER BY booking_date DESC;

-- #3) *****************************************
WITH DateCounts AS (
    SELECT 
        DATE(booking_datetime) AS booking_date,
        booking_day_of_week_v2,
        CASE
            WHEN ((DateDiff(AddDate(Current_Date(), 0), DATE(booking_datetime)) < 28) AND (DateDiff(Current_Date(), DATE(booking_datetime)) >= 0)) THEN 'Current 28 Days'
            WHEN ((DateDiff(AddDate(Current_Date(), 0), DATE(booking_datetime)) < (28 + 28)) AND (DateDiff(Current_Date(), DATE(booking_datetime)) >= 28)) THEN '4 Weeks Prior'
            WHEN ((DateDiff(AddDate(Current_Date(), 0), DATE(booking_datetime)) < (28 + (52 * 7))) AND (DateDiff(Current_Date(), DATE(booking_datetime)) >= (52 * 7))) THEN '52 Weeks Prior'
            ELSE 'no'
        END AS date_period,
        
        CASE  
            WHEN ((DateDiff(AddDate(Current_Date(), 0), DATE(booking_datetime)) < 28) AND (DateDiff(Current_Date(), DATE(booking_datetime)) >= 0)) THEN DATE(booking_datetime)
            WHEN ((DateDiff(AddDate(Current_Date(), 0), DATE(booking_datetime)) < (28 + 28)) AND (DateDiff(Current_Date(), DATE(booking_datetime)) >= 28)) THEN AddDate(DATE(booking_datetime), 28) 
            WHEN ((DateDiff(AddDate(Current_Date(), 0), DATE(booking_datetime)) < (28 + (52 * 7))) AND (DateDiff(Current_Date(), DATE(booking_datetime)) >= (52 * 7))) THEN AddDate(DATE(booking_datetime), (52 * 7))
        END AS common_date,
        
        COUNT(booking_id) AS booking_count
        
    FROM ezhire_booking_data.booking_data 
    WHERE booking_year IN (YEAR(Current_Date()), YEAR(subdate(Current_Date(), (52 * 7))))
        AND status <> 'Cancelled by User'
    GROUP BY booking_date, booking_day_of_week_v2, date_period, common_date, booking_datetime
    -- HAVING date_period <> 'no'
    ORDER BY booking_date DESC
)

SELECT 
    -- common_date,
    DATE_FORMAT(common_date, '%a, %c/%e') AS formatted_date,
    SUM(CASE WHEN date_period = '52 Weeks Prior' THEN booking_count ELSE 0 END) AS `52 Weeks Prior`,
    SUM(CASE WHEN date_period = '4 Weeks Prior' THEN booking_count ELSE 0 END) AS `4 Weeks Prior`,
    SUM(CASE WHEN date_period = 'Current 28 Days' THEN booking_count ELSE 0 END) AS `Current 28 Days`,
    CONCAT(FORMAT((SUM(CASE WHEN date_period = 'Current 28 Days' THEN booking_count ELSE 0 END) - SUM(CASE WHEN date_period = '52 Weeks Prior' THEN booking_count ELSE 0 END)) / SUM(CASE WHEN date_period = '52 Weeks Prior' THEN booking_count ELSE 0 END) * 100, 0), '%') AS `Difference %`
FROM DateCounts
WHERE date_period <> 'no'
GROUP BY common_date
ORDER BY common_date DESC;