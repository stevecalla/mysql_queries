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

-- GET MAX CREATED AT DATE
SELECT
	MIN(created_at_date),
    MAX(created_at_date)
FROM rfm_score_summary_history_data
LIMIT 1;

SELECT created_at_date
FROM rfm_score_summary_history_data
GROUP BY created_at_date
ORDER BY created_at_date DESC
LIMIT 2;

-- GET THE TWO MOST RECENT CREATED AT DATES
SELECT MIN(created_at_date) AS min_created_at_date,
       MAX(created_at_date) AS max_created_at_date
FROM (
    SELECT created_at_date
    FROM rfm_score_summary_history_data
	GROUP BY created_at_date
    ORDER BY created_at_date DESC
    LIMIT 2
) AS recent_dates;

-- HAS A BOOKING AFTER INITIAL DATE
SELECT
	rfm.user_ptr_id,
    rfm.created_at_date,
    rfm.date_join_cohort,
    
    rfm.is_repeat_new_first,
    rfm.all_cities_distinct,
    rfm.all_countries_distinct, 
    rfm.booking_count_total,
    rfm.booking_count_cancel,
    rfm.booking_count_completed,
    rfm.booking_count_started,
    rfm.booking_count_future,
    rfm.booking_count_other,
    rfm.is_currently_started,
    
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
    CASE
		WHEN b.promo_code IS NULL THEN "no"
        ELSE "yes"
	END AS has_promo_code,
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
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28
ORDER BY user_ptr_id, return_date;

-- COMBINE RFM & BOOKING DATA FOR INITIAL DATE & MAX CREATED_AT_DATE
SELECT
    rfm.user_ptr_id,
    rfm.date_join_cohort,
    
    rfm.is_repeat_new_first,
    rfm.all_cities_distinct,
    rfm.all_countries_distinct, 
    rfm.booking_count_total,
    rfm.booking_count_cancel,
    rfm.booking_count_completed,
    rfm.booking_count_started,
    rfm.booking_count_future,
    rfm.booking_count_other,
    rfm.is_currently_started,
    
    b.booking_id,
    b.status,
    b.booking_type,
    b.deliver_method,
    b.car_cat_name,
    marketplace_or_dispatch,
    b.promo_code,
    CASE
		WHEN b.promo_code IS NULL THEN "no"
        ELSE "yes"
	END AS has_promo_code,
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
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24
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
    
    rfm.is_repeat_new_first,
    rfm.all_cities_distinct,
    rfm.all_countries_distinct, 
    rfm.booking_count_total,
    rfm.booking_count_cancel,
    rfm.booking_count_completed,
    rfm.booking_count_started,
    rfm.booking_count_future,
    rfm.booking_count_other,
    rfm.is_currently_started,
    
    b.booking_id,
    b.status,
    b.booking_type,
    b.deliver_method,
    b.car_cat_name,
    marketplace_or_dispatch,
    b.promo_code,
    CASE
		WHEN b.promo_code IS NULL THEN "no"
        ELSE "yes"
	END AS has_promo_code,
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
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24
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
    
    rfm.is_repeat_new_first,
    rfm.all_cities_distinct,
    rfm.all_countries_distinct, 
    rfm.booking_count_total,
    rfm.booking_count_cancel,
    rfm.booking_count_completed,
    rfm.booking_count_started,
    rfm.booking_count_future,
    rfm.booking_count_other,
    rfm.is_currently_started,
    
    b.booking_id,
    b.status,
    b.booking_type,
    b.deliver_method,
    b.car_cat_name,
    marketplace_or_dispatch,
    b.promo_code,
    CASE
		WHEN b.promo_code IS NULL THEN "no"
        ELSE "yes"
	END AS has_promo_code,
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
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24
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
    
    rfm.is_repeat_new_first,
    rfm.all_cities_distinct,
    rfm.all_countries_distinct, 
    rfm.booking_count_total,
    rfm.booking_count_cancel,
    rfm.booking_count_completed,
    rfm.booking_count_started,
    rfm.booking_count_future,
    rfm.booking_count_other,
    rfm.is_currently_started,
    
    b.status,
    b.booking_type,
    b.deliver_method,
    b.car_cat_name,
    marketplace_or_dispatch,
    b.promo_code,
    CASE
		WHEN b.promo_code IS NULL THEN "no"
        ELSE "yes"
	END AS has_promo_code,
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
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24
ORDER BY rfm.user_ptr_id, b.return_date
) AS a
-- HAVING rfm_segment_three_parts = 'unknown' OR rfm_segment_five_parts = 'unknown'
ORDER BY user_ptr_id ASC
) AS c
GROUP BY 1,2 WITH ROLLUP
ORDER BY 1,2 DESC,count(*) DESC;