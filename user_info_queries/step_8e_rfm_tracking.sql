USE ezhire_user_data;

-- GET COUNT OF RECORDS
SELECT COUNT(*) FROM rfm_score_summary_history_data;

-- GET COUNT OF RECORDS by user id
SELECT user_ptr_id, count(*) FROM rfm_score_summary_history_data GROUP BY user_ptr_id ORDER BY user_ptr_id;

-- GET COUNT OF RECORDS by user id
SELECT created_at_date, count(*) FROM rfm_score_summary_history_data GROUP BY created_at_date ORDER BY created_at_date;

-- DISPLAY SCORE BY CREATED AT DATE WITH THE DIFFERENCE
SELECT
    score_five_parts,
    SUM(CASE WHEN created_at_date = '07/01/2024' THEN 1 ELSE 0 END) AS '07/01/2024',
    SUM(CASE WHEN created_at_date = '07/03/2024' THEN 1 ELSE 0 END) AS '07/03/2024',
    SUM(CASE WHEN created_at_date = '07/01/2024' THEN 1 ELSE 0 END) - SUM(CASE WHEN created_at_date = '07/03/2024' THEN 1 ELSE 0 END) AS difference
FROM rfm_score_summary_history_data
GROUP BY score_five_parts
ORDER BY score_five_parts ASC;
    
-- DISPLAY USER ID SCORE BY CREATED AT DATE WITH THE DIFFERENCE
SELECT
    user_ptr_id,
    SUM(CASE WHEN created_at_date = '07/01/2024' THEN score_five_parts ELSE 0 END) AS '07/01/2024',
    SUM(CASE WHEN created_at_date = '07/03/2024' THEN score_five_parts ELSE 0 END) AS '07/03/2024',
    SUM(CASE WHEN created_at_date = '07/01/2024' THEN score_five_parts ELSE 0 END) - SUM(CASE WHEN created_at_date = '07/03/2024' THEN score_five_parts ELSE 0 END) AS difference
FROM rfm_score_summary_history_data
GROUP BY  user_ptr_id
ORDER BY user_ptr_id ASC;

-- DISPLAY THE SCORE BY CREATED DATE
SELECT
    score_five_parts,
    SUM(CASE WHEN score_five_parts = '111' AND created_at_date = '07/01/2024' THEN 1 ELSE 0 END) AS '111',
    SUM(CASE WHEN score_five_parts = '112' AND created_at_date = '07/01/2024' THEN 1 ELSE 0 END) AS '112',
    SUM(CASE WHEN score_five_parts = '113' AND created_at_date = '07/01/2024' THEN 1 ELSE 0 END) AS '113',
    SUM(CASE WHEN score_five_parts = '114' AND created_at_date = '07/01/2024' THEN 1 ELSE 0 END) AS '114'
FROM rfm_score_summary_history_data
GROUP BY score_five_parts
ORDER BY score_five_parts ASC;

-- GET MIN & MAX CREATED AT DATE
SELECT
	MIN(created_at_date) AS min_created_at_date,
	STR_TO_DATE(MIN(created_at_date), '%m/%d/%Y') AS min_created_at_date_formatted,
    MAX(created_at_date) AS max_created_at_date
FROM rfm_score_summary_history_data
LIMIT 1;

-- GET THE TWO MOST RECENT CREATED AT DATES
SELECT MIN(created_at_date) AS min_created_at_date,
	   STR_TO_DATE(MIN(created_at_date), '%m/%d/%Y') AS min_date_formatted,
       MAX(created_at_date) AS max_created_at_date
FROM (
    SELECT created_at_date
    FROM rfm_score_summary_history_data
	GROUP BY created_at_date
    ORDER BY created_at_date DESC
    LIMIT 2
) AS recent_dates;

-- DISPLAY THE SCORES BY CREATED AT DATES ALONG WITH THE CHANGE IN SCORE
SELECT
    user_ptr_id,
    SUM(CASE WHEN created_at_date = '07/01/2024' THEN score_five_parts ELSE 0 END) AS '07/01/2024',
    (SELECT MAX(created_at_date) FROM rfm_score_summary_history_data) AS max_created_at_date,
    SUM(CASE WHEN created_at_date = (SELECT MAX(created_at_date) FROM rfm_score_summary_history_data) THEN score_five_parts ELSE 0 END) AS lastest_created_at_date,
    SUM(CASE WHEN created_at_date = '07/01/2024' THEN score_five_parts ELSE 0 END) - SUM(CASE WHEN created_at_date = (SELECT MAX(created_at_date) FROM rfm_score_summary_history_data) THEN score_five_parts ELSE 0 END) AS difference
