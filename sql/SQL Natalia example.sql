/* CAPSTONE PROJECT QUERIES */

-- How many years of data is avaiable per route
-- Passengers
SELECT 
    origin,
    destination,
    COUNT(DISTINCT year) as years_with_data,
    SUM(passengers) as total_passengers,
    MIN(year) as first_year,
    MAX(year) as last_year
FROM group2.passengers_master
WHERE passengers IS NOT NULL AND origin IN ('FRANKFURT/MAIN airport', 'PARIS-CHARLES DE GAULLE airport','ADOLFO SUAREZ MADRID-BARAJAS airport','AMSTERDAM/SCHIPHOL airport')
GROUP BY origin, destination
ORDER BY years_with_data DESC, total_passengers DESC;

-- Cargo
SELECT 
    origin,
    destination,
    COUNT(DISTINCT year) as years_with_data,
    SUM(cargo) as total_cargo,
    MIN(year) as first_year,
    MAX(year) as last_year
FROM group2.cargo_master
WHERE cargo IS NOT NULL AND origin IN ('FRANKFURT/MAIN airport', 'PARIS-CHARLES DE GAULLE airport','ADOLFO SUAREZ MADRID-BARAJAS airport','AMSTERDAM/SCHIPHOL airport')
GROUP BY origin, destination
ORDER BY years_with_data DESC, total_cargo DESC;

-- Routes with 8 years of data
-- Passengers
SELECT origin, destination, COUNT(DISTINCT year) as years_with_data
FROM group2.passengers_master
WHERE passengers IS NOT NULL AND origin IN ('FRANKFURT/MAIN airport', 'PARIS-CHARLES DE GAULLE airport','ADOLFO SUAREZ MADRID-BARAJAS airport','AMSTERDAM/SCHIPHOL airport')
GROUP BY origin, destination
HAVING COUNT(DISTINCT year) = 8
ORDER BY origin, destination;

-- Cargo
SELECT origin, destination, COUNT(DISTINCT year) as years_with_data
FROM group2.CARGO_MASTER
WHERE cargo IS NOT NULL AND origin IN ('FRANKFURT/MAIN airport', 'PARIS-CHARLES DE GAULLE airport','ADOLFO SUAREZ MADRID-BARAJAS airport','AMSTERDAM/SCHIPHOL airport')
GROUP BY origin, destination
HAVING COUNT(DISTINCT year) = 8
ORDER BY origin, destination;

--Top 20 routes by total passengers
-- Passengers
SELECT 
    origin,
    destination,
    SUM(passengers) as total_passengers,
    COUNT(DISTINCT year) as years_with_data
FROM group2.passengers_master
WHERE passengers IS NOT NULL AND origin IN ('FRANKFURT/MAIN airport', 'PARIS-CHARLES DE GAULLE airport','ADOLFO SUAREZ MADRID-BARAJAS airport','AMSTERDAM/SCHIPHOL airport')
GROUP BY origin, destination
ORDER BY total_passengers DESC
LIMIT 20;

-- Cargo
SELECT 
    origin,
    destination,
    SUM(cargo) as total_cargo,
    COUNT(DISTINCT year) as years_with_data
FROM group2.cargo_master
WHERE cargo IS NOT NULL AND origin IN ('FRANKFURT/MAIN airport', 'PARIS-CHARLES DE GAULLE airport','ADOLFO SUAREZ MADRID-BARAJAS airport','AMSTERDAM/SCHIPHOL airport')
GROUP BY origin, destination
ORDER BY total_cargo DESC
LIMIT 20;

--Routes that existed in 2019 but disappeared after
-- passengers
SELECT DISTINCT origin, destination
FROM group2.passengers_master
WHERE year = 2019 AND passengers IS NOT NULL AND origin IN ('FRANKFURT/MAIN airport', 'PARIS-CHARLES DE GAULLE airport','ADOLFO SUAREZ MADRID-BARAJAS airport','AMSTERDAM/SCHIPHOL airport')
AND (origin, destination) NOT IN (
    SELECT DISTINCT origin, destination
    FROM group2.passengers_master
    WHERE year >= 2022 AND passengers IS NOT NULL
);
-- Cargo
SELECT DISTINCT origin, destination
FROM group2.cargo_master
WHERE year = 2019 AND cargo IS NOT NULL AND origin IN ('FRANKFURT/MAIN airport', 'PARIS-CHARLES DE GAULLE airport','ADOLFO SUAREZ MADRID-BARAJAS airport','AMSTERDAM/SCHIPHOL airport')
AND (origin, destination) NOT IN (
    SELECT DISTINCT origin, destination
    FROM group2.cargo_master
    WHERE year >= 2022 AND cargo IS NOT NULL
);


