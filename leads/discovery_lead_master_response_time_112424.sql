USE ezhire_crm;
SELECT VERSION();

SET @target_date = '2024-11-24';

SELECT 'lead_master table', COUNT(*) FROM leads_master_log WHERE DATE(created_on) = @target_date;
SELECT * FROM leads_master_log WHERE DATE(created_on) = @target_date;

-- #1) LEAD RESPONSE TIME RAW DETAIL BY LEAD MASTER ID
      SELECT        
            lead_master_id, 
            MIN(created_on) AS created_on,
            MIN(updated_on) AS first_updated_on,
            COUNT(*),      
      
      -- Response Time
            CONCAT(
                  FLOOR(TIMESTAMPDIFF(SECOND, MIN(created_on), MIN(updated_on)) / 3600), ':', -- Hours
                  LPAD(FLOOR(MOD(TIMESTAMPDIFF(SECOND, MIN(created_on), MIN(updated_on)), 3600) / 60), 2, '0'), ':', -- Minutes
                  LPAD(MOD(TIMESTAMPDIFF(SECOND, MIN(created_on), MIN(updated_on)), 60), 2, '0') -- Seconds
            ) AS response_time,
      
            -- Response Time Binning
            CASE
                  WHEN MIN(updated_on) IS NULL THEN '0) MIN(updated_on) is NULL'
                  WHEN TIMESTAMPDIFF(MINUTE, MIN(created_on), MIN(updated_on)) <= 2 THEN '1) 0-2 minutes'
                  WHEN TIMESTAMPDIFF(MINUTE, MIN(created_on), MIN(updated_on)) BETWEEN 3 AND 5 THEN '2) 3-5 minutes'
                  WHEN TIMESTAMPDIFF(MINUTE, MIN(created_on), MIN(updated_on)) BETWEEN 6 AND 10 THEN '3) 6-10 minutes'
                  WHEN TIMESTAMPDIFF(MINUTE, MIN(created_on), MIN(updated_on)) BETWEEN 11 AND 15 THEN '4) 11-15 minutes'
                  ELSE '5) 15+ minutes'
            END AS response_time_bin,

            -- Created On Time Segment
            CASE
                  WHEN TIME(MIN(created_on)) BETWEEN '08:00:00' AND '16:00:00' THEN '1) 8am-4pm'
                  WHEN TIME(MIN(created_on)) BETWEEN '16:00:01' AND '23:59:59' THEN '2) 4pm-12am'
                  ELSE '0) 12am-8am'
            END AS created_on_time_segment

      FROM leads_master_log 
      WHERE DATE(created_on) = @target_date
      GROUP BY 1
      ;
-- *******************************************

-- #2) LEAD RESPONSE TIME ROLLUP BY RESPONSE TIME BIN BY LEAD CREATED HOUR
      SELECT 
            @target_date AS target_date,  
            
            IFNULL(response_time_bin, 'Grand Total') AS response_time_bin,
            
            COUNT(CASE WHEN created_on_time_segment = '0) 12am-8am' THEN 1 END) AS count_12am_8am,
            COUNT(CASE WHEN created_on_time_segment = '1) 8am-4pm' THEN 1 END) AS count_8am_4pm,
            COUNT(CASE WHEN created_on_time_segment = '2) 4pm-12am' THEN 1 END) AS count_4pm_12am,
            
            COUNT(*) AS row_total

            FROM (
            SELECT 
                  lead_master_id, 
                  MIN(created_on) AS created_on,
                  MIN(updated_on) AS first_updated_on,
                  
                  -- Response Time
                        CONCAT(
                              FLOOR(TIMESTAMPDIFF(SECOND, MIN(created_on), MIN(updated_on)) / 3600), ':', -- Hours
                              LPAD(FLOOR(MOD(TIMESTAMPDIFF(SECOND, MIN(created_on), MIN(updated_on)), 3600) / 60), 2, '0'), ':', -- Minutes
                              LPAD(MOD(TIMESTAMPDIFF(SECOND, MIN(created_on), MIN(updated_on)), 60), 2, '0') -- Seconds
                        ) AS response_time,
                  
                  -- Response Time Binning
                  CASE
                        WHEN MIN(updated_on) IS NULL THEN '0) MIN(updated_on) is NULL'
                        WHEN TIMESTAMPDIFF(MINUTE, MIN(created_on), MIN(updated_on)) <= 2 THEN '1) 0-2 minutes'
                        WHEN TIMESTAMPDIFF(MINUTE, MIN(created_on), MIN(updated_on)) BETWEEN 3 AND 5 THEN '2) 3-5 minutes'
                        WHEN TIMESTAMPDIFF(MINUTE, MIN(created_on), MIN(updated_on)) BETWEEN 6 AND 10 THEN '3) 6-10 minutes'
                        WHEN TIMESTAMPDIFF(MINUTE, MIN(created_on), MIN(updated_on)) BETWEEN 11 AND 15 THEN '4) 11-15 minutes'
                        ELSE '5) 15+ minutes'
                  END AS response_time_bin,

                  -- Created On Time Segment
                  CASE
                        WHEN TIME(MIN(created_on)) BETWEEN '08:00:00' AND '16:00:00' THEN '1) 8am-4pm'
                        WHEN TIME(MIN(created_on)) BETWEEN '16:00:01' AND '23:59:59' THEN '2) 4pm-12am'
                        ELSE '0) 12am-8am'
                  END AS created_on_time_segment

            FROM leads_master_log
            WHERE 
                  DATE(created_on) = @target_date
                  -- AND updated_on IS NOT NULL
            GROUP BY lead_master_id
      ) AS lead_response_time
      GROUP BY response_time_bin WITH ROLLUP;
-- *******************************************
