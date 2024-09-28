use ezhire_user_data;

-- REVIEW TABLE COMBINED BOOKING & USER DATA
SELECT *
FROM user_data_combined_booking_data as b
WHERE b.promo_code IN ('MY100');

-- GET ALL BOOKINGS FOR PROMO CODE = MY100
SELECT b.user_ptr_id, b.booking_id, b.promo_code, b.status, h.score_three_parts, b.booking_date, b.booking_type, h.test_group
FROM user_data_combined_booking_data as b
	LEFT JOIN rfm_score_summary_history_data AS h ON b.user_ptr_id = h.user_ptr_id
WHERE b.promo_code IN ('MY100')
	-- AND h.created_at_date IN ('2024-09-24', '2024-09-25')
ORDER BY h.score_three_parts ASC;

-- GET ALL BOOKINGS FOR PROMO CODE = MY100 NOT IN TEST COHORTS 133, 233, 333
SELECT b.user_ptr_id, b.booking_id, b.promo_code, b.status, h.score_three_parts, b.booking_date, b.booking_type, h.test_group
FROM user_data_combined_booking_data as b
	LEFT JOIN rfm_score_summary_history_data AS h ON b.user_ptr_id = h.user_ptr_id
WHERE b.promo_code IN ('MY100')
	AND h.created_at_date IN ('2024-09-24', '2024-09-25')
    -- AND h.score_three_parts NOT IN (233)
ORDER BY h.score_three_parts ASC;
    
-- GET BOOKING DATA FOR PROMO CODE LEAKAGE USERS
SELECT b.user_ptr_id, b.booking_id, b.promo_code, b.status, b.booking_date, b.pickup_date, b.return_date, b.booking_type
FROM user_data_combined_booking_data as b
WHERE b.user_ptr_id IN ('90721', '326341', '364262', '467795', '556502', '622227')
ORDER by b.user_ptr_id, b.booking_date;
    
