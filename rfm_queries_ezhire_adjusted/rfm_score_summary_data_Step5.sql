#		CREATE TABLE ${table}

DROP TEMPORARY TABLE IF EXISTS rfm_score_summary_data;
CREATE TEMPORARY TABLE rfm_score_summary_data
SELECT * 
    ,CONCAT(rfm.recency_score_three_parts, rfm.frequency_score_three_parts, rfm.monetary_score_three_parts) AS score_three_parts
    
		,FIRST_VALUE(rfm.booking_most_recent_return_vs_now) OVER (PARTITION BY rfm.recency_score_three_parts ORDER BY rfm.booking_most_recent_return_vs_now DESC) AS three_parts_first_recency_amount,    
		LAST_VALUE(rfm.booking_most_recent_return_vs_now) OVER (
		PARTITION BY rfm.recency_score_three_parts 
		ORDER BY rfm.booking_most_recent_return_vs_now DESC
		ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
		) AS three_parts_last_recency_amount,

		FIRST_VALUE(rfm.total_days_per_completed_and_started_bookings) OVER (PARTITION BY rfm.frequency_score_three_parts ORDER BY rfm.total_days_per_completed_and_started_bookings DESC) AS three_parts_first_frequency_amount,    
		LAST_VALUE(rfm.total_days_per_completed_and_started_bookings) OVER (
		PARTITION BY rfm.frequency_score_three_parts 
		ORDER BY rfm.total_days_per_completed_and_started_bookings DESC
		ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
		) AS three_parts_last_frequency_amount,

		FIRST_VALUE(rfm.booking_charge__less_discount_aed_per_completed_started_bookings) OVER (PARTITION BY rfm.monetary_score_three_parts ORDER BY rfm.booking_charge__less_discount_aed_per_completed_started_bookings DESC) AS three_parts_first_monetary_amount,    
		LAST_VALUE(rfm.booking_charge__less_discount_aed_per_completed_started_bookings) OVER (
		PARTITION BY rfm.monetary_score_three_parts 
		ORDER BY rfm.booking_charge__less_discount_aed_per_completed_started_bookings DESC
		ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
		) AS three_parts_last_monetary_amount,

		-- FIRST & LAST VALUE - FIVE PARTS
		CONCAT(rfm.recency_score_five_parts, rfm.frequency_score_five_parts, rfm.monetary_score_five_parts) AS score_five_parts,

		FIRST_VALUE(rfm.booking_most_recent_return_vs_now) OVER (PARTITION BY rfm.recency_score_five_parts ORDER BY rfm.booking_most_recent_return_vs_now DESC) AS five_parts_first_recency_amount,    
		LAST_VALUE(rfm.booking_most_recent_return_vs_now) OVER (
		PARTITION BY rfm.recency_score_five_parts 
		ORDER BY rfm.booking_most_recent_return_vs_now DESC
		ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
		) AS five_parts_last_recency_amount,

		FIRST_VALUE(rfm.total_days_per_completed_and_started_bookings) OVER (PARTITION BY rfm.frequency_score_five_parts ORDER BY rfm.total_days_per_completed_and_started_bookings DESC) AS five_parts_first_frequency_amount,    
		LAST_VALUE(rfm.total_days_per_completed_and_started_bookings) OVER (
		PARTITION BY rfm.frequency_score_five_parts 
		ORDER BY rfm.total_days_per_completed_and_started_bookings DESC
		ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
		) AS five_parts_last_frequency_amount,

		FIRST_VALUE(rfm.booking_charge__less_discount_aed_per_completed_started_bookings) OVER (PARTITION BY rfm.monetary_score_five_parts ORDER BY rfm.booking_charge__less_discount_aed_per_completed_started_bookings DESC) AS five_parts_first_monetary_amount,    
		LAST_VALUE(rfm.booking_charge__less_discount_aed_per_completed_started_bookings) OVER (
		PARTITION BY rfm.monetary_score_five_parts 
		ORDER BY rfm.booking_charge__less_discount_aed_per_completed_started_bookings DESC
		ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
		) AS five_parts_last_monetary_amount,

		CASE WHEN RAND() < 0.2 THEN 'Control' ELSE 'Experiment' END AS test_group
