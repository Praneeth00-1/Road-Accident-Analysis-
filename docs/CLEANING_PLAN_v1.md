# Cleaning Plan v1

**Status:** Frozen  
**Scope:** Raw road-accident extracts loaded into accident, casualty, and vehicle tables.  
**Evidence note:** No source extract or data dictionary is currently present in this repository. The rules below are the approved baseline; run the profiling gate before applying them and record observed counts in the cleaning log.

## Operating rules

1. Preserve the raw file unchanged. Produce a cleaned, versioned output and an audit log containing input row count, output row count, rejected rows, duplicate count, and missing-value counts before and after cleaning.
2. Convert blank strings, whitespace-only values, `NULL`, `N/A`, `NA`, `Unknown`, `Not known`, `-1`, and `999` to a single null representation **only where the source data dictionary identifies them as missing/unknown**. Do not recode a valid code without that confirmation.
3. Standardise text by trimming whitespace, collapsing repeated spaces, and normalising case for matching. Store display labels in title case and retain source-code columns where available.
4. Quarantine rows that fail key, date/time, or impossible-range checks. Do not silently delete them.
5. Calculate duplicate rules separately for each grain: accident, casualty, and vehicle. Keep the most complete record; if tied, keep the earliest ingested record. Log every removed duplicate.

## Column-level decisions

