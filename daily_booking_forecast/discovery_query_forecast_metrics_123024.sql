USE ezhire_forecast_data;

-- C:\Users\calla\development\ezhire\mysql_queries\daily_booking_forecast\discovery_query_forecast_metrics_123024.sql

SELECT * FROM booking_by_hour_data;

-- DROP TABLE IF EXISTS forecast_summary_metrics_data;

CREATE TABLE IF NOT EXISTS forecast_summary_metrics_data (
  today_date_gst DATE,
  today_current_day_of_week_gst INT,
  today_current_hour_gst INT,
  segment_major VARCHAR(50),
  segment_minor VARCHAR(50),
  booking_date DATE,
  booking_date_day_of_week INT,
  booking_total_prior_to_current_hour INT,
  booking_total INT,
  created_at_gst TIMESTAMP,
  UNIQUE KEY unique_summary_metrics (
    today_date_gst, 
    today_current_hour_gst,
    segment_major,
    segment_minor,
    booking_date
  )
);

INSERT IGNORE INTO forecast_summary_metrics_data  (
  today_date_gst,
  today_current_day_of_week_gst,
  today_current_hour_gst,
  segment_major,
  segment_minor,
  booking_date,
  booking_date_day_of_week,
  booking_total_prior_to_current_hour,
  booking_total,
  created_at_gst
)
SELECT  
	today_date_gst,
    today_current_day_of_week_gst,
    today_current_hour_gst,
    segment_major,
    segment_minor, 
    booking_date,
    booking_date_day_of_week,
    SUM(CASE WHEN booking_time_bucket_flag IN ("yes") THEN hourly_bookings ELSE 0 END) booking_total_prior_to_current_hour,
    SUM(hourly_bookings) AS booking_total,
    MIN(created_at_gst)
FROM booking_by_hour_data
-- WHERE segment_minor NOT IN ('actual_last_7_days', 'actuals_same_day_last_4_weeks')
GROUP BY today_date_gst, today_current_day_of_week_gst, today_current_hour_gst, segment_major, segment_minor, booking_date, booking_date_day_of_week
ORDER BY today_date_gst, today_current_day_of_week_gst, today_current_hour_gst, segment_major, segment_minor
;

SELECT * FROM forecast_summary_metrics_data;

-- SLACK SUMMARY QUERY
SELECT  
	today_date_gst,
	today_current_day_of_week_gst,
	today_current_hour_gst,
	segment_major,
	segment_minor, 
	SUM(CASE WHEN booking_time_bucket_flag IN ("yes") THEN hourly_bookings ELSE 0 END) booking_total_prior_to_current_hour,
	SUM(hourly_bookings) AS booking_total,
	MIN(created_at_gst)
FROM booking_by_hour_data
WHERE segment_minor NOT IN ('actual_last_7_days', 'actuals_same_day_last_4_weeks')
GROUP BY today_date_gst, today_current_day_of_week_gst, today_current_hour_gst, segment_major, segment_minor
ORDER BY today_date_gst, today_current_day_of_week_gst, today_current_hour_gst, segment_major, segment_minor;

-- SLACK SUMMARY QUERY
SELECT
  segment_major,
  segment_minor, 
  today_current_hour_gst,
  SUM(CASE WHEN booking_time_bucket_flag IN ("yes") THEN hourly_bookings ELSE 0 END) booking_total_prior_to_current_hour,
  SUM(hourly_bookings) AS booking_total
FROM booking_by_hour_data
WHERE segment_minor NOT IN ('actual_last_7_days', 'actuals_same_day_last_4_weeks')
GROUP BY segment_major, segment_minor, today_current_hour_gst;
