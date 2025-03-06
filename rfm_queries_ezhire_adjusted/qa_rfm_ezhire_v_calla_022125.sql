-- SET @user_id = "161549,96214,565263,570744,460721,125230,101999,650422,78306"; -- 1st sample set
-- SET @booking_id = "70713,71220,248667,251309,49462,47926,64699,304017";  -- 1st sample set

SET @user_id = "276033,220300,433284,90574,230847,424927,256050,389223,192627";  -- 2nd sample set

-- ***************************
# GET USER BOOKING INFO FROM USER COMBINED DATA TABLE
-- ***************************
-- select * from ezhire_user_data.user_data_combined_booking_data WHERE user_ptr_id IN (96214);
SELECT
	'combined table', user_ptr_id, booking_id, days, booking_charge_less_discount_aed 
FROM ezhire_user_data.user_data_combined_booking_data 
WHERE FIND_IN_SET(user_ptr_id, @user_id)
-- WHERE FIND_IN_SET(booking_id, @booking_id)
ORDER BY user_ptr_id, booking_id
;

-- ***************************
# GET USER BOOKING INFO FROM BOOKING DATA TABLE
-- ***************************
SELECT * FROM ezhire_booking_data.booking_data WHERE FIND_IN_SET(booking_id, @booking_id);
SELECT 
	'booking table', booking_id, early_return, days, booking_charge_less_discount_aed 
FROM ezhire_booking_data.booking_data 
WHERE FIND_IN_SET(booking_id, @booking_id);

-- ***************************
# GET USER BOOKING INFO USER PROFILE
-- ***************************
-- SELECT * from ezhire_user_data.user_data_profile WHERE FIND_IN_SET(user_ptr_id, @user_id);
SELECT
	'user profile', user_ptr_id, booking_count_not_cancel, booking_days_total, booking_charge_total_less_discount_aed, booking_charge__less_discount_aed_per_completed_started_bookings, rfm_recency_metric, rfm_frequency_metric, rfm_monetary_metric
FROM ezhire_user_data.user_data_profile
WHERE FIND_IN_SET(user_ptr_id, @user_id);
-- ***************************

-- ***************************
# GET USER INFO FROM RFM SUMMARY TABLE
-- ***************************
-- SELECT * from ezhire_user_data.user_data_combined_booking_data WHERE user_ptr_id IN (96214);
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
    
FROM ezhire_user_data.rfm_score_summary_data 
-- WHERE FIND_IN_SET(user_ptr_id, @user_id)
;


SELECT * FROM ezhire_user_data.rfm_score_summary_data;
-- ***************************
# EARLY RETURN TABLE
-- ***************************
-- SELECT 
-- 	*
-- FROM myproject.rental_early_return_charges as erc
-- -- WHERE erc.booking_id IN (248667);
-- WHERE erc.booking_id IN (251309);