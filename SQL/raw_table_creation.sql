CREATE TABLE raw.lanternwick_and_co(
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