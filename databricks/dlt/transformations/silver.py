from pyspark import pipelines as dp
from pyspark.sql.functions import col, to_date
from pyspark.sql.types import DecimalType

@dp.table(
    name="silver_stock_prices",
    comment="Cleaned and typed stock prices from bronze layer"
)
def silver_stock_prices():
    return (
        spark.read.table("bronze_stock_prices")
        .withColumn("trade_date", to_date(col("trade_date"), "yyyy-MM-dd"))
        .withColumn("open", col("open").cast(DecimalType(10, 4)))
        .withColumn("high", col("high").cast(DecimalType(10, 4)))
        .withColumn("low", col("low").cast(DecimalType(10, 4)))
        .withColumn("close", col("close").cast(DecimalType(10, 4)))
        .withColumn("volume", col("volume").cast("long"))
        .filter(col("close").isNotNull())
        .filter(col("trade_date").isNotNull())
    )
