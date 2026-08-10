CREATE DATABASE RoadAccident ;

USE RoadAccident ;


# Retrieving the whole data from the TABLE----
SELECT * FROM road_accident_prevention_clean ;

#Aplying the VARCHAR Constraint to the ID column---
ALTER TABLE road_accident_prevention_clean MODIFY Accident_ID VARCHAR(15);

#Applying the primary key to the ID column---
ALTER TABLE road_accident_prevention_clean  ADD PRIMARY KEY (Accident_ID);
DESCRIBE road_accident_prevention_clean;

SELECT * FROM road_accident_prevention_clean WHERE DATE IS NULL 
OR Time IS NULL 
OR State IS NULL
OR State IS NULL
OR District IS NULL
OR Latitude IS NULL
OR Longitude IS NULL
OR Road_Type IS NULL
OR Weather IS NULL
OR Light_Condition IS NULL
OR Driver_Age IS NULL
OR Driver_Gender IS NULL
OR Vehicle_Type IS NULL
OR Speed_kmph IS NULL 
OR Alcohol_Involved IS NULL;


select  * from road_accident_prevention_clean ;

SELECT Driver_Age ,State, SUM(Casualties) AS Total_Accidents 
FROM road_accident_prevention_clean 
GROUP BY Driver_Age  , State 
ORDER BY Driver_Age ASC ;


SELECT Driver_Age,Road_Type ,SUM(Casualties) AS Total_Accidents 
FROM road_accident_prevention_clean 
GROUP BY Driver_Age,Road_Type 
ORDER BY Driver_Age ASC ;

SELECT Driver_Age,Driver_Gender ,SUM(Casualties) AS Total_Accidents 
FROM road_accident_prevention_clean 
GROUP BY Driver_Age,Driver_Gender
ORDER BY Driver_Age ASC ;

SELECT COUNT(*) AS road_accident_prevention_clean
FROM road_accident_prevention_clean;


SELECT SUM(Casualties) AS road_accident_prevention_clean

FROM road_accident_prevention_clean;


SELECT Count(*) AS Alcohol_invovlved_accidents
FROM road_accident_prevention_clean
Where Alcohol_Involved = 'Yes'; 




SELECT *,
  dense_rank() OVER (PARTITION BY State order by Casualties DESC) AS 'Rank_of_Casualties'
  FROM road_accident_prevention_clean;
  
SELECT *,
  dense_rank() OVER (PARTITION BY State,District,Driver_Gender order by Casualties DESC) AS 'Gender'
  FROM road_accident_prevention_clean;
  
  
SELECT *,
row_number() OVER (ORDER BY Casualties) AS 'Row NUmbers'
FROM road_accident_prevention_clean;

SELECT Date,
COUNT(Casualties) AS Daily_Accidents ,
SUM(COUNT(Casualties)) OVER (ORDER BY Date) AS Running_Total
FROM road_accident_prevention_clean 
GROUP BY Date
ORDER BY Date;


SELECT
    Date,
    COUNT(*) AS Daily_Accidents,
    SUM(COUNT(*)) OVER (ORDER BY Date) AS Running_Total
FROM road_accident_prevention_clean
GROUP BY Date
ORDER BY Date;