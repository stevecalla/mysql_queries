-- Drop the database if it exists
DROP DATABASE IF EXISTS rental_dates;

-- CREATE RENTAL RECORD TABLE
CREATE DATABASE rental_dates;

-- Switch to the newly created database
USE rental_dates;

-- Create the table
CREATE TABLE
    rental_table (
        id INT PRIMARY KEY AUTO_INCREMENT,
        -- LOCATION & VEHICLE TYPE
        vehicle_type VARCHAR(20), -- New field for vehicle type
        location VARCHAR(20), -- New field for location
        -- DATE FIELDS
        start_date DATE,
        end_date DATE,
        start_datetime DATETIME AS (
            CONVERT(CONCAT (start_date, ' ', start_time), DATETIME)
        ),
        start_time TIME,
        end_time TIME,
        end_datetime DATETIME AS (
            CONVERT(CONCAT (end_date, ' ', end_time), DATETIME)
        ),
        -- days_rented INT AS (DATEDIFF(end_date, start_date)) STORED,
        -- days_rented DECIMAL(10, 4) AS ( TIMESTAMPDIFF(MINUTE, start_date, end_date) / (24 * 60)) STORED,
        days_rented DECIMAL(10, 4) AS (
            TIMESTAMPDIFF (MINUTE, start_datetime, end_datetime) / (24 * 60)
        ) STORED,
        total_minutes_in_day INT DEFAULT (24 * 60),
        -- START MINUTE FRACTION CALC
        start_hours_to_midnight INT AS (HOUR (TIMEDIFF ('24:00:00', start_time))) VIRTUAL,
        start_minutes_to_midnight INT AS (MINUTE (TIMEDIFF ('24:00:00', start_time))) VIRTUAL,
        start_total_minutes_to_midnight INT AS (
            start_hours_to_midnight * 60 + start_minutes_to_midnight
        ) VIRTUAL,
        start_fraction_of_day DECIMAL(5, 4) AS (
            start_total_minutes_to_midnight / total_minutes_in_day
        ) STORED,
        -- END MINUTE FRACTION CALC
        end_hours_to_midnight INT AS (HOUR (TIMEDIFF ('24:00:00', end_time))) VIRTUAL,
        end_minutes_to_midnight INT AS (MINUTE (TIMEDIFF ('24:00:00', end_time))) VIRTUAL,
        end_total_minutes_to_midnight INT AS (
            end_hours_to_midnight * 60 + end_minutes_to_midnight
        ) VIRTUAL,
        end_fraction_of_day DECIMAL(5, 4) AS (
            end_total_minutes_to_midnight / total_minutes_in_day
        ) STORED
    );

-- LOAD DATA LOCAL INFILE '/path/to/your/file.csv'
-- LOAD DATA LOCAL INFILE '/Users/stevecalla/du_coding/sql_queries/on-rent-calc/on-rent-data.csv'
-- LOAD DATA LOCAL INFILE 'C:/Users/calla/Google Drive/Resume & Stuff/ezhire/sql_analysis/on-rent-data.csv'
LOAD DATA LOCAL INFILE ' C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/on-rent-data.csv' INTO TABLE rental_table FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES (
    start_date,
    end_date,
    start_time,
    end_time,
    vehicle_type,
    location
);

-- Insert sample data into the table
INSERT INTO
    rental_table (
        start_date,
        end_date,
        start_time,
        end_time,
        vehicle_type,
        location
    )
VALUES
    (
        '2024-01-01',
        '2024-01-10',
        '08:00:00',
        '17:00:00',
        'vehicle_1',
        'location_a'
    ),
    (
        '2024-01-04',
        '2024-01-06',
        '08:00:00',
        '17:00:00',
        'vehicle_2',
        'location_b'
    ),
    (
        '2024-02-19',
        '2024-02-28',
        '17:30:00',
        '12:45:00',
        'vehicle_1',
        'location_a'
    ),
    (
        '2024-02-15',
        '2024-02-20',
        '17:30:00',
        '12:45:00',
        'vehicle_2',
        'location_b'
    );

-- Select all records with a limit of 10
SELECT
    *
FROM
    rental_table
LIMIT
    10;

-- ******************************************************
-- Drop the database if it exists
DROP DATABASE IF EXISTS calendar_table;

-- Create the calendar_table
CREATE TABLE
    calendar_table (
        calendar_date DATE PRIMARY KEY,
        day_of_week VARCHAR(9),
        day_of_week_numeric INT,
        week_of_year INT,
        day_of_year INT
    );

-- Insert data for the years 2023 and 2024
INSERT INTO
    calendar_table (
        calendar_date,
        day_of_week,
        day_of_week_numeric,
        week_of_year,
        day_of_year
    )
