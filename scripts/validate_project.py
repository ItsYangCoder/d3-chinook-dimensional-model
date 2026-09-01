"""Repository-level checks for the Chinook Databricks project.

These checks validate files and project conventions only. Data-quality SQL
checks still run in Databricks because they require the Unity Catalog tables.
"""

from __future__ import annotations

import ast
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]

REQUIRED_FILES = [
    "src/sql/00_setup/00_setup.sql",
    "src/sql/01_raw/01_raw_customer.sql",
    "src/sql/01_raw/02_raw_sales.sql",
    "src/sql/01_raw/03_raw_employee.sql",
    "src/sql/01_raw/04_raw_music.sql",
    "src/sql/02_clean/01_clean_customer.sql",
    "src/sql/02_clean/02_clean_sales.sql",
    "src/sql/02_clean/03_clean_employee.sql",
    "src/sql/02_clean/04_clean_music.sql",
    "src/sql/03_mart/01_dim_customer.sql",
    "src/sql/03_mart/02_dim_date.sql",
    "src/sql/03_mart/03_dim_employee.sql",
    "src/sql/03_mart/04_dim_track.sql",
    "src/sql/03_mart/05_fact_sales.sql",
    "src/sql/04_analytics/01_top_revenue_genre_country.sql",
    "src/sql/04_analytics/02_customer_spending_tiers.sql",
    "src/sql/04_analytics/03_monthly_sales_trend.sql",
    "src/sql/04_analytics/04_employee_sales_performance.sql",
    "src/sql/04_analytics/05_track_popularity_genre_playlist.sql",
    "src/sql/04_analytics/06_regional_customer_behavior.sql",
    "tests/01_source_checks.sql",
    "tests/02_clean_checks.sql",
    "tests/03_mart_checks.sql",
    "tests/04_business_query_checks.sql",
]

ERRORS: list[str] = []


def check_required_files() -> None:
    for relative_path in REQUIRED_FILES:
        path = ROOT / relative_path
        if not path.is_file():
            ERRORS.append(f"Missing required file: {relative_path}")
        elif not path.read_text(encoding="utf-8").strip():
            ERRORS.append(f"File is empty: {relative_path}")


def check_sql_files() -> int:
    sql_files = sorted(
        list((ROOT / "src" / "sql").rglob("*.sql"))
        + list((ROOT / "tests").glob("*.sql"))
    )

    for path in sql_files:
        text = path.read_text(encoding="utf-8")
        if not text.strip():
            ERRORS.append(f"SQL file is empty: {path.relative_to(ROOT)}")

    raw_files = sorted((ROOT / "src" / "sql" / "01_raw").glob("*.sql"))
    for path in raw_files:
        text = path.read_text(encoding="utf-8").upper()
        if "CREATE OR REPLACE TABLE" in text:
            ERRORS.append(
                "Raw layer must not overwrite tables with CREATE OR REPLACE: "
                f"{path.relative_to(ROOT)}"
            )
        if "CREATE TABLE IF NOT EXISTS" not in text:
            ERRORS.append(
                "Raw layer should use CREATE TABLE IF NOT EXISTS: "
                f"{path.relative_to(ROOT)}"
            )

    return len(sql_files)


def check_python_files() -> int:
    python_files = sorted(
        path
        for path in ROOT.rglob("*.py")
        if ".git" not in path.parts
    )

    for path in python_files:
        try:
            ast.parse(path.read_text(encoding="utf-8"), filename=str(path))
        except SyntaxError as error:
            ERRORS.append(
                f"Python syntax error in {path.relative_to(ROOT)}: "
                f"line {error.lineno}, {error.msg}"
            )

    return len(python_files)


def check_bundle_config() -> None:
    bundle_path = ROOT / "databricks.yml"
    if not bundle_path.is_file():
        ERRORS.append("Missing Databricks bundle configuration: databricks.yml")
        return

    text = bundle_path.read_text(encoding="utf-8")
    for required_text in ("bundle:", "variables:", "targets:", "resources:", "jobs:"):
        if required_text not in text:
            ERRORS.append(
                f"databricks.yml is missing the expected section: {required_text}"
            )


def main() -> int:
    check_required_files()
    sql_count = check_sql_files()
    python_count = check_python_files()
    check_bundle_config()

    if ERRORS:
        print("Chinook CI validation failed:")
        for error in ERRORS:
            print(f"- {error}")
        return 1

    print(
        "Chinook CI validation passed: "
        f"{sql_count} SQL files and {python_count} Python files checked."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
