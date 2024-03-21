-- Select database
USE ezhire_key_metrics;

-- Set parameters
SET @booking_date = '2023-01-01';
SET @return_date = '2023-01-01';
SET @status = '%Cancel%';

-- Query 4: Get days on rent for vendor and store in a temporary table
SELECT
    ct.calendar_date,

    -- MARKETPLACE VS DISPATCH
    SUM(
        CASE
            WHEN ct.calendar_date = km.pickup_date AND vendor LIKE 'Dispatch' THEN km.pickup_fraction_of_day
            WHEN ct.calendar_date = km.return_date AND vendor LIKE 'Dispatch' THEN km.return_fraction_of_day
            WHEN ct.calendar_date BETWEEN km.pickup_date AND km.return_date AND vendor LIKE 'Dispatch' THEN 1
            ELSE 0
        END
    ) AS vendor_on_rent_dispatch,
    
    SUM(
        CASE
            WHEN ct.calendar_date = km.pickup_date AND vendor LIKE 'MarketPlace' THEN km.pickup_fraction_of_day
            WHEN ct.calendar_date = km.return_date AND vendor LIKE 'MarketPlace' THEN km.return_fraction_of_day
            WHEN ct.calendar_date BETWEEN km.pickup_date AND km.return_date AND vendor LIKE 'MarketPlace' THEN 1
            ELSE 0
        END
    ) AS vendor_on_rent_marketplace

FROM
    calendar_table ct
INNER JOIN
    key_metrics_base km
    ON ct.calendar_date >= @booking_date
    AND km.return_date >= @return_date
    AND ct.calendar_date >= km.booking_date
    AND ct.calendar_date <= km.return_date
    AND km.status NOT LIKE @status
GROUP BY
    ct.calendar_date
ORDER BY
    ct.calendar_date ASC;