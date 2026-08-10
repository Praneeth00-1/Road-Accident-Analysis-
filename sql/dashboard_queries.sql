-- Purpose: reusable SQL queries for dashboard metrics and exploratory analysis.
-- Assumes the cleaned table road_accident_prevention_clean already exists.

-- 1. Executive overview metrics
SELECT
    COUNT(*) AS total_accidents,
    SUM(Casualties) AS total_casualties,
    SUM(CASE WHEN Severity IN ('High', 'Severe', 'Fatal') THEN 1 ELSE 0 END) AS severe_incidents
FROM road_accident_prevention_clean;

-- 2. Accidents by state and casualty count
SELECT
    State,
    COUNT(*) AS accident_count,
    SUM(Casualties) AS total_casualties
FROM road_accident_prevention_clean
GROUP BY State
ORDER BY total_casualties DESC, accident_count DESC;

-- 3. Driver behaviour and risk factors
SELECT
    Driver_Gender,
    AVG(CAST(Speed_kmph AS DECIMAL(10,2))) AS avg_speed,
    SUM(CASE WHEN Alcohol_Involved = 'Yes' THEN 1 ELSE 0 END) AS alcohol_related_accidents,
    SUM(CASE WHEN Driver_Drowsy = 'Yes' THEN 1 ELSE 0 END) AS drowsy_driver_accidents
FROM road_accident_prevention_clean
GROUP BY Driver_Gender;

-- 4. Weather and road conditions by severity
SELECT
    Weather,
    Road_Type,
    Severity,
    COUNT(*) AS accident_count
FROM road_accident_prevention_clean
GROUP BY Weather, Road_Type, Severity
ORDER BY accident_count DESC;
