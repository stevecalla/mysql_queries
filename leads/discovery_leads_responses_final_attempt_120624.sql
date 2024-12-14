USE ezhire_crm;

SET @date_interval = 10;

-- #1) COUNT OF LEADS BASED ON THE @date_interval VARIABLE CURRNTLY SET EQUAL TO YESTERDAY
    SELECT
        COUNT(DISTINCT lm.lead_id) AS count_lead_id

    FROM leads_master AS lm
        LEFT JOIN booking_master AS bm ON lm.app_booking_id = bm.Booking_id
        LEFT JOIN lead_status AS st ON lm.lead_status_id = st.id
        LEFT JOIN lead_sources AS ls ON lm.lead_source_id = ls.id
        LEFT JOIN lead_aswat_Call_Logs acl ON lm.lead_id = acl.Lead_id
    WHERE 
        -- LIMIT DATA TO LAST TWO DAYS
        DATE_FORMAT(lm.created_on, '%Y-%m-%d') = DATE_FORMAT(DATE_ADD(UTC_TIMESTAMP(), INTERVAL 5 HOUR), '%Y-%m-%d') - INTERVAL 1 DAY -- UTC to PST (Pakistan Standard Time)
        -- To remove marketing promo leads
        AND 
        (
            lm.lead_status_id NOT IN (12, 13, 14) OR 
            (
                COALESCE(bm.promo_code, '') NOT IN (SELECT promo_code FROM conversion_excluded_promo_codes WHERE is_active = 1) 
                OR COALESCE(bm.promo_code, '') = '' 
                OR TIMESTAMPDIFF(DAY, lm.created_on, CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00')) <= 7
            )
        )
    ;
-- *******************************************

-- #2) First subquery: Handles cases where multiple leads are associated with a single booking
    SELECT
        DATE_FORMAT(lm.created_on, '%Y-%m-%d') AS created_on_pst,
		bm.Booking_id,
	
 		SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT IF(bm.rental_status IS NULL OR bm.rental_status = '', NULL, bm.rental_status)), ',', 1) AS rental_status, -- first non null rental status,    
 		SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT IF(lm.lead_status_id IS NULL OR lm.lead_status_id = '', NULL, lm.lead_status_id)), ',', 1) AS lead_status_id, -- first non null lead status id
        
		-- GROUP_CONCAT(DISTINCT IF(lm.lead_id IS NULL OR lm.lead_id = '', NULL, lm.lead_id)) AS lead_id_list,
 		SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT IF(lm.lead_id IS NULL OR lm.lead_id = '', NULL, lm.lead_id)), ',', 1) AS lead_id, -- first non null lead_id
		
		-- GROUP_CONCAT(DISTINCT IF(lm.renting_in_country IS NULL OR lm.renting_in_country = '', NULL, lm.renting_in_country)) AS renting_in_country_list,
		SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT IF(lm.renting_in_country IS NULL OR lm.renting_in_country = '', NULL, lm.renting_in_country)), ',', 1) AS renting_in_country, -- first non null renting in country
     
		-- GROUP_CONCAT(DISTINCT IF(ls.source_name IS NULL OR ls.source_name = '', NULL, ls.source_name)) AS source_name_list,
 		SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT IF(ls.source_name IS NULL OR ls.source_name = '', NULL, ls.source_name)), ',', 1) AS source_name, -- first non null source name

        SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT IF(bm.booking_created_on IS NULL OR bm.booking_created_on = '', NULL, bm.booking_created_on)), ',', 1) AS booking_created_on_utc,

        -- COUNT(lm.lead_id) AS count_lead_id,
        COUNT(DISTINCT lm.lead_id) AS count_lead_id

        -- Response Time
        , MIN(lm.created_on) AS min_lead_created_on_pst
        , MIN(acl.Created_On) AS min_call_log_min_created_on_pst
        , CONCAT(
                FLOOR(TIMESTAMPDIFF(SECOND, MIN(lm.created_on), MIN(acl.Created_On)) / 3600), ':', -- Hours
                LPAD(FLOOR(MOD(TIMESTAMPDIFF(SECOND, MIN(lm.created_on), MIN(acl.Created_On)), 3600) / 60), 2, '0'), ':', -- Minutes
                LPAD(MOD(TIMESTAMPDIFF(SECOND, MIN(lm.created_on), MIN(acl.Created_On)), 60), 2, '0') -- Seconds
        ) AS response_time
        
        -- Response Time
        , MIN(lm.created_on) AS min_lead_created_on_pst
        , MIN(acl.Created_On) AS min_call_log_min_created_on_pst
        , CONCAT(
                FLOOR(TIMESTAMPDIFF(SECOND, MIN(lm.created_on), MIN(acl.Created_On)) / 3600), ':', -- Hours
                LPAD(FLOOR(MOD(TIMESTAMPDIFF(SECOND, MIN(lm.created_on), MIN(acl.Created_On)), 3600) / 60), 2, '0'), ':', -- Minutes
                LPAD(MOD(TIMESTAMPDIFF(SECOND, MIN(lm.created_on), MIN(acl.Created_On)), 60), 2, '0') -- Seconds
        ) AS response_time
            
        -- Response Time Binning
        , CASE
            WHEN MIN(acl.Created_On) IS NULL THEN '0) No response time'
            WHEN TIMESTAMPDIFF(MINUTE, MIN(lm.created_on), MIN(acl.Created_On)) <= 2 THEN '1) 0-2 minutes'
            WHEN TIMESTAMPDIFF(MINUTE, MIN(lm.created_on), MIN(acl.Created_On)) BETWEEN 3 AND 5 THEN '2) 3-5 minutes'
            WHEN TIMESTAMPDIFF(MINUTE, MIN(lm.created_on), MIN(acl.Created_On)) BETWEEN 6 AND 10 THEN '3) 6-10 minutes'
            WHEN TIMESTAMPDIFF(MINUTE, MIN(lm.created_on), MIN(acl.Created_On)) BETWEEN 11 AND 15 THEN '4) 11-15 minutes'
            ELSE '5) 15+ minutes'
        END AS response_time_bin

        -- SHIFT BASED ON CREATED TIME              
        , CASE 
                WHEN (CAST(lm.created_on AS TIME) BETWEEN '00:00:00' AND '07:59:59') THEN 'AM Shift 12a-8a'
                WHEN (CAST(lm.created_on AS TIME) BETWEEN '08:00:00' AND '15:59:59') THEN 'Day Shift 8a-4p'
                WHEN (CAST(lm.created_on AS TIME) BETWEEN '16:00:00' AND '23:59:59') THEN 'Night Shift 4p-12a'
                ELSE NULL
        END AS shift

        , 'Multiple Leads per Booking' AS query_source

        -- Max created_on for all records (without per-grouping)
        , (	
            SELECT 
                DATE_SUB(DATE_FORMAT(MAX(created_on), '%Y-%m-%d %H:%i:%s'), INTERVAL 1 HOUR) -- convert pst to gst
            FROM leads_master 
            LIMIT 1
        ) AS max_created_on_gst

    FROM leads_master AS lm
        LEFT JOIN booking_master AS bm ON lm.app_booking_id = bm.Booking_id
        LEFT JOIN lead_status AS st ON lm.lead_status_id = st.id
        LEFT JOIN lead_sources AS ls ON lm.lead_source_id = ls.id
        LEFT JOIN lead_aswat_Call_Logs acl ON lm.lead_id = acl.Lead_id

    WHERE 
        DATE_FORMAT(lm.created_on, '%Y-%m-%d') = DATE_FORMAT(DATE_ADD(UTC_TIMESTAMP(), INTERVAL 5 HOUR), '%Y-%m-%d') - INTERVAL @date_interval DAY -- UTC to PST (Pakistan Standard Time)
        
        -- To remove marketing promo leads
        AND 
        (
            lm.lead_status_id NOT IN (12, 13, 14) OR 
            (
                COALESCE(bm.promo_code, '') NOT IN (SELECT promo_code FROM conversion_excluded_promo_codes WHERE is_active = 1) 
                OR COALESCE(bm.promo_code, '') = '' 
                OR TIMESTAMPDIFF(DAY, lm.created_on, CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00')) <= 7
            )
        )
    GROUP BY DATE_FORMAT(lm.created_on, '%Y-%m-%d'), bm.Booking_id, shift
    HAVING 
		bm.Booking_id IS NOT NULL
        AND count_lead_id > 1
    ORDER BY DATE_FORMAT(lm.created_on, '%Y-%m-%d') DESC
    ;
-- *******************************************
    
-- #3) Second subquery: Handles cases where a single lead is associated with a booking
    SELECT
        DATE_FORMAT(lm.created_on, '%Y-%m-%d') AS created_on_pst,
		bm.Booking_id,
	
 		SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT IF(bm.rental_status IS NULL OR bm.rental_status = '', NULL, bm.rental_status)), ',', 1) AS rental_status, -- first non null rental_status
 		SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT IF(lm.lead_status_id IS NULL OR lm.lead_status_id = '', NULL, lm.lead_status_id)), ',', 1) AS lead_status_id, -- first non null lead status id
        
		-- GROUP_CONCAT(DISTINCT IF(lm.lead_id IS NULL OR lm.lead_id = '', NULL, lm.lead_id)) AS lead_id_list,
 		SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT IF(lm.lead_id IS NULL OR lm.lead_id = '', NULL, lm.lead_id)), ',', 1) AS lead_id, -- first non null lead_id
		
		-- GROUP_CONCAT(DISTINCT IF(lm.renting_in_country IS NULL OR lm.renting_in_country = '', NULL, lm.renting_in_country)) AS renting_in_country_list,
		SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT IF(lm.renting_in_country IS NULL OR lm.renting_in_country = '', NULL, lm.renting_in_country)), ',', 1) AS renting_in_country, -- first non null renting in country
     
		-- GROUP_CONCAT(DISTINCT IF(ls.source_name IS NULL OR ls.source_name = '', NULL, ls.source_name)) AS source_name_list,
 		SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT IF(ls.source_name IS NULL OR ls.source_name = '', NULL, ls.source_name)), ',', 1) AS source_name, -- first non null source name

        SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT IF(bm.booking_created_on IS NULL OR bm.booking_created_on = '', NULL, bm.booking_created_on)), ',', 1) AS booking_created_on_utc,

        -- COUNT(lm.lead_id) AS count_lead_id,
        COUNT(DISTINCT lm.lead_id) AS count_lead_id

        -- Response Time
        , MIN(lm.created_on) AS min_lead_created_on_pst
        , MIN(acl.Created_On) AS min_call_log_min_created_on_pst
        , CONCAT(
                FLOOR(TIMESTAMPDIFF(SECOND, MIN(lm.created_on), MIN(acl.Created_On)) / 3600), ':', -- Hours
                LPAD(FLOOR(MOD(TIMESTAMPDIFF(SECOND, MIN(lm.created_on), MIN(acl.Created_On)), 3600) / 60), 2, '0'), ':', -- Minutes
                LPAD(MOD(TIMESTAMPDIFF(SECOND, MIN(lm.created_on), MIN(acl.Created_On)), 60), 2, '0') -- Seconds
        ) AS response_time
                   
        -- Response Time Binning
        , CASE
            WHEN MIN(acl.Created_On) IS NULL THEN '0) No response time'
            WHEN TIMESTAMPDIFF(MINUTE, MIN(lm.created_on), MIN(acl.Created_On)) <= 2 THEN '1) 0-2 minutes'
            WHEN TIMESTAMPDIFF(MINUTE, MIN(lm.created_on), MIN(acl.Created_On)) BETWEEN 3 AND 5 THEN '2) 3-5 minutes'
            WHEN TIMESTAMPDIFF(MINUTE, MIN(lm.created_on), MIN(acl.Created_On)) BETWEEN 6 AND 10 THEN '3) 6-10 minutes'
            WHEN TIMESTAMPDIFF(MINUTE, MIN(lm.created_on), MIN(acl.Created_On)) BETWEEN 11 AND 15 THEN '4) 11-15 minutes'
            ELSE '5) 15+ minutes'
        END AS response_time_bin

        -- SHIFT BASED ON CREATED TIME
        , CASE 
                WHEN (CAST(lm.created_on AS TIME) BETWEEN '00:00:00' AND '07:59:59') THEN 'AM Shift 12a-8a'
                WHEN (CAST(lm.created_on AS TIME) BETWEEN '08:00:00' AND '15:59:59') THEN 'Day Shift 8a-4p'
                WHEN (CAST(lm.created_on AS TIME) BETWEEN '16:00:00' AND '23:59:59') THEN 'Night Shift 4p-12a'
                ELSE NULL
        END AS shift

        , 'Single Lead per Booking' AS query_source

        -- Max created_on for all records (without per-grouping)
        , (	
            SELECT 
                DATE_SUB(DATE_FORMAT(MAX(created_on), '%Y-%m-%d %H:%i:%s'), INTERVAL 1 HOUR) -- convert pst to gst
            FROM leads_master 
            LIMIT 1
        ) AS max_created_on_gst 

    FROM leads_master AS lm
        LEFT JOIN booking_master AS bm ON lm.app_booking_id = bm.Booking_id
        LEFT JOIN lead_status AS st ON lm.lead_status_id = st.id
        LEFT JOIN lead_sources AS ls ON lm.lead_source_id = ls.id
        LEFT JOIN lead_aswat_Call_Logs acl ON lm.lead_id = acl.Lead_id

    WHERE 
        -- LIMIT DATA TO LAST TWO DAYS
        DATE_FORMAT(lm.created_on, '%Y-%m-%d') = DATE_FORMAT(DATE_ADD(UTC_TIMESTAMP(), INTERVAL 5 HOUR), '%Y-%m-%d') - INTERVAL @date_interval DAY -- UTC to PST (Pakistan Standard Time)
        
        -- To remove marketing promo leads
        AND 
        (
            lm.lead_status_id NOT IN (12, 13, 14) OR 
            (
                COALESCE(bm.promo_code, '') NOT IN (SELECT promo_code FROM conversion_excluded_promo_codes WHERE is_active = 1) 
                OR COALESCE(bm.promo_code, '') = '' 
                OR TIMESTAMPDIFF(DAY, lm.created_on, CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00')) <= 7
            )
        )
    GROUP BY DATE_FORMAT(lm.created_on, '%Y-%m-%d'), bm.Booking_id, shift
    HAVING 
		bm.Booking_id IS NOT NULL
        AND count_lead_id = 1
    ORDER BY DATE_FORMAT(lm.created_on, '%Y-%m-%d') DESC
    ;
-- *******************************************
    
-- #4) Third subquery: Handles cases where leads do not have associated bookings
    SELECT
        DATE_FORMAT(lm.created_on, '%Y-%m-%d') AS created_on_pst,
		bm.Booking_id,

        bm.rental_status,
        lm.lead_status_id,

 		lm.lead_id,

		lm.renting_in_country,
 		ls.source_name,

        bm.booking_created_on AS booking_created_on_utc,

        -- COUNT(lm.lead_id) AS count_lead_id
        COUNT(DISTINCT lm.lead_id) AS count_lead_id
        
        -- Response Time
        , MIN(lm.created_on) AS lead_created_on_pst
        , MIN(acl.Created_On) AS min_call_log_min_created_on_pst
        , CONCAT(
                FLOOR(TIMESTAMPDIFF(SECOND, MIN(lm.created_on), MIN(acl.Created_On)) / 3600), ':', -- Hours
                LPAD(FLOOR(MOD(TIMESTAMPDIFF(SECOND, MIN(lm.created_on), MIN(acl.Created_On)), 3600) / 60), 2, '0'), ':', -- Minutes
                LPAD(MOD(TIMESTAMPDIFF(SECOND, MIN(lm.created_on), MIN(acl.Created_On)), 60), 2, '0') -- Seconds
        ) AS response_time
                   
        -- Response Time Binning
        , CASE
            WHEN MIN(acl.Created_On) IS NULL THEN '0) No response time'
            WHEN TIMESTAMPDIFF(MINUTE, MIN(lm.created_on), MIN(acl.Created_On)) <= 2 THEN '1) 0-2 minutes'
            WHEN TIMESTAMPDIFF(MINUTE, MIN(lm.created_on), MIN(acl.Created_On)) BETWEEN 3 AND 5 THEN '2) 3-5 minutes'
            WHEN TIMESTAMPDIFF(MINUTE, MIN(lm.created_on), MIN(acl.Created_On)) BETWEEN 6 AND 10 THEN '3) 6-10 minutes'
            WHEN TIMESTAMPDIFF(MINUTE, MIN(lm.created_on), MIN(acl.Created_On)) BETWEEN 11 AND 15 THEN '4) 11-15 minutes'
            ELSE '5) 15+ minutes'
        END AS response_time_bin

        -- SHIFT BASED ON CREATED TIME
        , CASE 
                WHEN (CAST(lm.created_on AS TIME) BETWEEN '00:00:00' AND '07:59:59') THEN 'AM Shift 12a-8a'
                WHEN (CAST(lm.created_on AS TIME) BETWEEN '08:00:00' AND '15:59:59') THEN 'Day Shift 8a-4p'
                WHEN (CAST(lm.created_on AS TIME) BETWEEN '16:00:00' AND '23:59:59') THEN 'Night Shift 4p-12a'
                ELSE NULL
        END AS shift

        , 'No Booking' AS query_source,

        -- Max created_on for all records (without per-grouping)
        (	
            SELECT 
                DATE_SUB(DATE_FORMAT(MAX(created_on), '%Y-%m-%d %H:%i:%s'), INTERVAL 1 HOUR) -- convert pst to gst
            FROM leads_master 
            LIMIT 1
        ) AS max_created_on_gst

    FROM leads_master AS lm
        LEFT JOIN booking_master AS bm ON lm.app_booking_id = bm.Booking_id
        LEFT JOIN lead_status AS st ON lm.lead_status_id = st.id
        LEFT JOIN lead_sources AS ls ON lm.lead_source_id = ls.id
        LEFT JOIN lead_aswat_Call_Logs acl ON lm.lead_id = acl.Lead_id

    WHERE 
        -- LIMIT DATA TO LAST TWO DAYS
        DATE_FORMAT(lm.created_on, '%Y-%m-%d') = DATE_FORMAT(DATE_ADD(UTC_TIMESTAMP(), INTERVAL 5 HOUR), '%Y-%m-%d') - INTERVAL @date_interval DAY -- UTC to PST (Pakistan Standard Time)
        AND bm.Booking_id IS NULL
        -- To remove marketing promo leads
        AND 
        (
            lm.lead_status_id NOT IN (12, 13, 14) OR 
            (
                COALESCE(bm.promo_code, '') NOT IN (SELECT promo_code FROM conversion_excluded_promo_codes WHERE is_active = 1) 
                OR COALESCE(bm.promo_code, '') = '' 
                OR TIMESTAMPDIFF(DAY, lm.created_on, CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00')) <= 7
            )
        )
    GROUP BY DATE_FORMAT(lm.created_on, '%Y-%m-%d'), bm.Booking_id, lm.lead_id, lm.renting_in_country, ls.source_name, bm.rental_status, lm.lead_status_id, bm.booking_created_on, shift
    ORDER BY DATE_FORMAT(lm.created_on, '%Y-%m-%d') DESC
    ;
-- *******************************************

-- #5) QUERY TO FIND THE (a) BOOKINGS WITH MULTIPLE LEADS (b) BOOKINGS WITH 1 LEAD (c) LEADS WITH NO BOOKINGS; COMBINE THE DATA THEN CALCULATE STATS
    -- C:\Users\calla\development\ezhire\mysql_queries\leads\discovery_leads_final_attempt_112924.sql

    -- const date_interval = 1; -- for javascript sql script; also change the variable to {date_interval}
    -- modify "=" to ">=" or similar

    SELECT
        CAST(created_on_pst AS CHAR) AS created_on_pst

        -- COMMENT OUT THE THREE FIELDS BELOW AS WELL AS THE RELATED GROUP BY TO SEE A ROLLUP OF THE DATA
        -- , query_source
        -- , renting_in_country
        -- , source_name
        -- , shift
        -- , response_time_bin

        -- LEAD COUNTS
        , CAST(IFNULL(SUM(count_lead_id), 0) AS UNSIGNED) AS count_leads_total
        , CAST(IFNULL(SUM(CASE WHEN lead_status_id IN (16) THEN count_lead_id END), 0) AS UNSIGNED) AS count_leads_invalid
        , CAST(IFNULL(SUM(CASE WHEN lead_status_id NOT IN (16) THEN count_lead_id END), 0) AS UNSIGNED) AS count_leads_valid
        
		-- SAME DAY COUNTS
        , COUNT(DISTINCT CASE 
            WHEN 
                DATE_FORMAT(CONVERT_TZ(booking_created_on_utc, '+00:00', '+05:00'), '%Y-%m-%d') = DATE_FORMAT(created_on_pst, '%Y-%m-%d')
                AND rental_status IN (8)
                AND lead_status_id NOT IN (16)
                AND TIMESTAMPDIFF(DAY, created_on_pst, CONVERT_TZ(booking_created_on_utc, '+00:00', '+05:00')) <= 7
            THEN booking_id 
        END) AS count_booking_same_day_rental_status_cancelled_distinct
        
        , COUNT(DISTINCT CASE 
            WHEN 
                DATE_FORMAT(CONVERT_TZ(booking_created_on_utc, '+00:00', '+05:00'), '%Y-%m-%d') = DATE_FORMAT(created_on_pst, '%Y-%m-%d')
                AND rental_status NOT IN (8)
                AND lead_status_id NOT IN (16)
                AND TIMESTAMPDIFF(DAY, created_on_pst, CONVERT_TZ(booking_created_on_utc, '+00:00', '+05:00')) <= 7
            THEN booking_id 
        END) AS count_booking_same_day_rental_status_not_cancelled_distinct
        
        , COUNT(DISTINCT CASE 
            WHEN 
                DATE_FORMAT(CONVERT_TZ(booking_created_on_utc, '+00:00', '+05:00'), '%Y-%m-%d') = DATE_FORMAT(created_on_pst, '%Y-%m-%d')
                -- AND rental_status NOT IN (8)
                AND lead_status_id NOT IN (16)
                AND TIMESTAMPDIFF(DAY, created_on_pst, CONVERT_TZ(booking_created_on_utc, '+00:00', '+05:00')) <= 7
            THEN booking_id 
        END) AS count_booking_same_day_rental_status_distinct_total
        
        -- TOTAL COUNTS
        , COUNT(CASE 
            WHEN 
                rental_status IN (8)
                AND lead_status_id NOT IN (16)
                AND TIMESTAMPDIFF(DAY, created_on_pst, CONVERT_TZ(booking_created_on_utc, '+00:00', '+05:00')) <= 7
            THEN booking_id 
        END) AS count_booking_id_cancelled_total
        
        , COUNT(CASE 
            WHEN 
                rental_status NOT IN (8)
                AND lead_status_id NOT IN (16)
                AND TIMESTAMPDIFF(DAY, created_on_pst, CONVERT_TZ(booking_created_on_utc, '+00:00', '+05:00')) <= 7
            THEN booking_id 
        END) AS count_booking_id_not_cancelled_total
        
        -- , COUNT(booking_id) AS count_booking_id_total
		, COUNT(CASE 
			WHEN
				booking_id IS NOT NULL
                AND lead_status_id NOT IN (16)
				AND TIMESTAMPDIFF(DAY, created_on_pst, CONVERT_TZ(booking_created_on_utc, '+00:00', '+05:00')) <= 7 THEN booking_id 
        END) AS count_booking_id_total

        -- CURRENT DATE / TIME PST (Pakistan Standard Time)
        , DATE_FORMAT(UTC_TIMESTAMP(), '%Y-%m-%d %H:%i:%s') AS queried_at_utc
        , DATE_FORMAT(DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR), '%Y-%m-%d %H:%i:%s') AS queried_at_gst -- UTC to GST
        , DATE_FORMAT(DATE_ADD(UTC_TIMESTAMP(), INTERVAL 5 HOUR), '%Y-%m-%d %H:%i:%s') AS queried_at_pst -- UTC to PST (Pakistan Standard Time)

        -- Max created_on for all records
        , CAST(MAX(max_created_on_gst) AS CHAR) AS max_created_on_gst
        , (	
            SELECT 
                CAST(MAX(max_created_on_gst) AS CHAR)
            FROM lead_response_data
            LIMIT 1
        ) AS max_created_on_gst_v2

    -- The subquery combines data from multiple sources and scenarios (multiple leads, single lead, or no booking)
    FROM (
        -- First subquery: Handles `cases where multiple leads are associated with a single booking
        SELECT
            DATE_FORMAT(lm.created_on, '%Y-%m-%d') AS created_on_pst,
            NULLIF(bm.Booking_id, '') AS booking_id,

            SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT IF(bm.rental_status IS NULL OR bm.rental_status = '', NULL, bm.rental_status)), ',', 1) AS rental_status,
            SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT IF(lm.lead_status_id IS NULL OR lm.lead_status_id = '', NULL, lm.lead_status_id)), ',', 1) AS lead_status_id,

            -- GROUP_CONCAT(DISTINCT IF(lm.lead_id IS NULL OR lm.lead_id = '', NULL, lm.lead_id)) AS lead_id_list,
            SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT IF(lm.lead_id IS NULL OR lm.lead_id = '', NULL, lm.lead_id)), ',', 1) AS lead_id,
		
            -- GROUP_CONCAT(DISTINCT IF(lm.renting_in_country IS NULL OR lm.renting_in_country = '', NULL, lm.renting_in_country)) AS renting_in_country_list,
            SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT IF(lm.renting_in_country IS NULL OR lm.renting_in_country = '', NULL, lm.renting_in_country)), ',', 1) AS renting_in_country, -- first non null renting in country

            -- GROUP_CONCAT(DISTINCT IF(ls.source_name IS NULL OR ls.source_name = '', NULL, ls.source_name)) AS source_name_list,
            SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT IF(ls.source_name IS NULL OR ls.source_name = '', NULL, ls.source_name)), ',', 1) AS source_name,
     
            SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT IF(bm.booking_created_on IS NULL OR bm.booking_created_on = '', NULL, bm.booking_created_on)), ',', 1) AS booking_created_on_utc,

            -- COUNT(lm.lead_id) AS count_lead_id
            COUNT(DISTINCT lm.lead_id) AS count_lead_id
            
            -- Response Time
            , MIN(lm.created_on) AS min_lead_created_on_pst
            , MIN(acl.Created_On) AS min_call_log_min_created_on_pst
            , CONCAT(
                    FLOOR(TIMESTAMPDIFF(SECOND, MIN(lm.created_on), MIN(acl.Created_On)) / 3600), ':', -- Hours
                    LPAD(FLOOR(MOD(TIMESTAMPDIFF(SECOND, MIN(lm.created_on), MIN(acl.Created_On)), 3600) / 60), 2, '0'), ':', -- Minutes
                    LPAD(MOD(TIMESTAMPDIFF(SECOND, MIN(lm.created_on), MIN(acl.Created_On)), 60), 2, '0') -- Seconds
            ) AS response_time
            
            -- Response Time Binning
            , CASE
                WHEN MIN(acl.Created_On) IS NULL THEN '0) No response time'
                WHEN TIMESTAMPDIFF(MINUTE, MIN(lm.created_on), MIN(acl.Created_On)) <= 2 THEN '1) 0-2 minutes'
                WHEN TIMESTAMPDIFF(MINUTE, MIN(lm.created_on), MIN(acl.Created_On)) BETWEEN 3 AND 5 THEN '2) 3-5 minutes'
                WHEN TIMESTAMPDIFF(MINUTE, MIN(lm.created_on), MIN(acl.Created_On)) BETWEEN 6 AND 10 THEN '3) 6-10 minutes'
                WHEN TIMESTAMPDIFF(MINUTE, MIN(lm.created_on), MIN(acl.Created_On)) BETWEEN 11 AND 15 THEN '4) 11-15 minutes'
                ELSE '5) 15+ minutes'
            END AS response_time_bin

            -- SHIFT BASED ON CREATED TIME
            , CASE 
                    WHEN (CAST(lm.created_on AS TIME) BETWEEN '00:00:00' AND '07:59:59') THEN 'AM Shift 12a-8a'
                    WHEN (CAST(lm.created_on AS TIME) BETWEEN '08:00:00' AND '15:59:59') THEN 'Day Shift 8a-4p'
                    WHEN (CAST(lm.created_on AS TIME) BETWEEN '16:00:00' AND '23:59:59') THEN 'Night Shift 4p-12a'
                    ELSE NULL
            END AS shift

            , 'Multiple Leads per Booking' AS query_source

            -- Max created_on for all records (without per-grouping)
            , (	
                SELECT 
                    DATE_SUB(DATE_FORMAT(MAX(created_on), '%Y-%m-%d %H:%i:%s'), INTERVAL 1 HOUR) -- convert pst to gst
                FROM leads_master 
                LIMIT 1
            ) AS max_created_on_gst

        FROM leads_master AS lm
			LEFT JOIN booking_master AS bm ON lm.app_booking_id = bm.Booking_id
			LEFT JOIN lead_status AS st ON lm.lead_status_id = st.id
			LEFT JOIN lead_sources AS ls ON lm.lead_source_id = ls.id
            LEFT JOIN lead_aswat_Call_Logs acl ON lm.lead_id = acl.Lead_id

        WHERE 
            DATE_FORMAT(lm.created_on, '%Y-%m-%d') >= DATE_FORMAT(DATE_ADD(UTC_TIMESTAMP(), INTERVAL 5 HOUR), '%Y-%m-%d') - INTERVAL @date_interval DAY

            AND (
                lm.lead_status_id NOT IN (12, 13, 14) OR 
                (
                    COALESCE(bm.promo_code, '') NOT IN (SELECT promo_code FROM conversion_excluded_promo_codes WHERE is_active = 1) 
                    OR COALESCE(bm.promo_code, '') = '' 
                    OR TIMESTAMPDIFF(DAY, lm.created_on, CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00')) <= 7
                )
            )
        GROUP BY DATE_FORMAT(lm.created_on, '%Y-%m-%d'), bm.Booking_id, shift
        HAVING bm.Booking_id IS NOT NULL AND count_lead_id > 1

        UNION ALL

        -- Second subquery: Handles cases where a single lead is associated with a booking
        SELECT
            DATE_FORMAT(lm.created_on, '%Y-%m-%d') AS created_on_pst,
            NULLIF(bm.Booking_id, '') AS booking_id,

            SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT IF(bm.rental_status IS NULL OR bm.rental_status = '', NULL, bm.rental_status)), ',', 1) AS rental_status,
            SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT IF(lm.lead_status_id IS NULL OR lm.lead_status_id = '', NULL, lm.lead_status_id)), ',', 1) AS lead_status_id,

            -- GROUP_CONCAT(DISTINCT IF(lm.lead_id IS NULL OR lm.lead_id = '', NULL, lm.lead_id)) AS lead_id_list,
            SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT IF(lm.lead_id IS NULL OR lm.lead_id = '', NULL, lm.lead_id)), ',', 1) AS lead_id,
		
            -- GROUP_CONCAT(DISTINCT IF(lm.renting_in_country IS NULL OR lm.renting_in_country = '', NULL, lm.renting_in_country)) AS renting_in_country_list,
            SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT IF(lm.renting_in_country IS NULL OR lm.renting_in_country = '', NULL, lm.renting_in_country)), ',', 1) AS renting_in_country,
            
            -- GROUP_CONCAT(DISTINCT IF(ls.source_name IS NULL OR ls.source_name = '', NULL, ls.source_name)) AS source_name_list,
            SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT IF(ls.source_name IS NULL OR ls.source_name = '', NULL, ls.source_name)), ',', 1) AS source_name,

            SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT IF(bm.booking_created_on IS NULL OR bm.booking_created_on = '', NULL, bm.booking_created_on)), ',', 1) AS booking_created_on_utc,

            -- COUNT(lm.lead_id) AS count_lead_id
            COUNT(DISTINCT lm.lead_id) AS count_lead_id

            -- Response Time
            , MIN(lm.created_on) AS min_lead_created_on_pst
            , MIN(acl.Created_On) AS min_call_log_min_created_on_pst
            , CONCAT(
                    FLOOR(TIMESTAMPDIFF(SECOND, MIN(lm.created_on), MIN(acl.Created_On)) / 3600), ':', -- Hours
                    LPAD(FLOOR(MOD(TIMESTAMPDIFF(SECOND, MIN(lm.created_on), MIN(acl.Created_On)), 3600) / 60), 2, '0'), ':', -- Minutes
                    LPAD(MOD(TIMESTAMPDIFF(SECOND, MIN(lm.created_on), MIN(acl.Created_On)), 60), 2, '0') -- Seconds
            ) AS response_time
                   
            -- Response Time Binning
            , CASE
                WHEN MIN(acl.Created_On) IS NULL THEN '0) No response time'
                WHEN TIMESTAMPDIFF(MINUTE, MIN(lm.created_on), MIN(acl.Created_On)) <= 2 THEN '1) 0-2 minutes'
                WHEN TIMESTAMPDIFF(MINUTE, MIN(lm.created_on), MIN(acl.Created_On)) BETWEEN 3 AND 5 THEN '2) 3-5 minutes'
                WHEN TIMESTAMPDIFF(MINUTE, MIN(lm.created_on), MIN(acl.Created_On)) BETWEEN 6 AND 10 THEN '3) 6-10 minutes'
                WHEN TIMESTAMPDIFF(MINUTE, MIN(lm.created_on), MIN(acl.Created_On)) BETWEEN 11 AND 15 THEN '4) 11-15 minutes'
                ELSE '5) 15+ minutes'
            END AS response_time_bin

            -- SHIFT BASED ON CREATED TIME
            , CASE 
                    WHEN (CAST(lm.created_on AS TIME) BETWEEN '00:00:00' AND '07:59:59') THEN 'AM Shift 12a-8a'
                    WHEN (CAST(lm.created_on AS TIME) BETWEEN '08:00:00' AND '15:59:59') THEN 'Day Shift 8a-4p'
                    WHEN (CAST(lm.created_on AS TIME) BETWEEN '16:00:00' AND '23:59:59') THEN 'Night Shift 4p-12a'
                    ELSE NULL
            END AS shift

            , 'Single Lead per Booking' AS query_source

            -- Max created_on for all records (without per-grouping)
            , (	
                SELECT 
                    DATE_SUB(DATE_FORMAT(MAX(created_on), '%Y-%m-%d %H:%i:%s'), INTERVAL 1 HOUR) -- convert pst to gst
                FROM leads_master 
                LIMIT 1
            ) AS max_created_on_gst

        FROM leads_master AS lm
			LEFT JOIN booking_master AS bm ON lm.app_booking_id = bm.Booking_id
			LEFT JOIN lead_status AS st ON lm.lead_status_id = st.id
			LEFT JOIN lead_sources AS ls ON lm.lead_source_id = ls.id
            LEFT JOIN lead_aswat_Call_Logs acl ON lm.lead_id = acl.Lead_id

        WHERE 
            DATE_FORMAT(lm.created_on, '%Y-%m-%d') >= DATE_FORMAT(DATE_ADD(UTC_TIMESTAMP(), INTERVAL 5 HOUR), '%Y-%m-%d') - INTERVAL @date_interval DAY
            AND (
                lm.lead_status_id NOT IN (12, 13, 14) OR 
                (
                    COALESCE(bm.promo_code, '') NOT IN (SELECT promo_code FROM conversion_excluded_promo_codes WHERE is_active = 1) 
                    OR COALESCE(bm.promo_code, '') = '' 
                    OR TIMESTAMPDIFF(DAY, lm.created_on, CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00')) <= 7
                )
            )
        GROUP BY DATE_FORMAT(lm.created_on, '%Y-%m-%d'), bm.Booking_id, shift
        HAVING bm.Booking_id IS NOT NULL AND count_lead_id = 1

        UNION ALL

        -- Third subquery: Handles cases where leads do not have associated bookings
        SELECT
            DATE_FORMAT(lm.created_on, '%Y-%m-%d') AS created_on_pst,
            NULLIF(bm.Booking_id, '') AS booking_id,

            bm.rental_status,
            lm.lead_status_id,

            lm.lead_id,

            lm.renting_in_country,
            ls.source_name,

            bm.booking_created_on AS booking_created_on_utc,

            -- COUNT(lm.lead_id) AS count_lead_id
            COUNT(DISTINCT lm.lead_id) AS count_lead_id
            
            -- Response Time
            , MIN(lm.created_on) AS lead_created_on_pst
            , MIN(acl.Created_On) AS min_call_log_min_created_on_pst
            , CONCAT(
                    FLOOR(TIMESTAMPDIFF(SECOND, MIN(lm.created_on), MIN(acl.Created_On)) / 3600), ':', -- Hours
                    LPAD(FLOOR(MOD(TIMESTAMPDIFF(SECOND, MIN(lm.created_on), MIN(acl.Created_On)), 3600) / 60), 2, '0'), ':', -- Minutes
                    LPAD(MOD(TIMESTAMPDIFF(SECOND, MIN(lm.created_on), MIN(acl.Created_On)), 60), 2, '0') -- Seconds
            ) AS response_time
                    
            -- Response Time Binning
            , CASE
                WHEN MIN(acl.Created_On) IS NULL THEN '0) No response time'
                WHEN TIMESTAMPDIFF(MINUTE, MIN(lm.created_on), MIN(acl.Created_On)) <= 2 THEN '1) 0-2 minutes'
                WHEN TIMESTAMPDIFF(MINUTE, MIN(lm.created_on), MIN(acl.Created_On)) BETWEEN 3 AND 5 THEN '2) 3-5 minutes'
                WHEN TIMESTAMPDIFF(MINUTE, MIN(lm.created_on), MIN(acl.Created_On)) BETWEEN 6 AND 10 THEN '3) 6-10 minutes'
                WHEN TIMESTAMPDIFF(MINUTE, MIN(lm.created_on), MIN(acl.Created_On)) BETWEEN 11 AND 15 THEN '4) 11-15 minutes'
                ELSE '5) 15+ minutes'
            END AS response_time_bin

            -- SHIFT BASED ON CREATED TIME
            , CASE 
                    WHEN (CAST(lm.created_on AS TIME) BETWEEN '00:00:00' AND '07:59:59') THEN 'AM Shift 12a-8a'
                    WHEN (CAST(lm.created_on AS TIME) BETWEEN '08:00:00' AND '15:59:59') THEN 'Day Shift 8a-4p'
                    WHEN (CAST(lm.created_on AS TIME) BETWEEN '16:00:00' AND '23:59:59') THEN 'Night Shift 4p-12a'
                    ELSE NULL
            END AS shift

            , 'No Booking' AS query_source

            -- Max created_on for all records (without per-grouping)
            , (	
                SELECT 
                    DATE_SUB(DATE_FORMAT(MAX(created_on), '%Y-%m-%d %H:%i:%s'), INTERVAL 1 HOUR) -- convert pst to gst
                FROM leads_master 
                LIMIT 1
            ) AS max_created_on_gst

        FROM leads_master AS lm
			LEFT JOIN booking_master AS bm ON lm.app_booking_id = bm.Booking_id
			LEFT JOIN lead_status AS st ON lm.lead_status_id = st.id
            LEFT JOIN lead_sources AS ls ON lm.lead_source_id = ls.id
            LEFT JOIN lead_aswat_Call_Logs acl ON lm.lead_id = acl.Lead_id

        WHERE 
            DATE_FORMAT(lm.created_on, '%Y-%m-%d') >= DATE_FORMAT(DATE_ADD(UTC_TIMESTAMP(), INTERVAL 5 HOUR), '%Y-%m-%d') - INTERVAL @date_interval DAY
            AND bm.Booking_id IS NULL
            AND (
                lm.lead_status_id NOT IN (12, 13, 14) OR 
                (
                    COALESCE(bm.promo_code, '') NOT IN (SELECT promo_code FROM conversion_excluded_promo_codes WHERE is_active = 1) 
                    OR COALESCE(bm.promo_code, '') = '' 
                    OR TIMESTAMPDIFF(DAY, lm.created_on, CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00')) <= 7
                )
            )
        GROUP BY DATE_FORMAT(lm.created_on, '%Y-%m-%d'), bm.Booking_id, lm.lead_id, lm.renting_in_country, ls.source_name, bm.rental_status, lm.lead_status_id, bm.booking_created_on, shift
    ) AS combined_results
	-- GROUP BY created_on_pst, 2, 3, 4, 5, 6
    GROUP BY created_on_pst
    ORDER BY created_on_pst DESC
    ;
-- *******************************************

