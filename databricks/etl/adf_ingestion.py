# ADF Triggered Notebook: JSON Ingestion from ADLS
# This notebook is triggered by Azure Data Factory pipeline activity
# Reads mcc_codes and fraud_labels from ADLS Gen2 and writes to Unity Catalog bronze layer
# Note: ADF Delta Lake connector does not support Unity Catalog three-level namespace
# Fallback: ADF triggers this notebook via Notebook activity instead

mcc_raw_df = (
    spark.read
    .format("json")
    .option("multiLine", "true")
    .load("abfss://labdata@jarvisetlstorage.dfs.core.windows.net/mcc_codes.json")
)

(mcc_raw_df.write
    .mode("overwrite")
    .option("overwriteSchema", "true")
    .saveAsTable("jarvis_etl.bronze.mcc_codes"))

print("jarvis_etl.bronze.mcc_codes written successfully")

fraud_labels_raw_df = (
    spark.read
    .format("json")
    .option("multiLine", "true")
    .load("abfss://labdata@jarvisetlstorage.dfs.core.windows.net/train_fraud_labels.json")
)

(fraud_labels_raw_df.write
    .mode("overwrite")
    .option("overwriteSchema", "true")
    .saveAsTable("jarvis_etl.bronze.fraud_labels"))

print("jarvis_etl.bronze.fraud_labels written successfully")
