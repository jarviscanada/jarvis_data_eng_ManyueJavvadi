from pyspark import pipelines as dp
from pyspark.sql.functions import col, lag, round, avg
from pyspark.sql.window import Window

@dp.table(
    name="gold_price_trends",
    comment="Daily price change and percentage change over 7, 30, 90 days"
)
def gold_price_trends():
    silver = spark.read.table("silver_stock_prices")
    w = Window.partitionBy("symbol").orderBy("trade_date")

    return (
        silver
        .withColumn("prev_7d_close", lag("close", 7).over(w))
        .withColumn("prev_30d_close", lag("close", 30).over(w))
        .withColumn("prev_90d_close", lag("close", 90).over(w))
        .withColumn("price_change_7d", round(col("close") - col("prev_7d_close"), 4))
        .withColumn("price_change_30d", round(col("close") - col("prev_30d_close"), 4))
        .withColumn("price_change_90d", round(col("close") - col("prev_90d_close"), 4))
        .withColumn("pct_change_7d", round((col("price_change_7d") / col("prev_7d_close")) * 100, 2))
        .withColumn("pct_change_30d", round((col("price_change_30d") / col("prev_30d_close")) * 100, 2))
        .withColumn("pct_change_90d", round((col("price_change_90d") / col("prev_90d_close")) * 100, 2))
        .drop("prev_7d_close", "prev_30d_close", "prev_90d_close")
    )

@dp.table(
    name="gold_volume_trends",
    comment="Rolling average volume over 7, 30, 90 day windows"
)
def gold_volume_trends():
    silver = spark.read.table("silver_stock_prices")
    w = Window.partitionBy("symbol").orderBy("trade_date")

    return (
        silver
        .select("symbol", "trade_date", "volume")
        .withColumn("avg_volume_7d", round(avg("volume").over(w.rowsBetween(-6, 0)), 0))
        .withColumn("avg_volume_30d", round(avg("volume").over(w.rowsBetween(-29, 0)), 0))
        .withColumn("avg_volume_90d", round(avg("volume").over(w.rowsBetween(-89, 0)), 0))
    )