FROM rfm_score_summary_history_data
GROUP BY user_ptr_id
ORDER BY user_ptr_id ASC;

-- ************************************-- IF user_ptr_id HAS RFM SCORE ON INITIAL DATE... DO THEY HAVE A BOOKING CREATED AFTER THE INITIAL DATE?
-- ... IF BOOKING YES THEN RFM SEGMENT = BOOKER
-- ... TRACK NEW RFM SCORES BUT THEY ARE NOT RELEVANT FOR THE ANALYSIS VS THE INITIAL DATE
-- ... ALL OTHERS ARE SAME OR MIGRATED

-- JOIN RFM SCORES FOR INITIAL DATE TO BOOKING DATA
-- GET BOOKING INFO FOR EACH USER WITH A BOOKING GREATER THAN THE INTIAL DATE
-- IF user_ptr_id HAS RFM SCORE ON INITIAL DATE... DO THEY HAVE A BOOKING CREATED AFTER THE INITIAL DATE?
-- ... IF BOOKING YES THEN RFM SEGMENT = BOOKER
-- ... TRACK NEW RFM SCORES BUT THEY ARE NOT RELEVANT FOR THE ANALYSIS VS THE INITIAL DATE
-- ... ALL OTHERS ARE SAME OR MIGRATED

-- JOIN RFM SCORES FOR INITIAL DATE TO BOOKING DATA
-- GET BOOKING INFO FOR EACH USER WITH A BOOKING GREATER THAN THE INTIAL DATE

USE ezhire_user_data;

SET @min_created_at_date = (SELECT MIN(created_at_date) FROM rfm_score_summary_history_data);
SET @min_created_at_date_formatted = STR_TO_DATE((SELECT MIN(created_at_date) FROM rfm_score_summary_history_data), '%m/%d/%Y');
SET @max_created_at_date = (SELECT MAX(created_at_date) FROM rfm_score_summary_history_data);

-- HAS A BOOKING AFTER INITIAL DATE
SELECT
	rfm.user_ptr_id,
    rfm.created_at_date,
    rfm.date_join_cohort,
    rfm.test_group,
    rfm.score_three_parts,
    rfm.score_five_parts,
    b.booking_id,
    b.status,
	b.booking_type,
    b.deliver_method,
    b.car_cat_name,
    marketplace_or_dispatch,
    b.promo_code,
    b.booking_date,
    b.pickup_date,
	b.return_date,
    b.booking_charge_less_discount,
    count(*),
	@min_created_at_date AS min_created_at_date,
	@min_created_at_date_formatted AS max_created_at_date
FROM rfm_score_summary_history_data AS rfm
	LEFT JOIN user_data_combined_booking_data AS b ON rfm.user_ptr_id = b.user_ptr_id
WHERE 
	rfm.created_at_date LIKE @min_created_at_date
	AND b.booking_date >= @min_created_at_date_formatted
	AND b.status NOT IN ('Cancelled by User')
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17
ORDER BY user_ptr_id, return_date;

