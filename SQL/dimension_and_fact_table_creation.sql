CREATE TABLE analytics.dim_invoice(
    invoice_key INTEGER PRIMARY KEY,
    invoiceno TEXT
);

INSERT INTO analytics.dim_invoice
SELECT 
    ROW_NUMBER() OVER(ORDER BY invoiceno)::INTEGER AS invoice_key,
    invoiceno
FROM staging.stg_lanternwick_and_co
WHERE invoiceno IS NOT NULL
GROUP BY invoiceno;

--dim_stock
CREATE TABLE analytics.dim_stock(
    stock_key INTEGER PRIMARY KEY,
    stockcode TEXT
);

INSERT INTO analytics.dim_stock
SELECT
    ROW_NUMBER() OVER(ORDER BY stockcode)::INTEGER AS stock_key,
    stockcode
FROM staging.stg_lanternwick_and_co
WHERE stockcode IS NOT NULL
GROUP BY stockcode;

--dim_country
CREATE TABLE analytics.dim_country(
    country_key INTEGER PRIMARY KEY,
    country TEXT
);

INSERT INTO analytics.dim_country
SELECT
    ROW_NUMBER() OVER(ORDER BY country)::INTEGER AS country_key,
    country
FROM staging.stg_lanternwick_and_co
WHERE country IS NOT NULL
GROUP BY country;

--dim_date
CREATE TABLE analytics.dim_date(
    date_key INTEGER PRIMARY KEY,
    full_date DATE NOT NULL,
    year INTEGER,
    month INTEGER,
    quarter INTEGER,
    month_name VARCHAR(20)
);
INSERT INTO analytics.dim_date
SELECT DISTINCT
    TO_CHAR(invoicedate, 'YYYYMMDD')::INTEGER AS date_key,
    invoicedate AS full_date,
    EXTRACT(YEAR FROM invoicedate)::INTEGER AS year,
    EXTRACT(MONTH FROM invoicedate)::INTEGER AS month,
    EXTRACT(QUARTER FROM invoicedate)::INTEGER AS quarter,
    TRIM(TO_CHAR(invoicedate, 'Month')) AS month_name
FROM staging.stg_lanternwick_and_co
WHERE invoicedate IS NOT NULL;

--dim_customer
CREATE TABLE analytics.dim_customer(
    customer_key INTEGER PRIMARY KEY,
    customerid TEXT
);

INSERT INTO analytics.dim_customer
SELECT 
    ROW_NUMBER() OVER(ORDER BY customerid)::INTEGER AS customer_key,
    customerid
FROM staging.stg_lanternwick_and_co
WHERE customerid IS NOT NULL
GROUP BY customerid;

--fact_lanternwick_and_co
CREATE TABLE analytics.fact_lanternwick_and_co(
    fact_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    invoice_key INTEGER REFERENCES analytics.dim_invoice(invoice_key),
    stock_key INTEGER REFERENCES analytics.dim_stock(stock_key),
	description TEXT,
    quantity NUMERIC,
    date_key INTEGER REFERENCES analytics.dim_date(date_key),
    unitprice NUMERIC,
    customer_key INTEGER REFERENCES analytics.dim_customer(customer_key),
	country_key INTEGER REFERENCES analytics.dim_country(country_key),
    linetotal NUMERIC
);

INSERT INTO analytics.fact_lanternwick_and_co (
    invoice_key,
    stock_key,
	description,
    quantity,
    date_key,
    unitprice,
    customer_key,
	country_key,
    linetotal
)
SELECT
    i.invoice_key,
    s.stock_key,
	l.description,
    l.quantity,
    d.date_key,
    l.unitprice,
    c.customer_key,
	co.country_key,
    l.linetotal
FROM staging.stg_lanternwick_and_co l
LEFT JOIN analytics.dim_invoice i
    ON l.invoiceno = i.invoiceno
LEFT JOIN analytics.dim_stock s
    ON l.stockcode = s.stockcode
LEFT JOIN analytics.dim_customer c
    ON l.customerid = c.customerid
LEFT JOIN analytics.dim_date d
    ON l.invoicedate = d.full_date
LEFT JOIN analytics.dim_country co
    ON l.country = co.country;