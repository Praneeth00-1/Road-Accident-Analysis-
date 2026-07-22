# Raw Data Cleaning Plan v1

**Status:** Frozen v1  
**Frozen on:** 2026-07-22  
**Audience:** Dataset reviewers  
**Source snapshot:** `data/Road_Accident_Prevention_Dataset_20000.csv`

## Scope

This plan defines the first approved cleaning pass for the supplied road-accident CSV snapshot. It covers missing values, duplicates, type fixes, and category harmonisation observed in that file only. It is conservative: preserve the raw file and all 20,000 records, standardise only values supported by the observed data, and do not infer missing values.

## Baseline profile

- Rows profiled: 20,000
- Columns profiled: 20
- Columns with blanks: 1 (`Casualties`)
- Fully complete columns: 19
- Exact duplicate rows: 0
- Duplicate `Accident_ID` values: 0
- Malformed `Date` tokens using `dd-MM-yyyy`: 0; observed range: 2022-01-01 to 2024-12-30
- Malformed `Time` tokens using `HH:mm`: 0; observed range: 00:00 to 23:59
- Malformed numeric tokens in typed columns: 0
- Observed data exception: `Casualties` has 793 blank values (3.96%).

Notes:

- No domain-specific range is treated as invalid without a supplied data dictionary. The observed numeric ranges are retained.
- The `Casualties` values are float-style text (for example, `1.0`) even though the observed non-null values are whole numbers from 0 to 12.
- The observed categorical labels are already consistent in spelling and case. v1 preserves the observed labels while enforcing trim and canonical-case normalisation for future loads.

## v1 cleaning principles

- Keep the raw CSV unchanged and generate a separate cleaned layer.
- Keep every row in the current snapshot; no record is dropped in v1.
- Convert blank strings to `NULL`.
- Apply type fixes only where the target type is unambiguous from the source values.
- Apply category harmonisation by trimming whitespace and enforcing the observed canonical labels.
- Do not perform statistical or rule-based imputation in the base cleaned table.
- Defer any analysis-specific fill strategy to downstream views or models.

## Duplicate policy

| Check | Current finding | v1 action |
| --- | ---: | --- |
| Exact row duplicate | 0 | No row is dropped in the current snapshot. Retain this check for future loads. |
| `Accident_ID` duplicate | 0 | Keep as the required business key. Quarantine any future duplicate for review; do not keep the first record automatically. |

## Type-fix rules

| Target type | Columns | v1 rule |
| --- | --- | --- |
| `STRING` | `Accident_ID` | Trim only; retain as text because it is an identifier with the `ACC` prefix. |
| `DATE` | `Date` | Parse using `dd-MM-yyyy`; all 20,000 observed values parse successfully. |
| `TIME` | `Time` | Parse using `HH:mm`; all 20,000 observed values parse successfully. |
| `DECIMAL` | `Latitude`, `Longitude` | Cast after trim validation; all observed values are numeric. |
| `INTEGER` | `Driver_Age`, `Speed_kmph`, `Casualties` | Cast after trim validation. `Casualties` is cast from float-style whole-number text to integer; blanks remain `NULL`. |
| `STRING` / categorical | `State`, `District`, `Road_Type`, `Weather`, `Light_Condition`, `Driver_Gender`, `Vehicle_Type`, `Alcohol_Involved`, `Driver_Drowsy`, `Pothole_Involved`, `Cause_of_Accident`, `Severity` | Trim, normalise case to the observed canonical label, and retain as text. |

## Category harmonisation rules

Apply trim and canonical-case normalisation to every categorical field. No category merge is approved in v1: labels are only mapped to the values observed in this snapshot.

- `State`: Andhra Pradesh, Karnataka, Kerala, Puducherry, Tamil Nadu, Telangana
- `District`: trim only; retain the 27 observed district labels. Do not merge names without a geographic reference file.
- `Road_Type`: City Road, Expressway, National Highway, State Highway, Village Road
- `Weather`: Clear, Cloudy, Foggy, Overcast, Rainy
- `Light_Condition`: Dawn, Day, Dusk, Night
- `Driver_Gender`: Female, Male
- `Vehicle_Type`: Auto, Bike, Bus, Car, Truck
- `Alcohol_Involved`, `Driver_Drowsy`, `Pothole_Involved`: No, Yes
- `Cause_of_Accident`: Drowsy Driving, Drunk Driving, Over Speeding, Poor Weather Visibility, Pothole/Bad Road, Signal Jumping
- `Severity`: High, Low, Medium

## Frozen rule buckets