-- COMBINE RFM & BOOKING DATA FOR INITIAL DATE & MAX CREATED_AT_DATE
SELECT
    rfm.user_ptr_id,
    rfm.date_join_cohort,
    b.booking_id,
    b.status,
    b.booking_type,
    b.deliver_method,
    b.car_cat_name,
    marketplace_or_dispatch,
    b.promo_code,
    b.booking_date,
    b.pickup_date,
    b.return_date,
    b.booking_charge_less_discount,
    
    COUNT(b.booking_id) AS booking_count,
    @min_created_at_date AS min_created_at_date,
    @max_created_at_date AS max_created_at_date,
    
    MIN(CASE WHEN rfm.created_at_date = @min_created_at_date THEN rfm.test_group ELSE NULL END) AS test_group_at_min_date,
    
    -- SCORE THREE PART COMPARISON
    MAX(CASE WHEN rfm.created_at_date = @min_created_at_date THEN rfm.score_three_parts ELSE 0 END) AS score_three_parts_as_of_initial_date,
    MAX(CASE WHEN rfm.created_at_date = @max_created_at_date THEN rfm.score_three_parts ELSE 0 END) AS score_three_parts_as_of_most_recent_created_at_date,
    MAX(CASE WHEN rfm.created_at_date = @min_created_at_date THEN rfm.score_three_parts ELSE 0 END) - MAX(CASE WHEN rfm.created_at_date = @max_created_at_date THEN rfm.score_three_parts ELSE 0 END) AS score_three_parts_difference,
    
    -- SCORE FIVE PART COMPARISON
    MAX(CASE WHEN rfm.created_at_date = @min_created_at_date THEN rfm.score_five_parts ELSE 0 END) AS score_five_parts_as_of_initial_date,
    MAX(CASE WHEN rfm.created_at_date = @max_created_at_date THEN rfm.score_five_parts ELSE 0 END) AS score_five_parts_as_of_most_recent_created_at_date,
    MAX(CASE WHEN rfm.created_at_date = @min_created_at_date THEN rfm.score_five_parts ELSE 0 END) - MAX(CASE WHEN rfm.created_at_date = @max_created_at_date THEN rfm.score_five_parts ELSE 0 END) AS score_five_parts_difference
    
FROM rfm_score_summary_history_data AS rfm
LEFT JOIN user_data_combined_booking_data AS b ON rfm.user_ptr_id = b.user_ptr_id
    AND rfm.created_at_date = @min_created_at_date
    AND b.booking_date >= @min_created_at_date_formatted
    AND b.status NOT IN ('Cancelled by User')
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13
ORDER BY rfm.user_ptr_id, b.return_date;

-- CREATE RFM SEGMENTS; COMBINE WITH BOOKING DATA
SELECT 
	*,
    CASE
		WHEN score_three_parts_as_of_initial_date = 0 THEN "new"
		WHEN booking_count > 0 THEN "booker"
        WHEN score_three_parts_difference = 0 THEN "same"
        WHEN score_three_parts_difference <> 0 THEN "migrated"
        ELSE "unknown"
    END AS rfm_segment_three_parts,
    CASE
		WHEN score_five_parts_as_of_initial_date = 0 THEN "new"
		WHEN booking_count > 0 THEN "booker"
        WHEN score_five_parts_difference = 0 THEN "same"
        WHEN score_five_parts_difference <> 0 THEN "migrated"
        ELSE "unknown"
    END AS rfm_segment_five_parts
FROM (

SELECT
    rfm.user_ptr_id,
    rfm.date_join_cohort,
    b.booking_id,
    b.status,
    b.booking_type,
    b.deliver_method,
    b.car_cat_name,
    marketplace_or_dispatch,
    b.promo_code,
    b.booking_date,
    b.pickup_date,
    b.return_date,
    b.booking_charge_less_discount,
    
    COUNT(b.booking_id) AS booking_count,
    @min_created_at_date AS min_created_at_date,
    @max_created_at_date AS max_created_at_date,
    
    MIN(CASE WHEN rfm.created_at_date = @min_created_at_date THEN rfm.test_group ELSE NULL END) AS test_group_at_min_date,
    
    -- SCORE THREE PART COMPARISON
    MAX(CASE WHEN rfm.created_at_date = @min_created_at_date THEN rfm.score_three_parts ELSE 0 END) AS score_three_parts_as_of_initial_date,
    MAX(CASE WHEN rfm.created_at_date = @max_created_at_date THEN rfm.score_three_parts ELSE 0 END) AS score_three_parts_as_of_most_recent_created_at_date,
    MAX(CASE WHEN rfm.created_at_date = @min_created_at_date THEN rfm.score_three_parts ELSE 0 END) - MAX(CASE WHEN rfm.created_at_date = @max_created_at_date THEN rfm.score_three_parts ELSE 0 END) AS score_three_parts_difference,
    
    -- SCORE FIVE PART COMPARISON
    MAX(CASE WHEN rfm.created_at_date = @min_created_at_date THEN rfm.score_five_parts ELSE 0 END) AS score_five_parts_as_of_initial_date,
    MAX(CASE WHEN rfm.created_at_date = @max_created_at_date THEN rfm.score_five_parts ELSE 0 END) AS score_five_parts_as_of_most_recent_created_at_date,
    MAX(CASE WHEN rfm.created_at_date = @min_created_at_date THEN rfm.score_five_parts ELSE 0 END) - MAX(CASE WHEN rfm.created_at_date = @max_created_at_date THEN rfm.score_five_parts ELSE 0 END) AS score_five_parts_difference
    
FROM rfm_score_summary_history_data AS rfm
LEFT JOIN user_data_combined_booking_data AS b ON rfm.user_ptr_id = b.user_ptr_id
    AND rfm.created_at_date = @min_created_at_date
    AND b.booking_date >= @min_created_at_date_formatted
    AND b.status NOT IN ('Cancelled by User')
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13
ORDER BY rfm.user_ptr_id, b.return_date
) AS a
-- HAVING rfm_segment_three_parts = 'unknown' OR rfm_segment_five_parts = 'unknown'
ORDER BY user_ptr_id ASC;

