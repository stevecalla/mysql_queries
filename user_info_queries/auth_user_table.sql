SELECT * FROM myproject.auth_user WHERE LOWER(first_name) LIKE '%test%' AND (LOWER(last_name) NOT LIKE '%test%' OR LOWER(username) NOT LIKE '%test%' OR email NOT LIKE '%test%');
SELECT * FROM myproject.auth_user WHERE LOWER(last_name) LIKE '%test%' AND (LOWER(first_name) NOT LIKE '%test%' OR LOWER(username) NOT LIKE '%test%'  OR email NOT LIKE '%test%');
SELECT * FROM myproject.auth_user WHERE LOWER(username) LIKE '%test%' AND (LOWER(first_name) NOT LIKE '%test%' OR LOWER(last_name) NOT LIKE '%test%' OR email NOT LIKE '%test%');
SELECT * FROM myproject.auth_user WHERE LOWER(email) LIKE '%test%' AND (LOWER(first_name) NOT LIKE '%test%' OR LOWER(last_name) NOT LIKE '%test%' OR username NOT LIKE '%test%');
SELECT * FROM myproject.auth_user WHERE LOWER(first_name) LIKE '%test%' OR LOWER(last_name) LIKE '%test%' OR LOWER(username) LIKE '%test%' OR LOWER(email) LIKE '%test%';
