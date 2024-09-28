-- SELECT * FROM ezhire_booking_data.booking_data WHERE booking_id in ("243255", "247465");

-- SELECT * FROM ezhire_booking_data.booking_data WHERE booking_id in ("240667");

-- SELECT * FROM ezhire_booking_data.booking_data WHERE booking_date IN ('2024-01-01');

SELECT * FROM ezhire_booking_data.booking_data WHERE customer_id in ('549331');

-- SELECT DISTINCT status, COUNT(*) FROM ezhire_booking_data.booking_data GROUP BY status ORDER BY status;
	
SELECT 
	DISTINCT(booking_channel),
    
	-- PIVOT BY BOOKING DATE
    FORMAT(SUM(CASE WHEN booking_year NOT IN (2021, 2022, 2023, 2024) THEN 1 ELSE 0 END), 0) AS 'Other',
    FORMAT(SUM(CASE WHEN booking_year = 2021 THEN 1 ELSE 0 END), 0) AS '2021',
    FORMAT(SUM(CASE WHEN booking_year = 2022 THEN 1 ELSE 0 END), 0) AS '2022',
    FORMAT(SUM(CASE WHEN booking_year = 2023 THEN 1 ELSE 0 END), 0) AS '2023',
    FORMAT(SUM(CASE WHEN booking_year = 2024 THEN 1 ELSE 0 END), 0) AS '2024',
	FORMAT(COUNT(*), 0) AS total_count
FROM ezhire_booking_data.booking_data 
GROUP BY 1 WITH ROLLUP
ORDER BY 1;

SELECT 
	DISTINCT(booking_source),
    
    -- PIVOT BY BOOKING DATE
    FORMAT(SUM(CASE WHEN booking_year NOT IN (2021, 2022, 2023, 2024) THEN 1 ELSE 0 END), 0) AS 'Other',
    FORMAT(SUM(CASE WHEN booking_year = 2021 THEN 1 ELSE 0 END), 0) AS '2021',
    FORMAT(SUM(CASE WHEN booking_year = 2022 THEN 1 ELSE 0 END), 0) AS '2022',
    FORMAT(SUM(CASE WHEN booking_year = 2023 THEN 1 ELSE 0 END), 0) AS '2023',
    FORMAT(SUM(CASE WHEN booking_year = 2024 THEN 1 ELSE 0 END), 0) AS '2024',
	FORMAT(COUNT(*), 0) AS total_count
    
FROM ezhire_booking_data.booking_data 
GROUP BY 1 WITH ROLLUP
ORDER BY 1;