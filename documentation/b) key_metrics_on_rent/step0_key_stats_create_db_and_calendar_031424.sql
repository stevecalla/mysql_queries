-- Drop the database if it exists
DROP DATABASE IF EXISTS ezhire_key_metrics;

-- CREATE RENTAL RECORD TABLE
CREATE DATABASE ezhire_key_metrics;

-- Switch to the newly created database
USE ezhire_key_metrics;

-- ****************** CREATE CALENDAR TABLE START ********************
DROP TABLE IF EXISTS ${table_name};

CREATE TABLE IF NOT EXISTS ${table_name} (
    calendar_date DATE NOT NULL,
    year                SMALLINT UNSIGNED NOT NULL,
    quarter             TINYINT  UNSIGNED NOT NULL,
    month               TINYINT  UNSIGNED NOT NULL,
    week_of_year        TINYINT  UNSIGNED NOT NULL,
    day_of_year         SMALLINT UNSIGNED NOT NULL,
    day_of_week         VARCHAR(9) NOT NULL,
    day_of_week_numeric TINYINT  UNSIGNED NOT NULL,
    PRIMARY KEY (calendar_date)
) ENGINE=InnoDB
    DEFAULT CHARSET=utf8mb4
    COLLATE=utf8mb4_0900_ai_ci;

SHOW INDEXES FROM calendar_table;

-- Insert data for the years 2015 and the last day of the current year
INSERT INTO calendar_table (
  calendar_date, year, quarter, month, week_of_year, day_of_year, day_of_week, day_of_week_numeric
)
    SELECT
        date_seq,
        YEAR(date_seq),
        QUARTER(date_seq),
        MONTH(date_seq),
        WEEK(date_seq),          -- consider WEEK(date_seq, 3) for ISO
        DAYOFYEAR(date_seq),
        DAYNAME(date_seq),
        DAYOFWEEK(date_seq)
        FROM (
            SELECT DATE_ADD('2015-01-01', INTERVAL seq DAY) AS date_seq
            FROM (
                SELECT (t4*1000 + t3*100 + t2*10 + t1) - 1 AS seq
                FROM
                (SELECT 0 AS t1 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t1,
                (SELECT 0 AS t2 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t2,
                (SELECT 0 AS t3 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t3,
                (SELECT 0 AS t4 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t4
            ) d
        WHERE DATE_ADD('2015-01-01', INTERVAL seq DAY)
                BETWEEN '2015-01-01' AND DATE_ADD(CURDATE(), INTERVAL 1 YEAR)
        ) AS calendar_data
;

-- Select all records with a limit of 10
SELECT * FROM calendar_table ORDER BY calendar_date DESC LIMIT 10;
SELECT FORMAT(COUNT(*), 0) FROM calendar_table;

-- run it
--  mysql -uroot -p < "/home/steve-calla/development/ezhire/mysql_queries/documentation/b) key_metrics_on_rent/step0_key_stats_create_db_and_calendar_031424.sql"

--  mysql -uroot -pdenverdenver -e "SHOW DATABASES;"