from pyspark import pipelines as dp
from pyspark.sql import Row
from utilities import utils

SYMBOLS = ["IBM", "AAPL", "MSFT", "GOOGL"]

def fetch_all_symbols():
    api_key = dbutils.secrets.get("dlt-scope", "rapidapi-key")
    rows = []
    for symbol in SYMBOLS:
        try:
            series = utils.fetch_daily_series(symbol, api_key)
            for date_str, values in series.items():
                rows.append({
                    "symbol": symbol,
                    "trade_date": date_str,
                    "open": float(values["1. open"]),
                    "high": float(values["2. high"]),
                    "low": float(values["3. low"]),
                    "close": float(values["4. close"]),
                    "volume": int(values["5. volume"])
                })
        except Exception as e:
            print(f"Failed to fetch {symbol}: {e}")
    import pandas as pd
    return pd.DataFrame(rows)

@dp.table(
    name="bronze_stock_prices",
    comment="Raw daily stock prices ingested from Alpha Vantage API via RapidAPI"
)
def bronze_stock_prices():
    pdf = fetch_all_symbols()
    return spark.createDataFrame(pdf)
