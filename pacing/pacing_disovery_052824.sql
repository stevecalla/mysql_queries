USE ezhire_pacing_metrics;
-- Select all records with a limit of 10
SELECT * FROM pacing_base;
-- NOTICED THAT EXTENSION CHARGE FIGURES ARE NEGATIVE ON CERTAIN DAYS?
SELECT * FROM pacing_base WHERE booking_date = '2023-04-11';
SELECT  booking_date, FORMAT(SUM(extension_charge_aed), 0) FROM pacing_base WHERE booking_date = '2023-04-11' GROUP BY booking_date;

SELECT * FROM pacing_base WHERE booking_date = '2023-03-22';
SELECT  booking_date, FORMAT(SUM(extension_charge_aed), 0) FROM pacing_base WHERE booking_date = '2023-03-22' GROUP BY booking_date;

USE ezhire_booking_data;
SELECT * FROM booking_data LIMIT 10;
SELECT * FROM booking_data WHERE booking_id IN ('182520', '182582');
