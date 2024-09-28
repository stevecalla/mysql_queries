-- Majid Khan, 3/12/24
-- They use this query to split number of days of booking month wise, then they calculate amount with respective rates

DROP TABLE IF EXISTS myproject.tmp_rental_car_booking2_view;
CREATE table myproject.tmp_rental_car_booking2_view
SELECT b.id,b.deliver_date_string delivery_date,b.deliver_time_string,b.return_date_string return_date,
       b.return_time_string,
(SELECT concat(er.new_return_date,' ',er.new_return_time)
		FROM myproject.rental_early_return_bookings er
		WHERE er.booking_id=b.id
		AND er.is_active=1 order by er.id desc limit 1) early_return_date_and_time
FROM myproject.rental_car_booking2 b
WHERE vendor_id not in(5,218,23086)
#AND b.id = 18487
AND status <> 8;

-- ***** 2nd QUERY ****
-- SELECT b.id,date_format(p.v_date,'%b-%Y') month,COUNT(1) days
-- FROM myproject.tmp_rental_car_booking2_view b
-- ,myproject.all_periods p
-- WHERE
-- (p.v_date between
--     STR_TO_DATE(b.delivery_date, '%d/%m/%Y')
--        AND COALESCE(str_to_date(b.early_return_date_and_time,'%d/%m/%Y %H:%i'),STR_TO_DATE(b.return_date, '%d/%m/%Y'))
-- )
-- #AND p.v_date between '2023-03-01' and '2023-03-07'
-- #AND b.id = 157758
-- #AND b.id = 18487
-- #AND b.id in (20561)
-- GROUP BY b.id,date_format(p.v_date,'%b-%Y');