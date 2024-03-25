-- Burhan Khan = you can get the lifetime booking revenue of a customer from below code.

SELECT owner_id,SUM(rental_charges) as rental_charges
FROM rental_car_booking2 r
LEFT JOIN (SELECT booking_id,COALESCE(ROUND(SUM(total_charge),2),0) AS rental_charges
	FROM rental_charges rc WHERE (charge_type_id IN (SELECT id FROM rental_charge_types ct WHERE ct.id = rc.charge_type_id AND ct.is_rental = 1)
	OR charge_type_id in (35,43)) AND charge_type_id NOT IN (1,14,34,9,34,22,2,12,8) GROUP BY booking_id) as t ON t.booking_id = r.id
   # excluding cancellation booking statu <> 8 
   WHERE status <> 8
   GROUP BY 1
   ORDER BY owner_id desc
   limit 10
    ;