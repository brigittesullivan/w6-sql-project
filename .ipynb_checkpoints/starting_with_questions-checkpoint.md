Answer the following questions and provide the SQL queries used to find the answer.

    
**Question 1: Which cities and countries have the highest level of transaction revenues on the site?**


SQL Queries:

```sql
-- Assumptions: 
	-- used unit_price from analytics since there was more complete data, productquantity has 369 values whereas units sold has 502. Going with units_sold more complete data. 
	-- assumed all currency in USD (even missing null values, 26 missing currency codes out of 502)

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
		ROUND(CAST(alls.productprice AS DECIMAL)/1000000, 2) - ROUND(CAST(an.unit_price AS DECIMAL)/1000000, 2) AS price_variance, 
		an.units_sold * ROUND(CAST(an.unit_price AS DECIMAL)/1000000, 2) AS revenue_clean
FROM all_sessions AS alls
FULL OUTER JOIN analytics AS an
ON alls.visitid = an.visitid
WHERE ROUND(CAST(an.unit_price AS DECIMAL)/1000000, 2) IS NOT NULL AND an.visitid IS NOT NULL AND alls.visitid IS NOT NULL AND an.units_sold IS NOT NULL
)

SELECT country, city, SUM(revenue_clean) AS total_rev
FROM revenue_data
GROUP BY country, city
ORDER BY total_rev DESC;
```


Answer:

* Top 3 highest revenue cities are: 
  1. New York USA, $11 378.77
  2. n/a, USA, $9 288.27
  3. Sunnyvale, USA, $6 787.81


**Question 2: What is the average number of products ordered from visitors in each city and country?**

* Assumption: used calculation from question 1 as starting point and changed aggregation to average instead of sum.
SQL Queries:
```sql
SELECT 	
		alls.country, 
		alls.city, 
		ROUND(AVG(an.units_sold * ROUND(CAST(an.unit_price AS DECIMAL)/1000000, 2)),2) AS avg_products
FROM all_sessions AS alls
FULL OUTER JOIN analytics AS an
ON alls.visitid = an.visitid
WHERE ROUND(CAST(an.unit_price AS DECIMAL)/1000000, 2) IS NOT NULL AND an.visitid IS NOT NULL AND alls.visitid IS NOT NULL AND an.units_sold IS NOT NULL
GROUP BY alls.country, alls.city
ORDER BY avg_products DESC
```


Answer:

* Top 3 highest average number of products ordered:
    1. Chicago, USA - 5
    2. Pittsburgh, USA - 4
    3. New York, USA - 3.83
* Observation - since Chicago and Pittsburgh have intergers as averages, it is suspicious that this is truly an average and could just be large single orders. Additional QA needed to determine if this is a single order with high amount of products ordered.  


**Question 3: Is there any pattern in the types (product categories) of products ordered from visitors in each city and country?**
Assumption: 
* Had to trim the product category to have meaningful data to analyze. Only took top 2 levels of product categories E.g., Home/Apparel/Women's/Women's-Outerwear/ became Home/Apparel. Otherwise product categories are too narrow. 
* Duplicates indicate there was the Same number of products ordered for each category and as result received the same rank. 

SQL Queries:

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


SELECT country, city, top_cat
FROM top_cat_city
WHERE city_rank = 1
```

Query 2: What is most popular product category by country? 

```sql
WITH popular_categories_country AS (
SELECT 	
					alls.country, 
					regexp_replace(alls.v2productcategory, '^([^/]*/[^/]*)/.*$', '\1') AS top_cat,	
					SUM(an.units_sold) AS items_count, 
					DENSE_RANK () OVER (PARTITION BY alls.country ORDER BY SUM(an.units_sold) DESC) AS country_rank
FROM 				all_sessions AS alls
FULL OUTER JOIN 	analytics AS an
ON 					alls.visitid = an.visitid
WHERE 			 	ROUND(CAST(an.unit_price AS DECIMAL)/1000000, 2) IS NOT NULL 
					AND an.visitid IS NOT NULL 
					AND alls.visitid IS NOT NULL 
					AND an.units_sold IS NOT NULL
GROUP BY 			alls.country,regexp_replace(alls.v2productcategory, '^([^/]*/[^/]*)/.*$', '\1')
ORDER BY 			alls.country
)

SELECT country, top_cat
FROM popular_categories_country
WHERE country_rank = 1
```
Query 3: Which category was ranked most popular accross all cities ? 

Answer:

* Query 1: Which product category had the most products ordered by city and country? 
    * The home category is the most common top category accross all cities and countries  
    * home/apparel is most popular wihtin cities that have home as a top category. 
    * Most popular product category in New York USA is Home/Bags.  
    * Paris France, Dublin Ireland, Tel-Aviv, Chicago, Dallas are cities where 'Home/Shop by Brand' was most popular category.
* Query 2: What is most popular product category by country? 
    * New York has influenced the countries most popular category to be "Home/Bags" where it was the only top category in any US city. 
    * Missing product category data for Taiwan, Romania, Signapore, Sweden. The most items are purchased within this category for the countries but we are missing the data. Data quality issue to be resolved as soon as possible. 
* Query 3:  Of all the top ranked category in each city, which ones appeared the most often?  Category was ranked most popular accross all cities and worldwide ? 
    * Home/Apparel is the category that saw the highest product unit sales in 18 cities worldwide. 
    * Next is Home/Shop by Brand in 8 cities. 



**Question 4: What is the top-selling product from each city/country? Can we find any pattern worthy of noting in the products sold?**


SQL Queries:

-- **Question 4: What is the top-selling product from each city/country? 
-- Can we find any pattern worthy of noting in the products sold?**

```sql 
-- NOTE - if there was a tie based on total products sold, both items are listed. Three queries are listed. 

-- 1. Top Product by country and city 
WITH city_rank AS (

	SELECT 				 
						alls.country, 
						alls.city,
						alls.v2productname, 
						SUM(an.units_sold) AS total_sold,
						RANK() OVER(PARTITION BY alls.country, alls.city ORDER BY SUM(an.units_sold) DESC) AS sales_rank
	FROM 				all_sessions AS alls
	FULL OUTER JOIN 	analytics AS an
	ON 					alls.visitid = an.visitid
	WHERE 				alls.visitid IS NOT NULL
						AND alls.productsku IS NOT NULL
						AND an.units_sold IS NOT NULL
	GROUP BY			alls.country, alls.city, alls.v2productname
	ORDER BY 			alls.country, alls.city,total_sold DESC
),

-- SELECT 		country, city, v2productname AS top_product, total_sold
-- FROM 		city_rank 
-- WHERE 		sales_rank = 1


-- 2. Top Product by country only
 country_rank AS (

	SELECT 				 
						alls.country, 
						alls.v2productname, 
						SUM(an.units_sold) AS total_sold,
						RANK() OVER(PARTITION BY alls.country ORDER BY SUM(an.units_sold) DESC) AS sales_rank 
	FROM 				all_sessions AS alls
	FULL OUTER JOIN 	analytics AS an
	ON 					alls.visitid = an.visitid
	WHERE 				alls.visitid IS NOT NULL
						AND alls.productsku IS NOT NULL
						AND an.units_sold IS NOT NULL
	GROUP BY			alls.country,  alls.v2productname
	ORDER BY 			alls.country, total_sold DESC
)

SELECT 		country, v2productname AS top_product_country, total_sold
FROM 		country_rank 
WHERE 		sales_rank = 1


-- 3 BONUS (because I got curious) Compare the top product in each country with the city top products. Duplicates indicate ties in total products sold.
SELECT 		city.country,
			city.city, 
			country.v2productname AS top_product_country, 
			city.v2productname AS top_product_city,
			city.total_sold AS total_sold,
			city.sales_rank AS city_rank,
			country.sales_rank AS country_rank
FROM 		city_rank AS city
INNER JOIN 	country_rank AS country
ON 			city.country = country.country
WHERE 		city.sales_rank = 1 AND country.sales_rank = 1
ORDER BY 	city.country, city.city

```

Answer:

* US clearly has most product sales than any other country
* Other countries have a very low volume of sales. US sold 871/991 products (Need to show query? )  


**Question 5: Can we summarize the impact of revenue generated from each city/country?**
Assumptions: 
* impact = % of revenue, 
* sales data without associated cities and countries were removed from analysis. Found error when calculating total revenue (analytics was calc all rows evven if no country data). 
* interpretation: Impact means the percentage revenue generated by city and/or country

SQL Queries:
```sql
-- **Question 5: Can we summarize the impact of revenue generated from each city/country?**


WITH 
total_sales AS (
	SELECT alls.country, alls.city, alls.visitid,an.units_sold, an.unit_price, an.units_sold * an.unit_price AS sales 
	FROM analytics AS an
	FULL OUTER JOIN all_sessions AS alls
	ON an.visitid = alls.visitid
	WHERE an.units_sold IS NOT NULL AND alls.country IS NOT NULL ), 
	

percent_rev_cte AS (
	SELECT			alls.country, 
					alls.city, 
					SUM(an.units_sold * ROUND(CAST(an.unit_price AS DECIMAL)/1000000, 2)) AS total_revenue_clean, 
					(SELECT 
							SUM(sales) 
							FROM total_sales) / 1000000 AS total_rev,
					SUM(an.units_sold * ROUND(CAST(an.unit_price AS DECIMAL)/1000000, 2)) / (SELECT SUM(sales)/1000000  
																										FROM total_sales) * 100 
						AS percent_rev
	FROM 			all_sessions AS alls
	FULL OUTER JOIN analytics AS an
	ON 				alls.visitid = an.visitid
	WHERE 			ROUND(CAST(an.unit_price AS DECIMAL)/1000000, 2) IS NOT NULL 
						AND an.visitid IS NOT NULL 
						AND alls.visitid IS NOT NULL 
						AND an.units_sold IS NOT NULL
	GROUP BY 		alls.country, alls.city 
	ORDER BY 		percent_rev DESC
	) 




-- Query 1: highest revenue generating cities / countries
SELECT 		country, city, ROUND(percent_rev, 3) AS percent_rev
FROM 		percent_rev_cte
ORDER BY 	percent_rev DESC
;

-- Query 2: highest revenue generating countries
-- SELECT 		country, SUM(ROUND(percent_rev, 3))AS percent_rev
-- FROM 		percent_rev_cte
-- GROUP BY 	country
-- ORDER BY 	percent_rev DESC

```


Answer:

* 9 out of top 10 highest revenue cities are located in the US
* 91.469% of revenue is generated in the US
* Sunnvale and Mountain View USA make up 25% of revenue but are relatively unknown cities. ecommerce business is very popular in these cities. 
* 24.97% of revenue generated from New York (not surprising considering city size)









