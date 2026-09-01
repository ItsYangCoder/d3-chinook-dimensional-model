# Databricks notebook source
# /// script
# [tool.databricks.environment]
# environment_version = "5"
# ///
base_path = (
    "/Volumes/workspace/bronze/1st_volume/"
    "shared/week05/chinook_csv/"
)

csv_files = sorted(
    [
        file.name
        for file in dbutils.fs.ls(base_path)
        if file.name.lower().endswith(".csv")
    ]
)

if not csv_files:
    raise ValueError(
        f"No CSV files found in {base_path}"
    )

print(f"Found {len(csv_files)} CSV files:")

for file_name in csv_files:
    print(file_name)

# COMMAND ----------

# ============================ DYNAMIC SOURCE ROW-COUNT INSPECTION ================================
from datetime import datetime, timedelta


# Uses yesterday as the source/load date
load_date = (
    datetime.now() - timedelta(days=1)
).strftime("%Y-%m-%d")


queries = []

for file_name in csv_files:

    source_file = file_name.replace(".csv", "")
    file_path = f"{base_path}{file_name}"

    queries.append(f"""
        SELECT
            DATE('{load_date}') AS LoadDate,
            '{source_file}' AS source_file,
            COUNT(*) AS row_count,
            CURRENT_TIMESTAMP() AS EntryTime

        FROM read_files(
            '{file_path}',
            format => 'csv',
            header => true,
            inferSchema => true
        )
    """)


final_query = "\nUNION ALL\n".join(queries) + """
    ORDER BY source_file
"""


# Runs the generated SQL query.
source_counts_df = spark.sql(final_query)

display(source_counts_df)

# COMMAND ----------

# ============================ SAVE SOURCE COUNTS AS AN AUDIT TRAIL ================================
source_counts_df.createOrReplaceTempView(
    "current_source_counts"
)


# Create the audit table if it does not exist yet.
spark.sql("""
    CREATE TABLE IF NOT EXISTS
        workspace.d3_quality.source_row_count_audit
    (
        LoadDate DATE,
        source_file STRING,
        row_count BIGINT,
        EntryTime TIMESTAMP
    )
    USING DELTA
""")


# MERGE prevents duplicate records when the same
# source batch is inspected again.
spark.sql("""
    MERGE INTO
        workspace.d3_quality.source_row_count_audit AS target

    USING current_source_counts AS source

        ON target.LoadDate = source.LoadDate
       AND target.source_file = source.source_file

    WHEN MATCHED THEN
        UPDATE SET
            target.row_count = source.row_count,
            target.EntryTime = source.EntryTime

    WHEN NOT MATCHED THEN
        INSERT (
            LoadDate,
            source_file,
            row_count,
            EntryTime
        )
        VALUES (
            source.LoadDate,
            source.source_file,
            source.row_count,
            source.EntryTime
        )
""")


# Confirm that the audit records were saved.
display(
    spark.sql("""
        SELECT
            LoadDate,
            source_file,
            row_count,
            EntryTime
        FROM workspace.d3_quality.source_row_count_audit
        ORDER BY LoadDate DESC, source_file
    """)
)