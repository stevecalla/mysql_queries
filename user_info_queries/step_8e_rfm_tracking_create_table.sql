USE ezhire_user_data;

SET @min_created_at_date = (SELECT MIN(created_at_date) FROM rfm_score_summary_history_data);
SET @min_created_at_date_formatted = STR_TO_DATE((SELECT MIN(created_at_date) FROM rfm_score_summary_history_data), '%m/%d/%Y');
SET @max_created_at_date = (SELECT MAX(created_at_date) FROM rfm_score_summary_history_data);

DROP TABLE IF EXISTS rfm_score_summary_history_data_tracking;

CREATE TABLE rfm_score_summary_history_data_tracking AS
SELECT 
    *,
    CASE
        WHEN score_three_parts_as_of_initial_date = 0 THEN 'new'
        WHEN booking_count > 0 THEN 'booker'
        WHEN score_three_parts_difference = 0 THEN 'same'
        WHEN score_three_parts_difference <> 0 THEN 'migrated'
        ELSE 'unknown'
    END AS rfm_segment_three_parts,
    CASE
        WHEN score_five_parts_as_of_initial_date = 0 THEN 'new'
        WHEN booking_count > 0 THEN 'booker'
        WHEN score_five_parts_difference = 0 THEN 'same'
        WHEN score_five_parts_difference <> 0 THEN 'migrated'
        ELSE 'unknown'
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
        b.marketplace_or_dispatch,
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
    GROUP BY rfm.user_ptr_id, rfm.date_join_cohort, rfm.is_repeat_new_first, rfm.all_cities_distinct, rfm.all_countries_distinct, rfm.booking_count_total, rfm.booking_count_cancel, rfm.booking_count_completed, rfm.booking_count_started, rfm.booking_count_future, rfm.booking_count_other, rfm.is_currently_started, b.booking_id, b.status, b.booking_type, b.deliver_method, b.car_cat_name, b.marketplace_or_dispatch, b.promo_code, b.has_promo_code, b.booking_date, b.pickup_date, b.return_date, b.booking_charge_less_discount
) AS a;

SELECT * FROM rfm_score_summary_history_data_tracking;
SELECT min_created_at_date, max_created_at_date, count(*) FROM rfm_score_summary_history_data_tracking GROUP BY min_created_at_date, max_created_at_date ORDER BY count(*);
SELECT rfm_segment_three_parts, min_created_at_date, max_created_at_date, count(*) FROM rfm_score_summary_history_data_tracking GROUP BY rfm_segment_three_parts, min_created_at_date, max_created_at_date WITH ROLLUP ORDER BY count(*);
SELECT rfm_segment_five_parts, min_created_at_date, max_created_at_date, count(*) FROM rfm_score_summary_history_data_tracking GROUP BY rfm_segment_five_parts, min_created_at_date, max_created_at_date WITH ROLLUP ORDER BY count(*);
