SELECT 
	*,
	booking_id
FROM myproject.rental_charges
-- WHERE booking_id IN ("240667") -- possible extension
-- WHERE booking_id IN ('245689') -- refund
-- WHERE booking_id IN ('240668') -- possible extension
-- WHERE booking_id IN ('246165')
WHERE booking_id IN ("247086")
-- WHERE booking_id IN ('240685','244787','245399','245689','246867','246876','258479','258490','258491')
ORDER BY booking_id, from_date
LIMIT 200;

-- SELECT 
-- 	SUM(total_charge) 
-- FROM myproject.rental_charges cc
-- WHERE cc.booking_id = b.id
-- AND cc.charge_type_id IN (1, 2, 8, 9, 13, 14, 20, 22, 24, 27, 28, 44, 45, 46, 47)) AS non_rental_charge,
-- 0 AS extension_charge,