-- https://www.andrewvillazon.com/forward-fill-values-t-sql/

USE ezhire_pacing_metrics;

DROP TABLE IF EXISTS demo_data;

CREATE TABLE demo_data (
    event_id TEXT
    ,measured_on DATE
    ,measurement INT
);

INSERT INTO demo_data
VALUES
-- (1,'2021-06-06',NULL)
-- ,(1,'2021-06-07', 5)
-- ,(1,'2021-06-08',NULL)
-- ,(1,'2021-06-09',NULL)
-- ,(2,'2021-05-22',42)
-- ,(2,'2021-05-23',42)
-- ,(2,'2021-05-25',NULL)
-- ,(2,'2021-05-26',11)
-- ,(2,'2021-05-27',NULL)
-- ,(2,'2021-05-27',NULL)
-- ,(3,'2021-07-01',NULL)
-- ,(3,'2021-07-03',NULL);

('2023-01','2021-06-06',NULL)
,('2023-01','2021-06-07', 5)
,('2023-01','2021-06-08',NULL)
,('2023-01','2021-06-09',NULL)
,(2023-01,'2021-05-22',42)
,(2023-01,'2021-05-23',42)
,(2023-01,'2021-05-25',NULL)
,(2,'2021-05-26',11)
,(2,'2021-05-27',NULL)
,(2,'2021-05-27',NULL)
,(3,'2021-07-01',NULL)
,(3,'2021-07-03',NULL);

SELECT * FROM demo_data;

SELECT
    *,
    CASE
		WHEN measurement IS NULL THEN (
			SELECT inner_table.measurement
			FROM demo_data as inner_table
			WHERE inner_table.event_id = demo_data.event_id
			AND inner_table.measured_on < demo_data.measured_on
			AND inner_table.measurement IS NOT NULL
			ORDER BY inner_table.measured_on DESC
			LIMIT 1)
		ELSE measurement
        END AS forward_fill
FROM demo_data
