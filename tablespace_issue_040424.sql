USE myproject;

SELECT table_name, engine
FROM information_schema.tables
WHERE table_schema = 'myproject' AND table_name = 'rental_car';

SHOW TABLE STATUS LIKE 'rental_car';

SELECT * FROM  rental_car LIMIT 1;
