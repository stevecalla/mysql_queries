-- SLACK NOTE WITH QUERY: https://ezhire.slack.com/archives/C075D9HPPGU/p1733864592632719
-- ERP CAR REPORT: https://www.ezhire.life/erp/#/vendor_cars_change_status/1
USE myproject;

DROP TEMPORARY TABLE IF EXISTS  tmp_car;
CREATE TEMPORARY TABLE tmp_car
SELECT 
	MAX(cs.id) AS maxid,
    (cs.car_id) AS car_id
FROM rental_booking_car_driver_status cs
	INNER JOIN rental_car cr ON cs.car_id = cr.id
WHERE cr.user_id = 234555
GROUP BY cs.car_id;

SELECT 
	* 
	,(Grand_total_Available + Grand_total_on_rental + rp_ncm_out + dc_ncm_out + others_count) AS total_cars
	,(Grand_total_on_rental / (Grand_total_Available + Grand_total_on_rental + rp_ncm_out + dc_ncm_out + others_count))*100 AS total_utilization
FROM (
	SELECT 	
		SUM(CASE WHEN car_status IN (9,14,15,16,21,23) AND car_reason <> 9 THEN  status_count ELSE 0 END) AS Grand_total_Available
		,SUM(CASE WHEN car_status IN (2,3,4,10,11,31,17,18,19) THEN status_count ELSE 0 END) AS Grand_total_on_rental
		,SUM(CASE WHEN car_status  IN (22) AND replacement_of = 1 THEN status_count ELSE 0 END) AS rp_ncm_out
		,SUM(CASE WHEN car_status IN (22) AND replacement_of = 0 THEN status_count ELSE 0 END) AS dc_ncm_out
		,(SELECT COUNT(c.id) AS status_count FROM rental_car c WHERE user_id = 234555 AND replacement_status IN (4,9,7,8,11)) AS others_count
	FROM (
		SELECT COUNT(cr.id) status_count
		,COALESCE(cr_st.car_status,0) AS car_status
		,COALESCE(cr_st.reason_id,0) AS car_reason
		,(CASE WHEN COALESCE(cr.replacement_of,0) = 0 THEN 0 ELSE 1 END) replacement_of
	FROM rental_car cr
		INNER JOIN tmp_car tc ON cr.id = tc.car_id
		INNER JOIN rental_booking_car_driver_status cr_st ON cr_st.id = tc.maxid
	WHERE
		cr.user_id = 234555
		AND cr.status = 1
	GROUP BY 
		COALESCE(cr_st.car_status,0)
		,COALESCE(cr_st.reason_id,0) 
		,(CASE WHEN COALESCE(cr.replacement_of,0) = 0 THEN 0 ELSE 1 END)
	)t
)f;