| Field(s) | Type fix | Missing-value rule | Duplicate / validity rule | Category harmonisation |
| --- | --- | --- | --- | --- |
| `Accident_Index` / `Accident_ID` | String; trim; preserve leading zeroes | **Drop/quarantine row** if null or blank | Accident table: unique key. Exact duplicate key: keep most complete record. Conflicting duplicate key: quarantine. | None |
| `Vehicle_Reference`, `Casualty_Reference` | Nullable integer | Null is permitted only when the table grain does not require it; otherwise **quarantine** | Unique with `Accident_ID` at its table grain; duplicate composite keys handled by operating rule 5 | None |
| `Accident Date` / `Date` | Parse to ISO `date` using documented source locale; retain raw value | **Quarantine** if null or unparsable | Quarantine dates outside documented coverage or future dates | None |
| `Time` | Parse to 24-hour `time` (`HH:MM`) | Keep null as `time_unknown`; do not impute | Quarantine unparsable values; validate 00:00–23:59 | None |
| `Day_of_Week` | Integer code plus canonical label | Keep null as `day_unknown`; do not impute | Where both date and day exist, regenerate/flag mismatch; date-derived value is authoritative | Map code/variants to `Monday`–`Sunday` |
| `Year`, `Month` | Integer (`Year`), integer 1–12 (`Month`) | Derive from valid date when missing; otherwise retain null | Quarantine impossible values; flag mismatch against date | Month labels → 1–12 plus canonical English label |
| `Latitude`, `Longitude`, `Easting`, `Northing` | Decimal numeric | Keep null; no geographic imputation | Quarantine nonnumeric or out-of-bound coordinates for the documented geography; retain only valid coordinate pairs | None |
| `Police_Force`, `Local_Authority_(District)`, `Local_Authority_(Highway)`, `LSOA_of_Accident_Location` | String/code; preserve code leading zeroes | Keep null as `area_unknown`; do not impute | Flag codes absent from the reference lookup; do not discard valid accidents solely for missing area | Trim; map only through an approved lookup; use `Unknown` as display label |
| `Accident_Severity`, `Casualty_Severity` | Ordered categorical; retain numeric source code when supplied | Keep null as `severity_unknown`; do not impute | Flag codes outside approved lookup | Canonical labels: `Fatal`, `Serious`, `Slight`, `Unknown`; map synonyms/case variants via lookup |
| `Number_of_Vehicles`, `Number_of_Casualties` | Non-negative integer | Keep null; do not impute | Quarantine negative/noninteger values; flag mismatch against linked vehicle/casualty row counts (do not overwrite without source-of-truth decision) | None |
| `Speed_limit` | Integer mph (or documented unit) | Keep null; do not impute | Quarantine nonnumeric, <=0, or values outside documented jurisdictional range | Convert unit only when metadata specifies a different source unit; record unit |
| `Road_Type`, `Road_Surface_Conditions`, `Carriageway_Hazards`, `Junction_Control`, `Junction_Detail`, `Light_Conditions`, `Weather_Conditions`, `Special_Conditions_at_Site`, `Pedestrian_Crossing-Human_Control`, `Pedestrian_Crossing-Physical_Facilities` | Categorical string/code | Keep null as `Unknown`; do not impute | Flag unmapped values for review | Trim/case-normalise; map spelling, punctuation and documented code variants through a versioned lookup; never merge materially distinct categories |
| `Urban_or_Rural_Area` | Categorical string/code | Keep null as `Unknown`; do not impute | Flag unmapped values | Map to `Urban`, `Rural`, `Unknown` |
| `Vehicle_Type`, `Vehicle_Manoeuvre`, `Vehicle_Location-Restricted_Lane`, `Hit_Object_in_Carriageway`, `Hit_Object_off_Carriageway`, `Skidding_and_Overturning`, `Vehicle_Leaving_Carriageway`, `1st_Point_of_Impact`, `Journey_Purpose_of_Driver`, `Towing_and_Articulation`, `Was_Vehicle_Left_Hand_Drive?` | Categorical string/code | Keep null as `Unknown`; do not impute | Flag unmapped values | Use approved vehicle lookup; normalise yes/no to `Yes`, `No`, `Unknown` |
| `Sex_of_Driver`, `Sex_of_Casualty`, `Pedestrian_Location`, `Pedestrian_Movement`, `Pedestrian_Road_Maintenance_Worker` | Categorical string/code | Keep null as `Unknown`; do not infer | Flag unmapped values | Canonicalise documented labels only; retain `Unknown` rather than guessing identity |
| `Age_of_Driver`, `Age_of_Casualty`, `Age_Band_of_Driver`, `Age_Band_of_Casualty` | Age: nullable integer; band: ordered categorical | Keep age null; do not impute. Derive a band only from a valid age and retain source band separately. | Quarantine negative or implausible ages according to the data dictionary; flag age/band mismatch | Map bands to documented ordered labels; keep `Unknown` separate |
| `Engine_Capacity_(CC)`, `Age_of_Vehicle` | Nullable integer | Keep null; do not impute | Quarantine negative/noninteger values; flag implausible values for review rather than capping | None |
| `Driver_Home_Area_Type` | Categorical string/code | Keep null as `Unknown`; do not impute | Flag unmapped values | Map to documented lookup labels |
| `Date`, `Time`, and all numeric fields not named above | Parse explicitly; never rely on locale inference or automatic mixed-type coercion | Retain null unless the field is a key or required operational field | Quarantine parse failures and impossible values; include them in audit output | Text dimensions use trim/collapse/case rules and a lookup where one exists |

## Profiling gate (required before implementation)

For every delivered table, create a profile that records: column name, source type, cleaned type, null count/rate, distinct count, top values, numeric min/max, parse failures, exact duplicate count, key-duplicate count, and unmapped category count. Add every field not listed above to the profile and obtain approval before adding a new imputation or drop rule.

## Explicit non-imputation policy

No demographic, severity, geographic, weather, road-condition, vehicle, count, or time value is statistically imputed in v1. The only derivations permitted are `Year`, `Month`, and `Day_of_Week` from a valid date, and an age band from a valid numeric age. This preserves analytical provenance and prevents fabricated accident characteristics.

## Acceptance criteria

- Raw inputs are immutable and cleaned outputs are reproducible.
- All rows removed or quarantined have a reason code.
- Primary/composite key uniqueness is verified at each table grain.
- Canonical category lookups have no unreviewed unmapped values.
- The audit log shows before/after row counts and missingness for every column.

