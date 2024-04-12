-- https://www.sqlshack.com/learn-mysql-the-basics-of-mysql-stored-procedures/
-- https://www.mysqltutorial.org/mysql-stored-procedure/getting-started-with-mysql-stored-procedures/

USE ezhire_pacing_metrics;

-- Drop the procedure
DROP PROCEDURE `ezhire_pacing_metrics`.`process_pickup_month_data_join`;

DELIMITER //


CREATE DEFINER=`root`@`localhost` PROCEDURE `process_pickup_month_data_join`()
BEGIN

    DECLARE pickup_month_year_val VARCHAR(10);
    DECLARE loop_count INT DEFAULT 0;  -- Variable to count loops
    DECLARE done INT DEFAULT 0;

    -- ******* STEP #1: START - GET DISTINCT MONTH YEAR COMBINATIONS TO USE IN LOOP BELOW ************
    DECLARE cur_pickup_month CURSOR FOR
        -- SELECT DISTINCT pickup_month_year FROM pacing_base_groupby WHERE pickup_month_year LIKE '2023-01%' ORDER BY pickup_month_year;
        -- SELECT DISTINCT pickup_month_year FROM pacing_base_groupby WHERE pickup_month_year LIKE '2023-%' ORDER BY pickup_month_year;
        SELECT DISTINCT pickup_month_year FROM pacing_base_groupby ORDER BY pickup_month_year;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    -- ******* STEP #1: END **************************************************************

    -- Progress and debug log
    CREATE TABLE IF NOT EXISTS debug_log (
        id INT AUTO_INCREMENT PRIMARY KEY,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        log_message TEXT
    );

    INSERT INTO debug_log (log_message) VALUES ('Starting execution of procedure');

    -- ******* STEP #2: START - CREATE TABLE TO CONTAIN PACING RESULTS WITH ALL DATES ************
    -- Drop the pacing_base_all_calendar_dates table if it exists
    DROP TABLE IF EXISTS pacing_base_all_calendar_dates;

    -- Create the pacing_base_all_calendar_dates table
    CREATE TABLE IF NOT EXISTS pacing_base_all_calendar_dates (
        grouping_id INT,
        max_booking_datetime DATETIME, -- ADDED

        -- CALC IS_BEFORE_TODAY
        is_before_today VARCHAR(3), -- ADDED

        pickup_month_year VARCHAR(10),
        first_day_of_month VARCHAR(10),
        last_day_of_month DATE,
        booking_date DATE,
        days_from_first_day_of_month BIGINT,

        count INT,
        total_booking_charge_aed DECIMAL(20, 2),
        total_booking_charge_less_discount_aed DECIMAL(20, 2),
        total_booking_charge_less_discount_extension_aed DECIMAL(20, 2),
        total_extension_charge_aed DECIMAL(20, 2),

        running_total_booking_count BIGINT,
        running_total_booking_charge_aed DECIMAL(20, 2),
        running_total_booking_charge_less_discount_aed DECIMAL(20, 2),
        running_total_booking_charge_less_discount_extension_aed DECIMAL(20, 2),
        running_total_extension_charge_aed DECIMAL(20, 2)
    );
    -- ******* STEP #2: END **************************************************************

    -- ******* STEP #3: START - LOOP THRU EACH YEAR MONTH COMBINATION; CREATE TEMP TABLE WITH MISSING CALENDAR DATES THEN INSERT TEMP TABLE INFO INTO CONSOLIDATED TABLE WITH ALL MONTH YEAR COMBINATIONS CALLED pacing_base_all_calendar_dates TABLE  ************
    OPEN cur_pickup_month;
    read_loop: LOOP
        FETCH cur_pickup_month INTO pickup_month_year_val;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
		-- Increment loop count
        SET loop_count = loop_count + 1;

        -- -- Insert data into pacing_base_all_calendar_dates table
        -- INSERT INTO pacing_base_all_calendar_dates
        --     SELECT
        --         loop_count AS grouping_id,
        --         pbg.pickup_month_year,
        --          pbg.max_booking_datetime, -- ADDED

        --          -- CALC IS_BEFORE_TODAY
        --          CASE
        --              WHEN days_from_first_day_of_month IS NULL THEN NULL
        --              WHEN days_from_first_day_of_month <= DATE_FORMAT(max_booking_datetime, '%d') + 2 THEN "yes"
        --              ELSE "no"
        --          END AS is_before_today, -- ADDED

        --         CONCAT(pickup_month_year, '-01') AS first_day_of_month,
        --         LAST_DAY(CONCAT(pickup_month_year, '-01')) AS last_day_of_month,
                
        --         c.calendar_date AS booking_date,
        --         pbg.days_from_first_day_of_month,

        --         pbg.count AS count,
            
                    -- REPLACE(pbg.total_booking_charge_aed, ',', '') AS total_booking_charge_aed,
                    -- REPLACE(pbg.total_booking_charge_less_discount_aed, ',', '') AS  total_booking_charge_less_discount_aed,
                    -- REPLACE(pbg.running_total_booking_count, ',', '') AS running_total_booking_count,
                    -- REPLACE(pbg.running_total_booking_charge_aed, ',', '') AS running_total_booking_charge_aed,
                    -- REPLACE(pbg.running_total_booking_charge_less_discount_aed, ',', '') AS running_total_booking_charge_less_discount_aed

        --     FROM calendar_table AS c

        --     LEFT JOIN pacing_base_groupby AS pbg ON c.calendar_date = pbg.booking_date 
        --     AND pbg.pickup_month_year = pickup_month_year_val

        --     WHERE c.calendar_date > @calendar_start_date
        --     AND c.calendar_date <= (SELECT MAX(booking_date) FROM pacing_base_groupby WHERE pickup_month_year = pickup_month_year_val)
        --     AND c.calendar_date >= (SELECT MIN(booking_date) FROM pacing_base_groupby WHERE pickup_month_year = pickup_month_year_val)

        --     ORDER BY c.calendar_date ASC, pbg.days_from_first_day_of_month ASC;

        -- -- Pause for 2 second
        -- SELECT SLEEP(2);    

        -- INSERT INTO pacing_base_all_calendar_dates
        -- VALUES
        --     (loop_count,'2023-01','2023-01-01','2023-01-31','2022-11-08',-54,1,111.00,222.00,1,333.00,444.00);

        -- *************
        DROP TABLE IF EXISTS temp;

        CREATE TABLE temp AS
            SELECT
                loop_count AS grouping_id,
                pbg.max_booking_datetime, -- ADDED

                -- CALC IS_BEFORE_TODAY
                CASE
                    WHEN days_from_first_day_of_month IS NULL THEN NULL
                    WHEN days_from_first_day_of_month <= DATE_FORMAT(max_booking_datetime, '%d') + 2 THEN "yes"
                    ELSE "no"
                END AS is_before_today, -- ADDED

                pbg.pickup_month_year,
                CONCAT(pickup_month_year, '-01') AS first_day_of_month,
                LAST_DAY(CONCAT(pickup_month_year, '-01')) AS last_day_of_month,
                
                c.calendar_date AS booking_date,
                pbg.days_from_first_day_of_month,

                pbg.count AS count,
                REPLACE(pbg.total_booking_charge_aed, ',', '') AS total_booking_charge_aed,
                REPLACE(pbg.total_booking_charge_less_discount_aed, ',', '') AS  total_booking_charge_less_discount_aed,
                REPLACE(pbg.total_booking_charge_less_discount_extension_aed, ',', '') AS  total_booking_charge_less_discount_extension_aed,
                REPLACE(pbg.total_extension_charge_aed, ',', '') AS  total_extension_charge_aed,

                REPLACE(pbg.running_total_booking_count, ',', '') AS running_total_booking_count,
                REPLACE(pbg.running_total_booking_charge_aed, ',', '') AS running_total_booking_charge_aed,
                REPLACE(pbg.running_total_booking_charge_less_discount_aed, ',', '') AS running_total_booking_charge_less_discount_aed,
                REPLACE(pbg.running_total_booking_charge_less_discount_extension_aed, ',', '') AS running_total_booking_charge_less_discount_extension_aed,
                REPLACE(pbg.running_total_extension_charge_aed, ',', '') AS running_total_extension_charge_aed

            FROM calendar_table AS c

            LEFT JOIN pacing_base_groupby AS pbg ON c.calendar_date = pbg.booking_date 
            AND pbg.pickup_month_year = pickup_month_year_val

            WHERE c.calendar_date > '2022-01-01'
            AND c.calendar_date <= (SELECT MAX(booking_date) FROM pacing_base_groupby WHERE pickup_month_year = pickup_month_year_val)
            AND c.calendar_date >= (SELECT MIN(booking_date) FROM pacing_base_groupby WHERE pickup_month_year = pickup_month_year_val)

            ORDER BY grouping_id, c.calendar_date ASC, pbg.days_from_first_day_of_month ASC;

        -- Pause for 1 second
        -- SELECT SLEEP(1);

        -- Insert data from the temporary table into the main table
        INSERT INTO pacing_base_all_calendar_dates
            SELECT * FROM temp;

        -- OUTPUT RESULTS
	    -- SELECT * FROM ezhire_pacing_metrics.pacing_base_all_calendar_dates WHERE pickup_month_year = pickup_month_year_val;
	    SELECT * FROM ezhire_pacing_metrics.pacing_base_all_calendar_dates WHERE grouping_id = loop_count;
    
        -- Progress log
        INSERT INTO debug_log (log_message) VALUES (CONCAT('Processed pickup_month_year: ', pickup_month_year_val));

    END LOOP;

    -- Add the created_at column after the loop
    ALTER TABLE pacing_base_all_calendar_dates ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    
    CLOSE cur_pickup_month;

	SELECT * FROM ezhire_pacing_metrics.pacing_base_all_calendar_dates;
    -- ******* STEP #3: END **************************************************************

    -- ******* STEP #4: START - REPLACE NULL VALUES WITH MOST RECENT PRIOR POPULATED ROW ************
    -- **************************************** --
    DROP TABLE IF EXISTS pacing_final_data;

    CREATE TABLE pacing_final_data AS
    SELECT
        CASE
            WHEN max_booking_datetime IS NULL THEN (
                SELECT inner_table.max_booking_datetime
                FROM pacing_base_all_calendar_dates AS inner_table
                WHERE inner_table.grouping_id = pacing_base_all_calendar_dates.grouping_id
                AND inner_table.booking_date < pacing_base_all_calendar_dates.booking_date
                AND inner_table.max_booking_datetime IS NOT NULL
                ORDER BY inner_table.booking_date DESC
                LIMIT 1)
            ELSE max_booking_datetime
        END AS max_booking_datetime, -- ADDED

        CASE
            WHEN is_before_today IS NULL THEN (
                SELECT inner_table.is_before_today
                FROM pacing_base_all_calendar_dates AS inner_table
                WHERE inner_table.grouping_id = pacing_base_all_calendar_dates.grouping_id
                AND inner_table.booking_date < pacing_base_all_calendar_dates.booking_date
                AND inner_table.is_before_today IS NOT NULL
                ORDER BY inner_table.booking_date DESC
                LIMIT 1)
            ELSE is_before_today
        END AS is_before_today, -- ADDED

        CASE
            WHEN pickup_month_year IS NULL THEN (
                SELECT inner_table.pickup_month_year
                FROM pacing_base_all_calendar_dates AS inner_table
                WHERE inner_table.grouping_id = pacing_base_all_calendar_dates.grouping_id
                AND inner_table.booking_date < pacing_base_all_calendar_dates.booking_date
                AND inner_table.pickup_month_year IS NOT NULL
                ORDER BY inner_table.booking_date DESC
                LIMIT 1)
            ELSE pickup_month_year
        END AS pickup_month_year,

        booking_date, -- populated for all rows
        
        -- days_from_first_day_of_month
        CASE
            WHEN first_day_of_month IS NULL THEN (
                SELECT DATEDIFF(pacing_base_all_calendar_dates.booking_date, STR_TO_DATE(inner_table.first_day_of_month  , '%Y-%m-%d'))
                FROM pacing_base_all_calendar_dates AS inner_table
                WHERE inner_table.grouping_id = pacing_base_all_calendar_dates.grouping_id
                AND inner_table.booking_date < pacing_base_all_calendar_dates.booking_date
                AND inner_table.first_day_of_month IS NOT NULL
                ORDER BY inner_table.booking_date DESC
                LIMIT 1)
            ELSE days_from_first_day_of_month
        END AS days_from_first_day_of_month,
        
        COALESCE(count, 0) AS count,
        COALESCE(total_booking_charge_aed, 0) AS total_booking_charge_aed,
        COALESCE(total_booking_charge_less_discount_aed, 0) AS total_booking_charge_less_discount_aed,
        COALESCE(total_booking_charge_less_discount_extension_aed, 0) AS total_booking_charge_less_discount_extension_aed,
        COALESCE(total_extension_charge_aed, 0) AS total_extension_charge_aed,
        
        -- running_count
        CASE
            WHEN running_total_booking_count IS NULL THEN (
                SELECT inner_table.running_total_booking_count
                FROM pacing_base_all_calendar_dates AS inner_table
                WHERE inner_table.grouping_id = pacing_base_all_calendar_dates.grouping_id
                AND inner_table.booking_date < pacing_base_all_calendar_dates.booking_date
                AND inner_table.running_total_booking_count IS NOT NULL
                ORDER BY inner_table.booking_date DESC
                LIMIT 1)
            ELSE running_total_booking_count
        END AS running_count,
        
        -- running_total_booking_charge_aed
        CASE
            WHEN running_total_booking_charge_aed IS NULL THEN (
                SELECT inner_table.running_total_booking_charge_aed
                FROM pacing_base_all_calendar_dates AS inner_table
                WHERE inner_table.grouping_id = pacing_base_all_calendar_dates.grouping_id
                AND inner_table.booking_date < pacing_base_all_calendar_dates.booking_date
                AND inner_table.running_total_booking_charge_aed IS NOT NULL
                ORDER BY inner_table.booking_date DESC
                LIMIT 1)
            ELSE running_total_booking_charge_aed
        END AS running_total_booking_charge_aed,
        
        -- running_total_booking_charge_less_discount_aed
        CASE
            WHEN running_total_booking_charge_less_discount_aed IS NULL THEN (
                SELECT inner_table.running_total_booking_charge_less_discount_aed
                FROM pacing_base_all_calendar_dates AS inner_table
                WHERE inner_table.grouping_id = pacing_base_all_calendar_dates.grouping_id
                AND inner_table.booking_date < pacing_base_all_calendar_dates.booking_date
                AND inner_table.running_total_booking_charge_less_discount_aed IS NOT NULL
                ORDER BY inner_table.booking_date DESC
                LIMIT 1)
            ELSE running_total_booking_charge_less_discount_aed
        END AS running_total_booking_charge_less_discount_aed,
        
        -- running_total_booking_charge_less_discount_extension_aed
        CASE
            WHEN running_total_booking_charge_less_discount_extension_aed IS NULL THEN (
                SELECT inner_table.running_total_booking_charge_less_discount_extension_aed
                FROM pacing_base_all_calendar_dates AS inner_table
                WHERE inner_table.grouping_id = pacing_base_all_calendar_dates.grouping_id
                AND inner_table.booking_date < pacing_base_all_calendar_dates.booking_date
                AND inner_table.running_total_booking_charge_less_discount_extension_aed IS NOT NULL
                ORDER BY inner_table.booking_date DESC
                LIMIT 1)
            ELSE running_total_booking_charge_less_discount_extension_aed
        END AS running_total_booking_charge_less_discount_extension_aed,
        
        -- running_total_extension_charge_aed
        CASE
            WHEN running_total_extension_charge_aed IS NULL THEN (
                SELECT inner_table.running_total_extension_charge_aed
                FROM pacing_base_all_calendar_dates AS inner_table
                WHERE inner_table.grouping_id = pacing_base_all_calendar_dates.grouping_id
                AND inner_table.booking_date < pacing_base_all_calendar_dates.booking_date
                AND inner_table.running_total_extension_charge_aed IS NOT NULL
                ORDER BY inner_table.booking_date DESC
                LIMIT 1)
            ELSE running_total_extension_charge_aed
        END AS running_total_extension_charge_aed
            
    FROM pacing_base_all_calendar_dates;
    
    -- Add the created_at column after the loop
    ALTER TABLE pacing_final_data ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    -- ******* STEP #4: END **************************************************************

    SELECT * FROM pacing_final_data;

    -- Progress log
    INSERT INTO debug_log (log_message) VALUES ('Created pacing_final_data table');

END//

DELIMITER ;

-- Call the stored procedure
CALL process_pickup_month_data_join();