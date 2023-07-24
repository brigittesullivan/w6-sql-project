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



Question 2: Does the US alone account for more sales than all other countries combined? 

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

Question 3: - find the total number of unique visitors (`fullVisitorID`) (fullvisitorid abbreviated to FVID)

SQL Queries:

Unique visitors in all_sessions table: 
```sql 
SELECT DISTINCT fullvisitorid
FROM all_sessions
```
Answer: 14223

Unique visitors in analytics table: 
```sql
SELECT DISTINCT fullvisitorid
FROM analytics
```
Answer: 120018

QA: Since there are different numbers of unique FVID in each table, indicates that more QA is necessary. 

```sql
WITH id_count AS (
SELECT 			DISTINCT an.fullvisitorid AS analytics_fullid, alls.fullvisitorid AS allsessions_fullid
FROM 			analytics AS AN
FULL OUTER JOIN all_sessions AS alls
ON 				CAST(an.fullvisitorid AS NUMERIC) = alls.fullvisitorid )
-- WHERE 			CAST(an.fullvisitorid AS NUMERIC) IN (7798640485060741361,2498836143351356423, 3608475193341679870)
-- 				OR alls.fullvisitorid IN (7798640485060741361,2498836143351356423, 3608475193341679870)

SELECT 	*
FROM 	id_count
WHERE 	allsessions_fullid IS NULL 
		OR 
		analytics_fullid IS NULL 
```
QA Answer: 
* Issue: too many FVID's do not appear in both analytics and all_sessions. 
* Only  3% (3 896) of all unique FVID appear in both tables. 
* 130 345 total unique FVID's found accross both tables.
* 126 449 FVID's don't appear in both tables (appearing in one but not the other). 
* 116 122 unique fullvisitorid's from **analytics** table are not found in **all_sessions** table - 92% of unique FVID's
* 10 327 unique fullvisitorid's from **all_sessions** table are not found in **analytics** table - 8% of unique FVID's

Question 4: 

SQL Queries:

Answer:



Question 5: 

SQL Queries:

Answer:
