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



Question 2: Does the US alone account for more sales than all other countries combined? (IDEA)

SQL Queries:

```sql
WITH revenue_data AS (

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
		an.units_sold * ROUND(CAST(an.unit_price AS DECIMAL)/1000000, 2) AS revenue_clean
FROM all_sessions AS alls
FULL OUTER JOIN analytics AS an
ON alls.visitid = an.visitid
WHERE ROUND(CAST(an.unit_price AS DECIMAL)/1000000, 2) IS NOT NULL AND an.visitid IS NOT NULL AND alls.visitid IS NOT NULL AND an.units_sold IS NOT NULL
)

SELECT	 	
			CASE WHEN country = 'United States' THEN country
			ELSE 'Non-US Country' END AS country_us,
			SUM(revenue_clean) AS total_rev
FROM 		revenue_data
GROUP BY 	country_us
ORDER BY 	total_rev DESC;

```

Answer:

* Yes, total US revenue is $41,682.54 and rest of world revenue combined is $3,887.09. US revenue is over 10 times greater than  rest of world revenue

Question 3: 

SQL Queries:

Answer:



Question 4: 

SQL Queries:

Answer:



Question 5: 

SQL Queries:

Answer:
