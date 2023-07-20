What are your risk areas? Identify and describe them.

* Unclear on data meaning, lacking business context. Many columns seem to mean the same thing, (e.g., Transactionrevenue, productrevenue, totaltransactionrevenue, revenue all are different columns and make reference to revenue). In the end, revenue in the analysis was manually calculated since none of the columns had complete or even accurate revenue data. 

* The data set has many quality issues and I have insufficient time to address all of them. As a result, data cleaning and QA was focused on removing blockers to completing the analysis.

QA Process:
Describe your QA process and include the SQL queries used to execute it.

* For every query, additional queries were created and run to verify the output is what is expected. This is a habit now. I also will write queries in a very iterative, modular way (usually starting with a SELECT * FROM table) and then gradually add to the query verifying the result is correct before moving on to adding another component to the query.
* when cleaning entire columns the original column would be included in the cleaning query to verify that the cleaning query executed as expected before loading clean data into a new table. 

e.g.: Resolving "nullish" cities in all sessions, the orignal city column was included. 
```sql
SELECT		city,
			CASE WHEN city = 'not available in demo dataset' THEN NULL
				WHEN city = '(not set)' THEN NULL
				ELSE city
				END AS city_clean
FROM 		all_sessions
```

e.g.: Resolving unit price issue unit/product price column was included. 
```sql
 -- convert prices to dollars all sessions
SELECT productprice, ROUND(CAST(productprice AS NUMERIC) / 1000000, 2) AS productprice_clean
FROM all_sessions

```

e.g., For **Question 3: Is there any pattern in the types (product categories) of products ordered from visitors in each city and country?**, I would always show the rank value to ensure that the window function was performing correctly, and that I also understood what I was looking for. In the final submission, I remove extraneous columns, however rank column remained throughout the building of the query. 

Query 1: Which product category had the most products ordered by city and country? 
```sql
WITH top_cat_city AS (

	SELECT 	
						alls.country, 
						alls.city,
						regexp_replace(alls.v2productcategory, '^([^/]*/[^/]*)/.*$', '\1') AS top_cat,	
						SUM(an.units_sold) AS items_count, 
						DENSE_RANK () OVER (PARTITION BY alls.country, alls.city ORDER BY SUM(an.units_sold) DESC) AS city_rank
	FROM 				all_sessions AS alls
	FULL OUTER JOIN 	analytics AS an
	ON 					alls.visitid = an.visitid
	WHERE 			 	ROUND(CAST(an.unit_price AS DECIMAL)/1000000, 2) IS NOT NULL 
						AND an.visitid IS NOT NULL 
						AND alls.visitid IS NOT NULL 
						AND an.units_sold IS NOT NULL
	GROUP BY 			alls.country, alls.city, regexp_replace(alls.v2productcategory, '^([^/]*/[^/]*)/.*$', '\1')
	ORDER BY 			alls.country, alls.city ) 


SELECT country, city, city_rank, top_cat
FROM top_cat_city
WHERE city_rank = 1