-- Quick check
SELECT COUNT(*) as routes_with_no_data_at_all
FROM (
    SELECT origin, destination
    FROM group2.passengers_master
    GROUP BY origin, destination
    HAVING SUM(CASE WHEN passengers IS NOT NULL THEN 1 ELSE 0 END) = 0
) sub;

-- quick check of number of routes and their data completeness, grouped by Full-Good-Medium-Low-Poor

SELECT 
    CASE 
        WHEN rows_with_data = 0 THEN '0% - No data at all'
        WHEN rows_with_data < 24 THEN 'Low - less than 2 years'
        WHEN rows_with_data < 48 THEN 'Medium - 2 to 4 years'
        WHEN rows_with_data < 96 THEN 'Good - 4 to 8 years'
        ELSE 'Full - 8 years'
    END as completeness_bucket,
    COUNT(*) as number_of_routes
FROM (
    SELECT 
        origin, 
        destination,
        SUM(CASE WHEN passengers IS NOT NULL THEN 1 ELSE 0 END) as rows_with_data
    FROM group2.passengers_master
    WHERE origin IN ('FRANKFURT/MAIN airport', 'PARIS-CHARLES DE GAULLE airport','ADOLFO SUAREZ MADRID-BARAJAS airport','AMSTERDAM/SCHIPHOL airport')
    GROUP BY origin, destination
) sub
GROUP BY completeness_bucket
ORDER BY completeness_bucket;

SELECT 
    CASE 
        WHEN rows_with_data = 0 THEN '0% - No data at all'
        WHEN rows_with_data < 24 THEN 'Low - less than 2 years'
        WHEN rows_with_data < 48 THEN 'Medium - 2 to 4 years'
        WHEN rows_with_data < 96 THEN 'Good - 4 to 8 years'
        ELSE 'Full - 8 years'
    END as completeness_bucket,
    COUNT(*) as number_of_routes
FROM (
    SELECT 
        origin, 
        destination,
        SUM(CASE WHEN cargo IS NOT NULL THEN 1 ELSE 0 END) as rows_with_data
    FROM group2.cargo_master
    WHERE origin IN ('FRANKFURT/MAIN airport', 'PARIS-CHARLES DE GAULLE airport','ADOLFO SUAREZ MADRID-BARAJAS airport','AMSTERDAM/SCHIPHOL airport')
    GROUP BY origin, destination
) sub
GROUP BY completeness_bucket
ORDER BY completeness_bucket;


-- creating two new columns for storing the first active year of a route and its last active year
-- aim is to be able to caluclate later, our survivors, lost and new routes.
ALTER TABLE group2.passengers_master 
ADD COLUMN first_year INTEGER,
ADD COLUMN last_year INTEGER;

UPDATE group2.passengers_master p
SET 
    first_year = route_info.first_year,
    last_year = route_info.last_year
FROM (
    SELECT 
        origin,
        destination,
        origin_country,
        MIN(year) as first_year,
        MAX(year) as last_year
    FROM group2.passengers_master
    WHERE passengers IS NOT NULL
    GROUP BY origin, destination, origin_country
) route_info
WHERE p.origin = route_info.origin 
AND p.destination = route_info.destination
AND p.origin_country = route_info.origin_country;


SELECT count(*) FROM GROUP2.PASSENGERS_MASTER PM;  --WHERE PM.FIRST_YEAR IS NOT NULL;


-- not working
SELECT 
    origin,
    destination,
    COUNT(DISTINCT year) as years_with_data,
    MIN(year) as first_year,
    MAX(year) as last_year,
    SUM(CASE WHEN passengers IS NOT NULL THEN 1 ELSE 0 END) as months_with_data
FROM group2.passengers_master
GROUP BY origin, destination
HAVING SUM(CASE WHEN passengers IS NOT NULL THEN 1 ELSE 0 END) > 0
AND COUNT(DISTINCT year) < 4
ORDER BY first_year, last_year;



-- Try casting explicitly
SELECT origin, destination
FROM group2.passengers_master
WHERE passengers IS NOT NULL
GROUP BY origin, destination
HAVING 
    SUM(CASE WHEN year::integer = 2019 THEN 1 ELSE 0 END) > 0
    AND SUM(CASE WHEN year::integer >= 2021 THEN 1 ELSE 0 END) > 0;


SELECT COUNT(*) as qualifying_routes
FROM (
    SELECT origin, destination
    FROM group2.passengers_master
    WHERE passengers IS NOT NULL
    GROUP BY origin, destination
    HAVING 
        MAX(CASE WHEN year = 2019 THEN 1 ELSE 0 END) = 1
        AND MAX(CASE WHEN year >= 2021 THEN 1 ELSE 0 END) = 1
) sub;

