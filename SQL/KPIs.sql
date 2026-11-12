--Total Revenue
SELECT d.month AS number,
       d.month_name AS month,
       SUM(r.linetotal) FILTER (WHERE d.year = 2010) AS revenue_2010,
       SUM(r.linetotal) FILTER (WHERE d.year = 2011) AS revenue_2011
FROM analytics.row_types r
LEFT JOIN analytics.dim_date d ON r.date_key = d.date_key
WHERE r.row_type = 'Sale'
GROUP BY d.month, d.month_name
ORDER BY d.month;

--Number of products that are below zero
SELECT COUNT(customer_key) AS products_below_zero_quantity
FROM analytics.fact_lanternwick_and_co
WHERE quantity < 0;

--Net Revenue
SELECT d.year,
       d.month AS number,
       d.month_name AS month,
       SUM(f.linetotal) FILTER (WHERE f.row_type = 'Sale')            AS gross_sales,
       SUM(f.linetotal) FILTER (WHERE f.row_type = 'Customer return') AS returns_value,
       SUM(f.linetotal) FILTER (WHERE f.row_type IN ('Sale','Customer return')) AS net_revenue
FROM analytics.row_types f
LEFT JOIN analytics.dim_date d ON f.date_key = d.date_key
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;

--Number of Orders
SELECT d.month_name,
        COUNT(DISTINCT(i.invoiceno)) FILTER(WHERE d.year = 2010) AS number_of_invoice_2010,
        COUNT(DISTINCT(i.invoiceno)) FILTER(WHERE d.year = 2011) AS number_of_invoice_2011
FROM analytics.dim_invoice i
LEFT JOIN analytics.fact_lanternwick_and_co f
ON f.invoice_key = i.invoice_key
LEFT JOIN analytics.dim_date d
ON f.date_key = d.date_key
GROUP BY d.month, d.month_name
ORDER BY d.month;

--Average Order Value
SELECT d.year,
       d.month AS number,
       d.month_name AS month,
       SUM(r.linetotal) AS revenue,
       COUNT(DISTINCT i.invoiceno) AS orders,
       ROUND(SUM(r.linetotal) / NULLIF(COUNT(DISTINCT i.invoiceno), 0), 2) AS avg_order_value
FROM analytics.row_types r
LEFT JOIN analytics.dim_date d ON r.date_key = d.date_key
LEFT JOIN analytics.dim_invoice i
ON r.invoice_key = i.invoice_key
WHERE r.row_type = 'Sale'
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;

--Units Sold
SELECT 
       d.month AS number,
       d.month_name AS month,
       SUM(r.quantity) FILTER(WHERE d.year = 2010) AS units_sold_2010,
       SUM(r.quantity) FILTER(WHERE d.year = 2011) AS units_sold_2011
FROM analytics.row_types r
LEFT JOIN analytics.dim_date d ON r.date_key = d.date_key
WHERE r.row_type = 'Sale'
GROUP BY d.month, d.month_name
ORDER BY d.month;


--Month-over-Month Revenue Growth %
WITH monthly_rev  AS 
(SELECT d.year,
       d.month AS number,
       d.month_name AS month,
       SUM(r.linetotal) AS revenue
FROM analytics.row_types r
LEFT JOIN analytics.dim_date d ON r.date_key = d.date_key
WHERE r.row_type = 'Sale'
GROUP BY d.year, d.month, d.month_name)

SELECT year, number, month,
        revenue,
        LAG(revenue) OVER (PARTITION BY year ORDER BY year, number) AS prev_month_revenue,
        ROUND((revenue - LAG(revenue) OVER(PARTITION BY year ORDER BY year,  number))
        / NULLIF(LAG(revenue) OVER(PARTITION BY year ORDER BY year,  number), 0), 2) AS month_to_month_rev_growth
FROM monthly_rev
ORDER BY year, number;

