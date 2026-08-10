# Road Accident Analysis

This repository contains a reproducible analytics workflow for road-accident data, from raw CSV input to SQL-ready schema definitions, Python-based data checks and portfolio documentation.

## Project goal
The objective is to explore accident patterns across time, geography, weather, road conditions and driver behaviour, and to package the work in a way that is suitable for a data portfolio.

## Repository structure
- data/: raw and generated data files
- docs/: project documentation, including the data dictionary, dashboard guide and portfolio artefacts
- sql/: SQL schema and dashboard-oriented query examples
- tools/: Python utilities for data-quality checks and reporting
- notebooks/: workspace for exploratory analysis
- dashboard/: location for dashboard assets and related outputs

## Dataset overview
The main dataset is stored in data/Road_Accident_Prevention_Dataset_20000.csv and contains 20,000 records with fields such as accident ID, date, time, state, district, road conditions, weather, driver details and casualty information.

## Key deliverables
- Finalised data dictionary: docs/DATA_DICTIONARY.md
- SQL schema and query examples: sql/Schema.sql and sql/dashboard_queries.sql
- Python data-quality report utility: tools/data_quality_report.py
- Dashboard documentation: docs/DASHBOARD_DOCUMENTATION.md
- Portfolio-ready summary: docs/PORTFOLIO_ARTIFACTS.md

## How to use this project
1. Review the schema in sql/Schema.sql.
2. Run the Python utility to generate a data-quality report:
   python tools/data_quality_report.py
3. Use the SQL file in sql/dashboard_queries.sql as a starting point for dashboard KPIs.
4. Read the documentation under docs/ for the project narrative.

## Notes
The project is intentionally structured so that each file has a clear purpose and can be reused in future analysis or presentation work.
