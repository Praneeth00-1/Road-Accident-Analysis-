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


