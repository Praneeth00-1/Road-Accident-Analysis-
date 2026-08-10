# Dashboard documentation

## Purpose of the dashboard
The dashboard is designed to support a quick, evidence-based review of accident risk patterns across time, geography and driver behaviour. It helps stakeholders move from raw records to a clear decision narrative.

## Recommended pages

### 1. Executive overview
Purpose: provide a high-level snapshot of accident volume, casualties and high-severity incidents.
Suggested visuals:
- Total accidents KPI
- Total casualties KPI
- Severity distribution chart
- Trend chart by date or month

### 2. Risk factor analysis
Purpose: highlight conditions that are strongly associated with severe outcomes.
Suggested visuals:
- Alcohol-involved incidents by severity
- Driver drowsiness by severity
- Pothole involvement by severity
- Road type and weather comparison charts

### 3. Geographic hotspots
Purpose: show where accidents are concentrated and which states or districts need intervention.
Suggested visuals:
- State-level accident count map or bar chart
- District-level casualty heatmap
- Top risky states and districts summary

## Measure definitions
- Total accidents: count of records in the dataset.
- Total casualties: sum of the Casualties field.
- Severe incidents: count of accidents with Severity values indicating major or critical outcomes.
- Alcohol-related share: percentage of records where Alcohol_Involved is Yes.
- Drowsy-driver share: percentage of records where Driver_Drowsy is Yes.
- Pothole-related share: percentage of records where Pothole_Involved is Yes.
- High-speed incidents: count of records where Speed_kmph exceeds a chosen threshold, such as 80 km/h.

## Suggested narrative for stakeholders
1. Start with the executive summary to show scale.
2. Move to risk factors to explain why severity rises.
3. Finish with geographic hotspots to identify where action is most urgent.
