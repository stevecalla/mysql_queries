SELECT * FROM key_metrics_base;

SELECT DISTINCT 
	-- vendor
	-- booking_type
	-- status
	country
FROM key_metrics_base
WHERE vendor NOT LIKE 'N/A' AND vendor IS NOT NULL AND vendor != ''
ORDER BY country
LIMIT 100;