SELECT 
    origin,
    destination,
    origin_country,
    COUNT(DISTINCT year) as years_with_data,
    STRING_AGG(DISTINCT year::text, ', ' ORDER BY year::text) as active_years,
    SUM(CASE WHEN year BETWEEN 2017 AND 2019 THEN 1 ELSE 0 END) as baseline_years,
    SUM(CASE WHEN year IN (2020, 2021) THEN 1 ELSE 0 END) as covid_years,
    SUM(CASE WHEN year BETWEEN 2022 AND 2024 THEN 1 ELSE 0 END) as postcovid_years
FROM group2.passengers_master
WHERE passengers IS NOT NULL
GROUP BY origin, destination, origin_country
HAVING COUNT(DISTINCT year) < 4
ORDER BY origin_country, active_years;


SELECT 
    origin,
    destination,
    origin_country,
    COUNT(DISTINCT year) as years_with_data,
    STRING_AGG(DISTINCT year::text, ', ' ORDER BY year::text) as active_years,
    SUM(CASE WHEN year BETWEEN 2017 AND 2019 THEN 1 ELSE 0 END) as baseline_years,
    SUM(CASE WHEN year IN (2020, 2021) THEN 1 ELSE 0 END) as covid_years,
    SUM(CASE WHEN year BETWEEN 2022 AND 2024 THEN 1 ELSE 0 END) as postcovid_years
FROM group2.cargo_master
WHERE cargo IS NOT NULL
GROUP BY origin, destination, origin_country
HAVING COUNT(DISTINCT year) < 4
ORDER BY origin_country, active_years;

-- new conditions: 12 months of data in each period and present in all periods
SELECT COUNT(*) as qualifying_routes
FROM (
    SELECT origin, destination, origin_country
    FROM group2.cargo_master
    WHERE cargo IS NOT NULL
    AND origin IN (
        'FRANKFURT/MAIN airport',
        'PARIS-CHARLES DE GAULLE airport',
        'ADOLFO SUAREZ MADRID-BARAJAS airport',
        'AMSTERDAM/SCHIPHOL airport'
    )
    GROUP BY origin, destination, origin_country
    HAVING 
        COUNT(CASE WHEN year BETWEEN 2017 AND 2019 
              AND cargo IS NOT NULL THEN 1 END) >= 12
        AND COUNT(CASE WHEN year IN (2020, 2021) 
              AND cargo IS NOT NULL THEN 1 END) >= 12
        AND COUNT(CASE WHEN year BETWEEN 2022 AND 2024 
              AND cargo IS NOT NULL THEN 1 END) >= 12
) sub;


-- Check breakdown by airport
SELECT origin, COUNT(DISTINCT destination) as qualifying_routes
FROM (
    SELECT origin, destination, origin_country
    FROM group2.passengers_master
    WHERE passengers IS NOT NULL
    AND origin IN (
        'FRANKFURT/MAIN airport',
        'PARIS-CHARLES DE GAULLE airport',
        'ADOLFO SUAREZ MADRID-BARAJAS airport',
        'AMSTERDAM/SCHIPHOL airport'
    )
    GROUP BY origin, destination, origin_country
    HAVING 
        COUNT(CASE WHEN year BETWEEN 2017 AND 2019 
              AND passengers IS NOT NULL THEN 1 END) >= 12
        AND COUNT(CASE WHEN year IN (2020, 2021) 
              AND passengers IS NOT NULL THEN 1 END) >= 12
        AND COUNT(CASE WHEN year BETWEEN 2022 AND 2024 
              AND passengers IS NOT NULL THEN 1 END) >= 12
) sub
GROUP BY origin
ORDER BY origin;

SELECT origin, COUNT(DISTINCT destination) as routes
FROM group2.passengers_core
GROUP BY origin
ORDER BY origin;

SELECT *  FROM cargo_master WHERE DESTINATION_COUNTRY IS NULL;

SELECT 
    CASE 
        WHEN year BETWEEN 2017 AND 2019 THEN 'Baseline'
        WHEN year IN (2020, 2021) THEN 'COVID'
        WHEN year BETWEEN 2022 AND 2024 THEN 'Post-COVID'
    END as period,
    COUNT(*) as rows,
    SUM(passengers) as total_passengers
FROM group2.passengers_core
WHERE passengers IS NOT NULL
GROUP BY period
ORDER BY period;


SELECT COUNT(*) 
FROM group2.passengers_master
WHERE origin_country IN ('NL', 'FR')
AND origin IS NULL
AND destination IS NULL
AND passengers IS NULL
AND flights IS NULL;

DELETE FROM group2.cargo_master
WHERE origin_country IN ('NL', 'FR')
AND origin IS NULL
AND destination IS NULL
AND cargo IS NULL
AND flights IS NULL;

SELECT count(distinct destination) FROM PASSENGERS_core;




