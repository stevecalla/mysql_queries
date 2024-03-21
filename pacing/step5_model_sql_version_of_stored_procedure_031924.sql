USE ezhire_pacing_metrics;

DROP TABLE IF EXISTS temp_data_202301;

SET @calendar_start_date = '2022-01-01';
SET @pickup_month_year = '2023-01';

CREATE TABLE temp_data_202301 AS
SELECT
	1 AS grouping_id,
    pbg.pickup_month_year,
    CONCAT(pickup_month_year, '-01') AS first_day_of_month,
    LAST_DAY(CONCAT(pickup_month_year, '-01')) AS last_day_of_month,
    
    c.calendar_date AS booking_date,
    pbg.days_from_first_day_of_month,

	pbg.count AS count,
	pbg.total_booking_charge_aed,
    pbg.total_booking_charge_less_discount_aed,
    pbg.running_total_booking_count,
    pbg.running_total_booking_charge_aed,
    pbg.running_total_booking_charge_less_discount_aed

FROM calendar_table AS c

LEFT JOIN pacing_base_groupby AS pbg ON c.calendar_date = pbg.booking_date 
AND pbg.pickup_month_year = @pickup_month_year

WHERE c.calendar_date > @calendar_start_date
AND c.calendar_date <= (SELECT MAX(booking_date) FROM pacing_base_groupby WHERE pickup_month_year = @pickup_month_year)
AND c.calendar_date >= (SELECT MIN(booking_date) FROM pacing_base_groupby WHERE pickup_month_year = @pickup_month_year)

ORDER BY c.calendar_date ASC, pbg.days_from_first_day_of_month ASC;

SELECT * FROM temp_data_202301;

-- **************************************** --
DROP TABLE IF EXISTS temp_data_202401;

SET @pickup_month_year_v2 = '2024-01';

CREATE TABLE temp_data_202401 AS
SELECT
	2 AS grouping_id,
    pbg.pickup_month_year,
    CONCAT(pickup_month_year, '-01') AS first_day_of_month,
    LAST_DAY(CONCAT(pickup_month_year, '-01')) AS last_day_of_month,
    
    c.calendar_date AS booking_date,
    pbg.days_from_first_day_of_month,

	pbg.count AS count,
	pbg.total_booking_charge_aed,
    pbg.total_booking_charge_less_discount_aed,
    pbg.running_total_booking_count,
    pbg.running_total_booking_charge_aed,
    pbg.running_total_booking_charge_less_discount_aed

FROM calendar_table AS c

LEFT JOIN pacing_base_groupby AS pbg ON c.calendar_date = pbg.booking_date 
AND pbg.pickup_month_year = @pickup_month_year_v2

WHERE c.calendar_date > @calendar_start_date
AND c.calendar_date <= (SELECT MAX(booking_date) FROM pacing_base_groupby WHERE pickup_month_year = @pickup_month_year_v2)
AND c.calendar_date >= (SELECT MIN(booking_date) FROM pacing_base_groupby WHERE pickup_month_year = @pickup_month_year_v2)

ORDER BY c.calendar_date ASC, pbg.days_from_first_day_of_month ASC;

SELECT * FROM temp_data_202401;

-- *********************************
-- Query using UNION ALL to join temp_data_202301 and temp_data_202401
CREATE TABLE temp_combinedData
    SELECT * FROM temp_data_202301
        UNION ALL
    SELECT * FROM temp_data_202401;

SELECT * FROM temp_combinedData;

-- **************************************** --
SELECT
	-- pickup_month_year
    CASE
		WHEN pickup_month_year IS NULL THEN (
			SELECT inner_table.pickup_month_year
			FROM temp_combinedData AS inner_table
			WHERE inner_table.grouping_id = temp_combinedData.grouping_id
			AND inner_table.booking_date < temp_combinedData.booking_date
			AND inner_table.pickup_month_year IS NOT NULL
			ORDER BY inner_table.booking_date DESC
			LIMIT 1)
		ELSE pickup_month_year
        END AS pickup_month_year,
	booking_date,
    
    -- days_from_first_day_of_month
	CASE
		WHEN first_day_of_month IS NULL THEN (
			SELECT DATEDIFF(temp_combinedData.booking_date, STR_TO_DATE(inner_table.first_day_of_month  , '%Y-%m-%d'))
			FROM temp_combinedData AS inner_table
			WHERE inner_table.grouping_id = temp_combinedData.grouping_id
			AND inner_table.booking_date < temp_combinedData.booking_date
			AND inner_table.first_day_of_month IS NOT NULL
			ORDER BY inner_table.booking_date DESC
			LIMIT 1)
		ELSE days_from_first_day_of_month
        END AS days_from_first_day_of_month,
    
    COALESCE(count, 0) AS count,
	COALESCE(total_booking_charge_aed, 0) AS total_booking_charge_aed,
	COALESCE(total_booking_charge_less_discount_aed, 0) AS total_booking_charge_less_discount_aed,
    
    -- running_count
    CASE
		WHEN running_total_booking_count IS NULL THEN (
			SELECT inner_table.running_total_booking_count
			FROM temp_combinedData AS inner_table
			WHERE inner_table.grouping_id = temp_combinedData.grouping_id
			AND inner_table.booking_date < temp_combinedData.booking_date
			AND inner_table.running_total_booking_count IS NOT NULL
			ORDER BY inner_table.booking_date DESC
			LIMIT 1)
		ELSE running_total_booking_count
        END AS running_count
        
FROM temp_combinedData;