-- ROLLUP RFM SEGMENTS BY RFM SEGMENT BY DATE JOIN COHORT
SELECT 
	rfm_segment_three_parts,
    rfm_segment_five_parts,
    date_join_cohort,
    count(*),
	FORMAT(COUNT(*), 0) AS count_formatted
FROM
(
SELECT 
	*,
    CASE
		WHEN score_three_parts_as_of_initial_date = 0 THEN "new"
		WHEN booking_count > 0 THEN "booker"
        WHEN score_three_parts_difference = 0 THEN "same"
        WHEN score_three_parts_difference <> 0 THEN "migrated"
        ELSE "unknown"
    END AS rfm_segment_three_parts,
    CASE
		WHEN score_five_parts_as_of_initial_date = 0 THEN "new"
		WHEN booking_count > 0 THEN "booker"
        WHEN score_five_parts_difference = 0 THEN "same"
        WHEN score_five_parts_difference <> 0 THEN "migrated"
        ELSE "unknown"
    END AS rfm_segment_five_parts
FROM (

SELECT
    rfm.user_ptr_id,
    rfm.date_join_cohort,
    b.booking_id,
    b.status,
    b.booking_type,
    b.deliver_method,
    b.car_cat_name,
    marketplace_or_dispatch,
    b.promo_code,
    b.booking_date,
    b.pickup_date,
    b.return_date,
    b.booking_charge_less_discount,
    
    COUNT(b.booking_id) AS booking_count,
    @min_created_at_date AS min_created_at_date,
    @max_created_at_date AS max_created_at_date,
    
    MIN(CASE WHEN rfm.created_at_date = @min_created_at_date THEN rfm.test_group ELSE NULL END) AS test_group_at_min_date,
    
    -- SCORE THREE PART COMPARISON
    MAX(CASE WHEN rfm.created_at_date = @min_created_at_date THEN rfm.score_three_parts ELSE 0 END) AS score_three_parts_as_of_initial_date,
    MAX(CASE WHEN rfm.created_at_date = @max_created_at_date THEN rfm.score_three_parts ELSE 0 END) AS score_three_parts_as_of_most_recent_created_at_date,
    MAX(CASE WHEN rfm.created_at_date = @min_created_at_date THEN rfm.score_three_parts ELSE 0 END) - MAX(CASE WHEN rfm.created_at_date = @max_created_at_date THEN rfm.score_three_parts ELSE 0 END) AS score_three_parts_difference,
    
    -- SCORE FIVE PART COMPARISON
    MAX(CASE WHEN rfm.created_at_date = @min_created_at_date THEN rfm.score_five_parts ELSE 0 END) AS score_five_parts_as_of_initial_date,
    MAX(CASE WHEN rfm.created_at_date = @max_created_at_date THEN rfm.score_five_parts ELSE 0 END) AS score_five_parts_as_of_most_recent_created_at_date,
    MAX(CASE WHEN rfm.created_at_date = @min_created_at_date THEN rfm.score_five_parts ELSE 0 END) - MAX(CASE WHEN rfm.created_at_date = @max_created_at_date THEN rfm.score_five_parts ELSE 0 END) AS score_five_parts_difference
    
FROM rfm_score_summary_history_data AS rfm
LEFT JOIN user_data_combined_booking_data AS b ON rfm.user_ptr_id = b.user_ptr_id
    AND rfm.created_at_date = @min_created_at_date
    AND b.booking_date >= @min_created_at_date_formatted
    AND b.status NOT IN ('Cancelled by User')
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13
ORDER BY rfm.user_ptr_id, b.return_date
) AS a
-- HAVING rfm_segment_three_parts = 'unknown' OR rfm_segment_five_parts = 'unknown'
ORDER BY user_ptr_id ASC
) AS c
GROUP BY 1,2,3 WITH ROLLUP
ORDER BY 1,2,3 DESC,count(*) DESC;