SELECT
    date_seq,
    DAYNAME (date_seq),
    DAYOFWEEK (date_seq),
    WEEK (date_seq, 1),
    DAYOFYEAR (date_seq)
FROM
    (
        SELECT
            DATE_ADD ('2023-01-01', INTERVAL seq DAY) AS date_seq
        FROM
            (
                SELECT
                    (t4 * 1000 + t3 * 100 + t2 * 10 + t1) - 1 AS seq
                FROM
                    (
                        SELECT
                            0 AS t1
                        UNION
                        SELECT
                            1
                        UNION
                        SELECT
                            2
                        UNION
                        SELECT
                            3
                        UNION
                        SELECT
                            4
                        UNION
                        SELECT
                            5
                        UNION
                        SELECT
                            6
                        UNION
                        SELECT
                            7
                        UNION
                        SELECT
                            8
                        UNION
                        SELECT
                            9
                    ) t1,
                    (
                        SELECT
                            0 AS t2
                        UNION
                        SELECT
                            1
                        UNION
                        SELECT
                            2
                        UNION
                        SELECT
                            3
                        UNION
                        SELECT
                            4
                        UNION
                        SELECT
                            5
                        UNION
                        SELECT
                            6
                        UNION
                        SELECT
                            7
                        UNION
                        SELECT
                            8
                        UNION
                        SELECT
                            9
                    ) t2,
                    (
                        SELECT
                            0 AS t3
                        UNION
                        SELECT
                            1
                        UNION
                        SELECT
                            2
                        UNION
                        SELECT
                            3
                        UNION
                        SELECT
                            4
                        UNION
                        SELECT
                            5
                        UNION
                        SELECT
                            6
                        UNION
                        SELECT
                            7
                        UNION
                        SELECT
                            8
                        UNION
                        SELECT
                            9
                    ) t3,
                    (
                        SELECT
                            0 AS t4
                        UNION
                        SELECT
                            1
                        UNION
                        SELECT
                            2
                        UNION
                        SELECT
                            3
                    ) t4
            ) AS seq_table
        WHERE
            DATE_ADD ('2023-01-01', INTERVAL seq DAY) BETWEEN '2023-01-01' AND '2024-12-31'
    ) AS calendar_data;

-- Select all records with a limit of 10
SELECT
    *
FROM
    calendar_table
LIMIT
    10;

-- ******************************************************
-- CALCULATE TOTAL ON-RENT BY CALENDAR DATE
-- Assuming rental_table and calendar_table already exist
-- Create a query that combines the tables and increments the rental count for each overlapping date
SELECT
    ct.calendar_date,
    SUM(
        CASE
            WHEN ct.calendar_date = rt.start_date THEN rt.start_fraction_of_day
            WHEN ct.calendar_date = rt.end_date THEN rt.end_fraction_of_day
            ELSE 1
        END
    ) AS days_on_rent_fraction,
    COUNT(rt.id) AS days_on_rent_whole_day
FROM
    calendar_table ct
    INNER JOIN -- only shows dates in calendar table with results
    -- LEFT JOIN -- shows all dates in the calendar table. dates with no results show 0
    rental_table rt ON ct.calendar_date BETWEEN rt.start_date AND rt.end_date
GROUP BY
    ct.calendar_date;

-- LIMIT 10;
-- Insert sample data into the table
INSERT INTO
    rental_table (
        start_date,
        end_date,
        start_time,
        end_time,
        vehicle_type,
        location
    )
VALUES
    (
        '2024-01-04',
        '2024-01-06',
        '08:00:00',
        '17:00:00',
        'vehicle_1',
        'location_b'
    ),
    (
        '2024-02-15',
        '2024-02-20',
        '17:30:00',
        '12:45:00',
        'vehicle_1',
        'location_b'
    );

-- Select all records with a limit of 10
SELECT
    *
FROM
    rental_table
LIMIT
    10;

-- ******************************************************
-- CALCULATE ON-RENT BY VEHICLE TYPE AND CALENDAR DATE
-- Assuming rental_table and calendar_table already exist
-- Create a query that combines the tables and increments the rental count for each overlapping date with specific vehicle types
SELECT
    ct.calendar_date AS calendar_date,
    rt.vehicle_type AS vehicle_type,
    SUM(
        CASE
            WHEN ct.calendar_date = rt.start_date
            AND rt.vehicle_type = vehicle_type THEN rt.start_fraction_of_day
            WHEN ct.calendar_date = rt.end_date
            AND rt.vehicle_type = vehicle_type THEN rt.end_fraction_of_day
            WHEN ct.calendar_date > rt.start_date
            AND rt.vehicle_type = vehicle_type THEN 1
            ELSE 0
        END
    ) AS days_on_rent_fraction,
    COUNT(rt.id) AS days_on_rent_whole_day
