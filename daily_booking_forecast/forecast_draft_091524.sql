WITH HourlySales AS (
    SELECT
        HOUR(DATE_ADD(b.created_on, INTERVAL 4 HOUR)) AS hour,
        COUNT(*) AS sales_count
    FROM rental_car_booking2 AS b
    WHERE HOUR(DATE_ADD(b.created_on, INTERVAL 4 HOUR)) <= HOUR(NOW()) + 4 -- Ensure we're only including records up to the current time
    GROUP BY hour
    ORDER BY hour
)
-- SELECT * FROM HourlySales;
,
HourlySalesAvg AS (
    SELECT
        hour,
        sales_count,
        AVG(sales_count) OVER (ORDER BY hour ROWS BETWEEN 23 PRECEDING AND CURRENT ROW) AS avg_sales_per_hour
    FROM HourlySales
)
SELECT
    hour,
    sales_count,
    avg_sales_per_hour
FROM HourlySalesAvg
ORDER BY hour;