FROM (
			SELECT 
				user_ptr_id,
				date_join_cohort,
				email,
				mobile,
				telephone,
				first_name,
				last_name,
        
				-- COUNTRY / CITY
				all_countries_distinct,
				all_cities_distinct,
        
				-- PROMO CODE STATUS -- TODO: NEW
				#all_promo_codes_distinct,
				#promo_code_on_most_recent_booking,
				#used_promo_code_last_14_days_flag,
				#used_promo_code_on_every_booking,

				-- BOOKING TYPE
				#booking_type_all_distinct, 
				#booking_type_most_recent,
		
				booking_count_total,
				booking_count_cancel,
				booking_count_completed,
				booking_count_started,
				booking_count_future,
				booking_count_other,
		
				is_currently_started,
				is_repeat_new_first,
				is_renter,
				is_looker,
				is_canceller,
				booking_most_recent_return_date,
				rfm_recency_metric,
                booking_most_recent_return_vs_now,
                rfm_frequency_metric,
                total_days_per_completed_and_started_bookings,
				rfm_monetary_metric,
                booking_charge__less_discount_aed_per_completed_started_bookings,
				FORMAT(percent_rank() OVER (ORDER BY rfm_recency_metric), 2) AS recency_rank,
				ROW_NUMBER() OVER (ORDER BY rfm_recency_metric, booking_most_recent_return_date) AS row_number_id,
				COUNT(*) OVER () AS total_rows,
				ROW_NUMBER() OVER (ORDER BY rfm_recency_metric, booking_most_recent_return_date) / COUNT(*) OVER () AS row_percent,

				-- For Recency
				NTILE(3) OVER (ORDER BY rfm_recency_metric DESC) AS recency_score_three_parts,
				NTILE(5) OVER (ORDER BY rfm_recency_metric DESC) AS recency_score_five_parts,

				-- For Frequency
				NTILE(3) OVER (ORDER BY rfm_frequency_metric ASC) AS frequency_score_three_parts,		
				NTILE(5) OVER (ORDER BY rfm_frequency_metric ASC)  AS frequency_score_five_parts,

				-- For Monetary
				NTILE(3) OVER (ORDER BY rfm_monetary_metric ASC) AS monetary_score_three_parts,
				NTILE(5) OVER (ORDER BY rfm_monetary_metric ASC) AS monetary_score_five_parts

                
			#,total_days_per_completed_and_started_bookings
            #,booking_charge__less_discount_aed_per_completed_started_bookings
			FROM user_data_profile

			--  TOTAL WITH NO FILTER = 594,998
			WHERE 
				is_renter = "yes" -- 95,129 row(s) IN ('repeat', 'first', 'new')
					AND is_currently_started LIKE "no" -- 92,200 row(s)
					AND booking_count_future = 0 
					AND booking_count_other = 0 -- 91,989 row(s)
					#AND booking_most_recent_return_date IS NOT NULL -- 91,984 row(s)
					#AND (rfm_recency_metric >= 0 OR rfm_frequency_metric >= 0 OR rfm_recency_metric >= 0)
					#AND booking_charge__less_discount_aed_per_completed_started_bookings >= 0 -- 91,813 row(s)
					#AND total_days_per_completed_and_started_bookings >= 0 -- 91,813
					AND all_countries_distinct LIKE '%United Arab Emirates%' -- 80,487 UAE combined with other countries
					-- AND all_countries_distinct LIKE 'United Arab Emirates' -- 80,105 only UAE (not UAE and other countries)
			#ORDER BY rfm_recency_metric, booking_most_recent_return_date ASC
	)rfm;
    
    SELECT * FROM rfm_score_summary_data;
    SELECT
	user_ptr_id,
    date_join_cohort,
    
    -- RECENCY
    booking_most_recent_return_date,
    booking_most_recent_return_vs_now,
    
    -- FREQUENCY
    total_days_per_completed_and_started_bookings,
    
    -- MONETARY
    booking_charge__less_discount_aed_per_completed_started_bookings,
    
    -- SCORES
    score_three_parts,
    score_five_parts,
    
    -- CONTROL V EXPERIMENT
    test_group
    
FROM rfm_score_summary_data 
-- WHERE user_ptr_id IN (125230)
-- WHERE user_ptr_id IN (706144, 272965) 
-- LIMIT 10
;