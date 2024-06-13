USE ezhire_booking_data;
SELECT * FROM ezhire_booking_data.booking_data; -- 252,081 	(as of 3/20/24 6pm); all bookings excluding test bookings (~7k)

-- -- KEY METRICS DATA SETS
-- USE ezhire_key_metrics;					
-- SELECT * FROM calendar_table;  			-- 3,999		"step0_key_stats_create_db_and_calendar_031424.sql"
-- SHOW INDEXES FROM key_metrics_base;
-- SELECT * FROM key_metrics_base;  		-- 251,640	 	"step1_key_stats_key_metrics_base_031424" 			used in all the key_metrics queries below

-- -- SELECT * FROM key_metrics; 				-- 535	 		"step2b_key_onrent_calc_multiple_031424.sql" 		executes logic in small blocks then joins data together
-- SELECT * FROM key_metrics_core_onrent_days; 	-- 535  "step2a_script key_stats_onrent_calc_031424.sql"	all code in one file
-- SELECT * FROM key_metrics_data; 		-- 535; 		"sql_getKeyMetrics_loop.js"	node script				used key_metrics_base in generateOnRentSQL_031624.js
-- -- view key metrics stats

-- PACING METERICS DATA SETS
USE ezhire_pacing_metrics;
SELECT * FROM calendar_table; 			-- 1,461		xxx
SELECT * FROM pacing_base; 				-- 78,290		xxx
SELECT * FROM pacing_base_groupby; 		-- 737			xxx
SELECT * FROM pacing_base_all_calendar_dates; -- 1,615	xxx
SELECT * FROM temp; 					-- 51			xxx
SELECT * FROM pacing_final_data; 		-- 1,615		xxx