FROM
    calendar_table ct
    INNER JOIN rental_table rt ON ct.calendar_date BETWEEN rt.start_date AND rt.end_date
GROUP BY
    rt.vehicle_type,
    ct.calendar_date
ORDER BY
    vehicle_type,
    calendar_date;

-- Select all records with a limit of 10
SELECT
    *
FROM
    rental_table
LIMIT
    10;

-- ******************************************************
-- CALCULATE ON-RENT BY VEHICLE TYPE AND CALENDAR DATE PIVOTED BY VEHICLE TYPE
-- Assuming rental_table and calendar_table already exist
-- Create a query that combines the tables and increments the rental count for each overlapping date with specific vehicle types
SELECT
    ct.calendar_date AS calendar_date,
    -- rt.vehicle_type AS vehicle_type,
    SUM(
        CASE
            WHEN ct.calendar_date = rt.start_date
            AND rt.vehicle_type = "vehicle_1" THEN rt.start_fraction_of_day
            WHEN ct.calendar_date = rt.end_date
            AND rt.vehicle_type = "vehicle_1" THEN rt.end_fraction_of_day
            WHEN ct.calendar_date > rt.start_date
            AND rt.vehicle_type = "vehicle_1" THEN 1
            ELSE 0
        END
    ) AS vehicle_1_days_on_rent_fraction,
    SUM(
        CASE
            WHEN ct.calendar_date = rt.start_date
            AND rt.vehicle_type = "vehicle_2" THEN rt.start_fraction_of_day
            WHEN ct.calendar_date = rt.end_date
            AND rt.vehicle_type = "vehicle_2" THEN rt.end_fraction_of_day
            WHEN ct.calendar_date > rt.start_date
            AND rt.vehicle_type = "vehicle_2" THEN 1
            ELSE 0
        END
    ) AS vehicle_2_days_on_rent_fraction,
    SUM(
        CASE
            WHEN ct.calendar_date = rt.start_date
            AND (
                rt.vehicle_type = "vehicle_1"
                OR rt.vehicle_type = "vehicle_2"
            ) THEN rt.start_fraction_of_day
            WHEN ct.calendar_date = rt.end_date
            AND (
                rt.vehicle_type = "vehicle_1"
                OR rt.vehicle_type = "vehicle_2"
            ) THEN rt.end_fraction_of_day
            WHEN ct.calendar_date > rt.start_date
            AND (
                rt.vehicle_type = "vehicle_1"
                OR rt.vehicle_type = "vehicle_2"
            ) THEN 1
            ELSE 0
        END
    ) AS total_on_rent_days
FROM
    calendar_table ct
    INNER JOIN rental_table rt ON ct.calendar_date BETWEEN rt.start_date AND rt.end_date
GROUP BY
    -- rt.vehicle_type, ct.calendar_date
    ct.calendar_date
ORDER BY
    -- vehicle_type, calendar_date;
    calendar_date;

-- ******************************************************
-- ADD SUBQUERY TO CALCULATE THE TOTAL ON RENT DAYS
-- EXPLAIN SELECT
SELECT
    subquery.calendar_date,
    subquery.vehicle_1_days_on_rent_fraction,
    subquery.vehicle_2_days_on_rent_fraction,
    (
        subquery.vehicle_1_days_on_rent_fraction + subquery.vehicle_2_days_on_rent_fraction
    ) AS total_on_rent_days
FROM
    (
        SELECT
            ct.calendar_date,
            SUM(
                CASE
                    WHEN ct.calendar_date = rt.start_date
                    AND rt.vehicle_type = "vehicle_1" THEN rt.start_fraction_of_day
                    WHEN ct.calendar_date = rt.end_date
                    AND rt.vehicle_type = "vehicle_1" THEN rt.end_fraction_of_day
                    WHEN ct.calendar_date > rt.start_date
                    AND rt.vehicle_type = "vehicle_1" THEN 1
                    ELSE 0
                END
            ) AS vehicle_1_days_on_rent_fraction,
            SUM(
                CASE
                    WHEN ct.calendar_date = rt.start_date
                    AND rt.vehicle_type = "vehicle_2" THEN rt.start_fraction_of_day
                    WHEN ct.calendar_date = rt.end_date
                    AND rt.vehicle_type = "vehicle_2" THEN rt.end_fraction_of_day
                    WHEN ct.calendar_date > rt.start_date
                    AND rt.vehicle_type = "vehicle_2" THEN 1
                    ELSE 0
                END
            ) AS vehicle_2_days_on_rent_fraction
        FROM
            calendar_table ct
            INNER JOIN rental_table rt ON ct.calendar_date BETWEEN rt.start_date AND rt.end_date
        GROUP BY
            ct.calendar_date
    ) AS subquery
ORDER BY
    calendar_date;