-- ROLLUP RFM SEGMENTS BY RFM SEGMENT
SELECT 
	rfm_segment_three_parts,
    rfm_segment_five_parts,
    count(*),
	FORMAT(COUNT(*), 0) AS count_formatted
FROM
(
SELECT 
	*,
    CASE
		WHEN score_three_parts_as_of_initial_date = 0 THEN "new"
		WHEN booking_count > 0 THEN "booker"
        WHEN score_three_parts_difference = 0 THEN "same"
        WHEN score_three_parts_difference <> 0 THEN "migrated"
        ELSE "unknown"
    END AS rfm_segment_three_parts,
    CASE
		WHEN score_five_parts_as_of_initial_date = 0 THEN "new"
		WHEN booking_count > 0 THEN "booker"
        WHEN score_five_parts_difference = 0 THEN "same"
        WHEN score_five_parts_difference <> 0 THEN "migrated"
        ELSE "unknown"
    END AS rfm_segment_five_parts
FROM (

SELECT
    rfm.user_ptr_id,
    rfm.date_join_cohort,
    b.booking_id,
    b.status,
    b.booking_type,
    b.deliver_method,
    b.car_cat_name,
    marketplace_or_dispatch,
    b.promo_code,
    b.booking_date,
    b.pickup_date,
    b.return_date,
    b.booking_charge_less_discount,
    
    COUNT(b.booking_id) AS booking_count,
    @min_created_at_date AS min_created_at_date,
    @max_created_at_date AS max_created_at_date,
    
    MIN(CASE WHEN rfm.created_at_date = @min_created_at_date THEN rfm.test_group ELSE NULL END) AS test_group_at_min_date,
    
    -- SCORE THREE PART COMPARISON
    MAX(CASE WHEN rfm.created_at_date = @min_created_at_date THEN rfm.score_three_parts ELSE 0 END) AS score_three_parts_as_of_initial_date,
    MAX(CASE WHEN rfm.created_at_date = @max_created_at_date THEN rfm.score_three_parts ELSE 0 END) AS score_three_parts_as_of_most_recent_created_at_date,
    MAX(CASE WHEN rfm.created_at_date = @min_created_at_date THEN rfm.score_three_parts ELSE 0 END) - MAX(CASE WHEN rfm.created_at_date = @max_created_at_date THEN rfm.score_three_parts ELSE 0 END) AS score_three_parts_difference,
    
    -- SCORE FIVE PART COMPARISON
    MAX(CASE WHEN rfm.created_at_date = @min_created_at_date THEN rfm.score_five_parts ELSE 0 END) AS score_five_parts_as_of_initial_date,
    MAX(CASE WHEN rfm.created_at_date = @max_created_at_date THEN rfm.score_five_parts ELSE 0 END) AS score_five_parts_as_of_most_recent_created_at_date,
    MAX(CASE WHEN rfm.created_at_date = @min_created_at_date THEN rfm.score_five_parts ELSE 0 END) - MAX(CASE WHEN rfm.created_at_date = @max_created_at_date THEN rfm.score_five_parts ELSE 0 END) AS score_five_parts_difference
    
FROM rfm_score_summary_history_data AS rfm
LEFT JOIN user_data_combined_booking_data AS b ON rfm.user_ptr_id = b.user_ptr_id
    AND rfm.created_at_date = @min_created_at_date
    AND b.booking_date >= @min_created_at_date_formatted
    AND b.status NOT IN ('Cancelled by User')
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13
ORDER BY rfm.user_ptr_id, b.return_date
) AS a
-- HAVING rfm_segment_three_parts = 'unknown' OR rfm_segment_five_parts = 'unknown'
ORDER BY user_ptr_id ASC
) AS c
GROUP BY 1,2 WITH ROLLUP
ORDER BY 1,2 DESC,count(*) DESC;