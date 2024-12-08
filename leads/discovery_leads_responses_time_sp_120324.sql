USE ezhire_crm;
SELECT VERSION();

SET @target_date = '2024-12-05';

-- #1) 'lead_master table' DETAILS
      SELECT 'lead_master table', COUNT(*) FROM leads_master_log WHERE DATE(created_on) = @target_date;
      SELECT *, 'lead_master table' FROM leads_master_log LIMIT 10;
-- *******************************************

-- #2) 'lead_aswat_Call_Logs' DETAILS
      SELECT 'lead_aswat_Call_Logs', COUNT(*) FROM lead_aswat_Call_Logs WHERE DATE(created_on) = @target_date;
      SELECT *, 'lead_aswat_Call_Logs' FROM lead_aswat_Call_Logs LIMIT 10;
-- *******************************************

-- #3) 'lead_call_time_ranges' DETAILS
      SELECT 'FROM ezhire_crm.lead_call_time_ranges', COUNT(*) FROM lead_call_time_ranges WHERE DATE(created_on) = @target_date;
      SELECT *, 'FROM ezhire_crm.lead_call_time_ranges' FROM lead_call_time_ranges LIMIT 10;
-- *******************************************

-- #4) LEAD RESPONSE - STORED PROCEDURE "SP_get_lead_aswat_call_logs"
      -- CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_get_lead_aswat_call_logs`(
      -- IN P_user_id INT,
      -- IN P_from_date DATE, 
      -- in P_to_date DATE,
      -- IN P_country VARCHAR(200)
      -- )

      SELECT  
            ctlr.startingTime, 
            ctlr.endingTime, 
            ctlr.display_name,

            SUM(CASE WHEN shift='AM Shift 12a-8a' THEN 1 ELSE 0 END) AS 'AM Shift 12a-8a',
            SUM(CASE WHEN shift='Day Shift 8a-4p' THEN 1 ELSE 0 END) AS 'Day Shift 8a-4p',
            SUM(CASE WHEN shift='Night Shift 4p-12a' THEN 1 ELSE 0 END) AS 'Night Shift 4p-12a'
            
            FROM lead_call_time_ranges ctlr

            LEFT JOIN (
                  SELECT

                  CASE 
                        WHEN (CAST(lm.created_on AS TIME) BETWEEN '00:00:00' AND '07:59:59') THEN 'AM Shift 12a-8a' 
                        WHEN (CAST(lm.created_on AS TIME) BETWEEN '08:00:00' AND '15:59:59') THEN 'Day Shift 8a-4p'
                        WHEN (CAST(lm.created_on AS TIME) BETWEEN '16:00:00' AND '23:59:59') THEN 'Night Shift 4p-12a' 
                        END AS shift,
                        
                  CASE 
                        WHEN TIMESTAMPDIFF(MINUTE, MAX(lm.created_on), MIN(acl.Created_On)) > 16 THEN 16
                        ELSE TIMESTAMPDIFF(MINUTE, MAX(lm.created_on), MIN(acl.Created_On))
                  END AS difference

                  FROM leads_master lm
                  INNER JOIN lead_aswat_Call_Logs acl ON acl.Lead_id = lm.lead_id
                  -- LEFT JOIN users u ON u.user_id=acl.user_id
                  -- LEFT JOIN shifts s ON s.id=u.shift

                  WHERE 
                        -- acl.user_id = CASE WHEN P_user_id = 0 THEN acl.user_id ELSE P_user_id END
                        -- AND DATE(lm.created_on) BETWEEN P_from_date AND P_to_date
                        -- AND
                        DATE(lm.created_on) = @target_date

                        -- AND CASE WHEN P_country = '' THEN COALESCE(renting_in_country, '') = COALESCE(renting_in_country, '') ELSE COALESCE(renting_in_country, '') = P_country END

                        and lm.lead_status_id <> 16
                  GROUP BY lm.id
            ) AS tbl ON
                  (
                        CASE 
                              WHEN difference > 16 THEN 16
                              ELSE difference 
                        END >= ctlr.startingTime

                        AND CASE 
                              WHEN difference > 16 THEN 16
                              ELSE difference
                        END <= ctlr.endingTime)

            -- GROUP BY ctlr.startingTime, ctlr.endingTime, 'AM Shift 12a-8a','Night Shift 4p-12a', 'Day Shift 8a-4p';
            GROUP BY ctlr.startingTime, ctlr.endingTime, ctlr.display_name;   
-- *******************************************

-- #5) SAME AS QUERY #2 WITH TOTAL COLUMN & COMMENTS REMOVED
      SELECT  
            lm.lead_id,
            lm.created_on,
            
            -- RESPONSE TIME
            CASE 
                  WHEN response_data.difference IS NOT NULL THEN response_data.difference
                  ELSE NULL
            END AS `Response Time`,

            -- SHIFT BASED ON CREATED TIME
            CASE 
                  WHEN (CAST(lm.created_on AS TIME) BETWEEN '00:00:00' AND '07:59:59') THEN 'AM Shift 12a-8a'
                  WHEN (CAST(lm.created_on AS TIME) BETWEEN '08:00:00' AND '15:59:59') THEN 'Day Shift 8a-4p'
                  WHEN (CAST(lm.created_on AS TIME) BETWEEN '16:00:00' AND '23:59:59') THEN 'Night Shift 4p-12a'
                  ELSE NULL
            END AS `Shift`
      FROM leads_master lm
      LEFT JOIN (
            SELECT 
                  acl.Lead_id,
                  LEAST(16, TIMESTAMPDIFF(MINUTE, MAX(lm.created_on), MIN(acl.Created_On))) AS difference
            FROM leads_master lm
            INNER JOIN lead_aswat_Call_Logs acl ON acl.Lead_id = lm.lead_id
            WHERE 
                  DATE(lm.created_on) = @target_date
                  AND lm.lead_status_id <> 16
            GROUP BY acl.Lead_id
      ) response_data
      ON lm.lead_id = response_data.Lead_id
      WHERE DATE(lm.created_on) = @target_date;

-- *******************************************
