USE ezhire_crm;

-- Step #1 = this query shows lead / booking counts with and without duplicates. 
-- Duplicates exist because 1 booking is assigned to multiple lead ids.
    SELECT 
        created_on_pst_lm,
        -- GROUP_CONCAT(DISTINCT created_on_pst_lm_date), -- to view duplicate created on dates
        
        SUM(count_leads) AS count_lead_total, -- included duplicates thus not valid
        COUNT(DISTINCT lead_id_lm) AS count_lead_distinct, -- since these are grouped in the subquery, the count is accurately unique/distinct
        SUM(count_leads) - COUNT(DISTINCT lead_id_lm) AS variance_leads,
        
        SUM(count_bookings) AS count_booking_total, -- include duplicates thus not valid
        COUNT(DISTINCT booking_id_bm) AS count_booking_distinct, -- since these are grouped in the subquery, the count is accurately unique/distinct
        SUM(count_bookings) - COUNT(DISTINCT booking_id_bm) AS variance_bookings
    FROM (
        -- this query groups by booking id if there is a booking id & group concats the fields to ensure each field is only counted as one row (not multiple rows); this handles duplicates
        SELECT 
            bm.Booking_id AS booking_id_bm,
            DATE(lm.created_on) AS created_on_pst_lm,
            GROUP_CONCAT(bm.Created_on) AS created_on_utc_bm,
            GROUP_CONCAT(CONVERT_TZ(bm.Created_on, '+00:00', '+05:00')) AS created_on_pst_bm, -- Adjust UTC to PST
            GROUP_CONCAT(lm.lead_id) AS lead_id_lm,
            GROUP_CONCAT(lm.created_on) AS created_on_pst_lm_grouped, -- Already in PST
            GROUP_CONCAT(DATE(lm.created_on)) AS created_on_pst_lm_date, -- Extract date for grouping
            GROUP_CONCAT(cl.min_created_on_cl),
            
            -- Determine the shift based on the created time
            GROUP_CONCAT(CASE 
                WHEN CAST(lm.created_on AS TIME) BETWEEN '00:00:00' AND '07:59:59' THEN 'AM: 12a-8a'
                WHEN CAST(lm.created_on AS TIME) BETWEEN '08:00:00' AND '15:59:59' THEN 'Day: 8a-4p'
                WHEN CAST(lm.created_on AS TIME) BETWEEN '16:00:00' AND '23:59:59' THEN 'Night: 4p-12a'
                ELSE NULL
            END) AS shift,
            
            COUNT(bm.Booking_id) AS count_bookings,
            COUNT(lm.lead_id) AS count_leads
        FROM leads_master AS lm
            LEFT JOIN booking_master AS bm 
                ON lm.app_booking_id = bm.Booking_id
            -- this join finds the min created on call log for each lead id (& makes the query more efficent)
            LEFT JOIN (
                SELECT 
                    Lead_id,
                    MIN(CREATED_On) AS min_created_on_cl
                FROM lead_aswat_Call_Logs
                GROUP BY Lead_id
            ) AS cl ON lm.lead_id = cl.Lead_id

        -- WHERE DATE(lm.created_on) = '2024-12-04'

        -- this group by groups by booking id when there is a booking id (thus ensuring booking ids assigned to more than 1 lead are only counted once for the booking id and lead id)
        -- if there is no booking id then the it is grouped by lead id
        GROUP BY 
            CASE 
                WHEN bm.Booking_id IS NOT NULL THEN bm.Booking_id 
                ELSE lm.lead_id
            END,
            booking_id_bm,
            created_on_pst_lm
    ) AS subquery
    GROUP BY 
        created_on_pst_lm DESC
        -- created_on_pst_lm_date
    ;
-- *******************************************
