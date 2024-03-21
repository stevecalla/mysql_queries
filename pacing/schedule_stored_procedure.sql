-- Check the status of the Event Scheduler
-- SHOW VARIABLES LIKE 'event_scheduler';

-- Enable the Event Scheduler if it's not already enabled
-- SET GLOBAL event_scheduler = ON;

-- -- Drop a scheduled event
DROP EVENT IF EXISTS my_event;

-- Create a scheduled event
CREATE EVENT IF NOT EXISTS my_event
-- ON SCHEDULE AT CURRENT_TIMESTAMP + INTERVAL 1 MINUTE
-- ON SCHEDULE EVERY 1 DAY
-- STARTS CURRENT_TIMESTAMP
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP + INTERVAL 1 MINUTE
-- STARTS CURRENT_TIMESTAMP + INTERVAL 30 SECONDS
COMMENT 'Scheduled event to run a procedure daily'
DO
	CALL process_pickup_month_data_join();
    -- CALL process_test_sp();

SHOW EVENTS;

-- Modify a scheduled event
-- ALTER EVENT my_event
-- COMMENT 'Updated description of the event';

-- -- Drop a scheduled event
DROP EVENT IF EXISTS my_event;

SHOW EVENTS

-- SHOW PROCESSLIST;

