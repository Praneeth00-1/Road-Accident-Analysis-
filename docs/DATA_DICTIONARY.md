# Data dictionary

This dictionary describes the fields used in the accident analysis dataset.

| Column | Type | Description |
| --- | --- | --- |
| Accident_ID | String | Unique identifier for each accident record. |
| Date | Date | Date of the accident. |
| Time | Time | Time of the accident. |
| State | String | State or region where the accident occurred. |
| District | String | District within the state. |
| Latitude | Float | Approximate latitude coordinate. |
| Longitude | Float | Approximate longitude coordinate. |
| Road_Type | String | Classification of the road segment. |
| Weather | String | Weather condition at the time of the event. |
| Light_Condition | String | Lighting condition, such as daylight or night. |
| Driver_Age | Integer | Age of the driver involved. |
| Driver_Gender | String | Gender of the driver. |
| Vehicle_Type | String | Type of vehicle involved. |
| Speed_kmph | Integer | Vehicle speed in kilometres per hour. |
| Alcohol_Involved | String | Indicates whether alcohol was involved. |
| Driver_Drowsy | String | Indicates whether the driver was drowsy. |
| Pothole_Involved | String | Indicates whether potholes were involved. |
| Cause_of_Accident | String | Main cause assigned to the accident record. |
| Severity | String | Severity level of the accident outcome. |
| Casualties | Integer | Number of casualties associated with the record. |

## Notes
- The dataset contains 20,000 accident records.
- The most relevant analytical dimensions are time, geography, road conditions, weather, driver behaviour and vehicle characteristics.
- The field names in this dictionary align with the CSV file used for the project.
