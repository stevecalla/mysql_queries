-- Drop the procedure
DROP PROCEDURE IF EXISTS `ezhire_pacing_metrics`.`process_test_sp`;

DELIMITER //

CREATE DEFINER=`root`@`localhost` PROCEDURE `process_test_sp`()
BEGIN
DROP TABLE IF EXISTS demo_data;

CREATE TABLE demo_data (
    event_id TEXT
    ,measured_on DATE
    ,measurement INT
    ,foward_fill INT
);

INSERT INTO demo_data
VALUES
(1,'2021-06-06',NULL,NULL)
,(1,'2021-06-07', 5, NULL)
,(1,'2021-06-08',NULL, NULL)
,(1,'2021-06-09',NULL, NULL)
,(2,'2021-05-22',42, NULL)
,(2,'2021-05-23',42, NULL)
,(2,'2021-05-25',NULL, NULL)
,(2,'2021-05-26',11, NULL)
,(2,'2021-05-27',NULL, NULL)
,(2,'2021-05-27',NULL, NULL)
,(3,'2021-07-01',NULL, NULL)
,(3,'2021-07-03',NULL, NULL);

SELECT * FROM demo_data;

INSERT INTO demo_data
SELECT
    event_id,
    measured_on,
    measurement,
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
FROM demo_data;

SELECT * FROM demo_data;

END//

DELIMITER ;

-- Call the stored procedure
CALL process_test_sp();
