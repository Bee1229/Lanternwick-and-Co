--View for Row Types (customer return, damaged, non-product charge, lost, others and sale)
CREATE VIEW analytics.row_types AS 
  SELECT f.*, s.stockcode, c.customerid, i.invoiceno,
    CASE
      WHEN i.invoiceno::text LIKE 'C%'
        THEN 'Customer return'
      WHEN s.stockcode IN ('POST','DOT','M','C2','D','S','BANK CHARGES','AMAZONFEE','CRUK','B','PADS')
        OR s.stockcode LIKE 'gift_%'
        THEN 'Non-product charge'
      WHEN f.unitprice = 0 AND c.customerid = 'None' 
        AND f.description::text ~* 'damag|wet|smash|crush|broken|mould|mold|unsale|destroy|thrown|missing|defect'
        THEN 'Damaged/written off'
      WHEN f.unitprice = 0 AND c.customerid = 'None'
        AND f.description::TEXT ~* 'missing|lost|found|check|mix|wrong|count|[?]'
        THEN 'Lost/unexplained'
      WHEN f.unitprice = 0 AND c.customerid = 'None'
        THEN 'Other stock adjustment'
      WHEN f.unitprice > 0
        THEN 'Sale'
      ELSE 'Review'
    END AS row_type
  FROM analytics.fact_lanternwick_and_co f
  LEFT JOIN analytics.dim_invoice  i ON f.invoice_key  = i.invoice_key
  LEFT JOIN analytics.dim_stock    s ON f.stock_key    = s.stock_key
  LEFT JOIN analytics.dim_customer c ON f.customer_key = c.customer_key;