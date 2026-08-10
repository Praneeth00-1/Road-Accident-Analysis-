"""Purpose: generate a lightweight data-quality report for the road accident dataset."""
from __future__ import annotations

import csv
import json
from collections import Counter
from pathlib import Path
from typing import Dict, List

ROOT = Path(__file__).resolve().parents[1]
DATA_PATH = ROOT / "data" / "Road_Accident_Prevention_Dataset_20000.csv"


def load_rows(path: Path) -> List[Dict[str, str]]:
    with path.open("r", encoding="utf-8", newline="") as handle:
        return list(csv.DictReader(handle))


def build_report(rows: List[Dict[str, str]]) -> Dict[str, object]:
    headers = list(rows[0].keys()) if rows else []
    missing_counts = {column: 0 for column in headers}
    for row in rows:
        for column in headers:
            if row.get(column, "") in {"", None}:
                missing_counts[column] += 1

    severity_counts = Counter(row.get("Severity", "") for row in rows)
    cause_counts = Counter(row.get("Cause_of_Accident", "") for row in rows)

    return {
        "row_count": len(rows),
        "columns": headers,
        "missing_values": missing_counts,
        "severity_distribution": dict(severity_counts),
        "top_causes": dict(cause_counts.most_common(10)),
    }


if __name__ == "__main__":
    rows = load_rows(DATA_PATH)
    report = build_report(rows)
    output_path = ROOT / "data" / "data_quality_report.json"
    output_path.write_text(json.dumps(report, indent=2), encoding="utf-8")
    print(json.dumps(report, indent=2))