| Rule ID | Affected columns | Keep / drop / impute decision |
| --- | --- | --- |
| R1 | `Accident_ID` | Keep every non-null, unique identifier as text. No row is dropped. Any future null or duplicate is quarantined for review. |
| R2 | `Date`, `Time` | Keep every row; parse to `DATE` and `TIME`. No blanks or malformed values were found. Future parse failures are quarantined, not coerced or inferred. |
| R3 | `State`, `District`, `Road_Type`, `Weather`, `Light_Condition`, `Driver_Gender`, `Vehicle_Type`, `Alcohol_Involved`, `Driver_Drowsy`, `Pothole_Involved`, `Cause_of_Accident`, `Severity` | Keep every row; trim and map only to the observed canonical labels. No category value is imputed. Future blanks become `NULL`; unrecognised labels are flagged for review. |
| R4 | `Latitude`, `Longitude` | Keep every row; cast to `DECIMAL`. No blanks or malformed numeric values were found. Do not infer coordinates in v1. |
| R5 | `Driver_Age`, `Speed_kmph` | Keep every row; cast to `INTEGER`. No blanks or malformed numeric values were found. No range-based deletion or correction is approved without a data dictionary. |
| R6 | `Casualties` | Keep every row; cast valid float-style whole numbers to `INTEGER`. Convert the 793 blanks to `NULL`; do not impute zero because a blank does not establish zero casualties. |

## Column-level inventory

| Column | Nulls | Missing % | Rule ID | v1 action |
| --- | ---: | ---: | --- | --- |
| `Accident_ID` | 0 | 0.00% | R1 | Keep as required unique text key. |
| `Date` | 0 | 0.00% | R2 | Parse as `DATE` using `dd-MM-yyyy`. |
| `Time` | 0 | 0.00% | R2 | Parse as `TIME` using `HH:mm`. |
| `State` | 0 | 0.00% | R3 | Trim and retain observed canonical label. |
| `District` | 0 | 0.00% | R3 | Trim only; no geographic name merge. |
| `Latitude` | 0 | 0.00% | R4 | Cast to `DECIMAL`. |
| `Longitude` | 0 | 0.00% | R4 | Cast to `DECIMAL`. |
| `Road_Type` | 0 | 0.00% | R3 | Trim and retain observed canonical label. |
| `Weather` | 0 | 0.00% | R3 | Trim and retain observed canonical label. |
| `Light_Condition` | 0 | 0.00% | R3 | Trim and retain observed canonical label. |
| `Driver_Age` | 0 | 0.00% | R5 | Cast to `INTEGER`. |
| `Driver_Gender` | 0 | 0.00% | R3 | Trim and retain observed canonical label. |
| `Vehicle_Type` | 0 | 0.00% | R3 | Trim and retain observed canonical label. |
| `Speed_kmph` | 0 | 0.00% | R5 | Cast to `INTEGER`. |
| `Alcohol_Involved` | 0 | 0.00% | R3 | Trim and retain `No` or `Yes`. |
| `Driver_Drowsy` | 0 | 0.00% | R3 | Trim and retain `No` or `Yes`. |
| `Pothole_Involved` | 0 | 0.00% | R3 | Trim and retain `No` or `Yes`. |
| `Cause_of_Accident` | 0 | 0.00% | R3 | Trim and retain observed canonical label. |
| `Severity` | 0 | 0.00% | R3 | Trim and retain observed canonical label. |
| `Casualties` | 793 | 3.96% | R6 | Keep row; convert blank to `NULL`; cast valid values to `INTEGER`; do not impute. |

## Columns with no missing values

| Column group | Current quality status | v1 action |
| --- | --- | --- |
| `Accident_ID` | Complete and unique in the profiled snapshot | Keep as required event key. |
| `Date`, `Time` | Complete and fully parseable | Cast to target temporal types. |
| All columns except `Casualties` | Complete in the profiled snapshot | Apply only the type and canonicalisation rules stated above. |

## Acceptance criteria for v1

- Cleaned row count remains 20,000.
- No exact row is dropped in the current snapshot.
- `Accident_ID` remains non-null and unique.
- The 793 blank `Casualties` values are normalised to `NULL`; none is filled with zero or another value.
- `Date`, `Time`, and numeric fields load into their target types without malformed-token failures.
- Category fields are limited to the observed canonical sets listed above, and any future unrecognised value is reported.

## Deferred to v2

- Any imputation strategy for missing `Casualties`.
- Geographic validation or correction of coordinates and district labels using an approved reference dataset.
- Business-range validation for speed, age, casualties, or coordinates once a data dictionary defines accepted limits.
- Cross-field inference, including deriving a missing casualty count from severity or other accident attributes.
