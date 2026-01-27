-- Show table schema
\d+ retail;

-- Show first 10 rows
SELECT *
FROM retail
LIMIT 10;

-- Check # of records
SELECT COUNT(*)
FROM retail;

-- Number of clients (unique customer_id)
SELECT COUNT(DISTINCT customer_id)
FROM retail;

-- Invoice date range
SELECT
  MAX(invoice_date) AS max,
  MIN(invoice_date) AS min
FROM retail;

-- Number of SKUs
SELECT COUNT(DISTINCT stock_code)
FROM retail;

-- Average invoice amount (exclude negative invoices)
SELECT AVG(invoice_total)
FROM (
  SELECT
    invoice_no,
    SUM(quantity * unit_price) AS invoice_total
  FROM retail
  GROUP BY invoice_no
  HAVING SUM(quantity * unit_price) > 0
) t;

-- Total revenue
SELECT SUM(quantity * unit_price)
FROM retail;

-- Total revenue by YYYYMM
SELECT
  (EXTRACT(YEAR FROM invoice_date)::int * 100 +
   EXTRACT(MONTH FROM invoice_date)::int) AS yyyymm,
  SUM(quantity * unit_price)
FROM retail
GROUP BY yyyymm
ORDER BY yyyymm;

