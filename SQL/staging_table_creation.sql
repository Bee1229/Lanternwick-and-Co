CREATE TABLE staging.stg_lanternwick_and_co(
    invoiceno TEXT NOT NULL,
    stockcode TEXT NOT NULL,
    description TEXT,
    quantity INTEGER,
    invoicedate DATE,
    unitprice NUMERIC,
    customerid TEXT,
    country TEXT,
    linetotal NUMERIC
);

INSERT INTO staging.stg_lanternwick_and_co
SELECT
    invoiceno,
    stockcode,
    description,
    quantity,
    invoicedate::DATE,
    unitprice,
    TRIM(TRAILING '.0' FROM customerid),
    country,
    ROUND(linetotal,2)
FROM raw.lanternwick_and_co;