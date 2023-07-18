Question 1: What is the variance between product price (all_sessions) and unit price (analytics)

SQL Queries:
```sql
SELECT 	alls.fullvisitorid, 
		alls.country, 
		alls.city, 
		alls.visitid,
		alls.productquantity,
		ROUND(CAST(alls.productprice AS DECIMAL)/1000000, 2) AS product_price_clean,
		alls.productsku,
		alls.currencycode,
		an.units_sold,
		ROUND(CAST(an.unit_price AS DECIMAL)/1000000, 2) AS unit_price_clean,
		an.revenue, 
		ROUND(CAST(alls.productprice AS DECIMAL)/1000000, 2) - ROUND(CAST(an.unit_price AS DECIMAL)/1000000, 2) AS price_variance
FROM all_sessions AS alls
FULL OUTER JOIN analytics AS an
ON alls.visitid = an.visitid
-- WHERE an.units_sold IS NOT NULL AND alls.visitid IS NOT NULL AND alls.country IS NOT NULL
WHERE an.units_sold IS NOT NULL AND alls.country IS NOT NULL AND (ROUND(CAST(alls.productprice AS DECIMAL)/1000000, 2) - ROUND(CAST(an.unit_price AS DECIMAL)/1000000, 2) = 0)
```
Answer: 



Question 2: 

SQL Queries:

Answer:



Question 3: 

SQL Queries:

Answer:



Question 4: 

SQL Queries:

Answer:



Question 5: 

SQL Queries:

Answer:
