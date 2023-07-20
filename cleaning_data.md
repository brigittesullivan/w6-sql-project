What issues will you address by cleaning the data?

* Unit Cost divide by 1 million
* timestamp - need to convert
* check for nulls columns/rows 
* check for duplicates - analytics table
* chance data type: 
    * units sold analytics 
* keep top 2 levels for product categories - name for this? 

-- Time Permitting: 
	-- will consolidate all queries and create a new table with cleaned data 
	-- make column names consistent format (v2productcategory > productcategory), all snake case accross all tables
	-- update time values to a timestamp instead of int
	-- 
Queries:
Below, provide the SQL queries you used to clean your data.

Query 1: make null-ish values true NULLS for country and city in all_sessions

```sql

-- Review all unique values for country to identity which ones must be cleaned
SELECT		DISTINCT country
FROM 		all_sessions
-- Resut: found one nullish value "(not set)"

-- clean null-ish values for country in all_sessions
SELECT 		country,
			CASE WHEN country = '(not set)' THEN NULL
				ELSE country
				END AS country_clean
FROM 		all_sessions

-- Review all unique values for city to identity which ones must be cleaned
SELECT		DISTINCT city
FROM 		all_sessions

-- Resut: found two nullish values "(not set)" and "not available in demo dataset"
-- clean null-ish values for city in all_sessions
SELECT		city,
			CASE WHEN city = 'not available in demo dataset' THEN NULL
				WHEN city = '(not set)' THEN NULL
				ELSE city
				END AS city_clean
FROM 		all_sessions

```

Query 2: convert all price data to dollars in all_sessions and analytics

```sql
-- product price 
SELECT productprice, ROUND(CAST(productprice AS NUMERIC) / 1000000, 2) AS productprice_clean
FROM all_sessions

-- unit_price 
SELECT unit_price, ROUND(CAST(unit_price AS NUMERIC) / 1000000, 2) AS unitprice_clean
FROM analytics
```

Query 3: Make date data a date data type, to simplify loading process, many columns were loaded with type VARCHAR

```sql
SELECT 	date, 
		CAST(CAST(date AS varchar(8)) AS DATE) AS date_clean
FROM 	all_sessions
```

Query 4: Check for duplicates in all_sessions. 
-- check for duplicates in all sessions and resolve if applicable. None found. 
-- Query result shows no fully duplicate records (where value is same for each column of one record). 
-- Time permitting would first normalize DB then check for duplicates again. 
```sql

SELECT 	fullVisitorId, 
    channelGrouping, 
    time,
    country, 
    city, 
    totalTransactionRevenue, 
    transactions, 
    timeOnSite, 
    pageviews	, 
    sessionQualityDim, 
    date	, 
    visitId, 
    type, 
    productRefundAmount, 
    productQuantity, 
    productPrice, 
    productRevenue, 
    productSKU, 
    v2ProductName, 
    v2ProductCategory,
    productVariant, 
    currencyCode, 
    itemQuantity, 
    itemRevenue, 
    transactionRevenue,
    transactionId, 
    pageTitle, 
    searchKeyword, 
    pagePathLevel1,
    eCommerceAction_type,
    eCommerceAction_step,
    eCommerceAction_option	, count(*)
FROM 	all_sessions
GROUP BY   
	fullVisitorId, 
    channelGrouping, 
    time,
    country, 
    city, 
    totalTransactionRevenue, 
    transactions, 
    timeOnSite, 
    pageviews	, 
    sessionQualityDim, 
    date	, 
    visitId, 
    type, 
    productRefundAmount, 
    productQuantity, 
    productPrice, 
    productRevenue, 
    productSKU, 
    v2ProductName, 
    v2ProductCategory,
    productVariant, 
    currencyCode, 
    itemQuantity, 
    itemRevenue, 
    transactionRevenue,
    transactionId, 
    pageTitle, 
    searchKeyword, 
    pagePathLevel1,
    eCommerceAction_type,
    eCommerceAction_step,
    eCommerceAction_option
HAVING COUNT(*) > 1
```

Query 4: Product Category Grouping. During analysis of starting with questions found that the product category data was too granular, and wanted to find patterns at a higher level grouping for product categories.  

```sql
--- make a top category to group categories at a higher level. 

SELECT 		v2ProductCategory,	regexp_replace(v2productcategory, '^([^/]*/[^/]*)/.*$', '\1') AS category_group,	 count(*)
FROM 		all_sessions
WHERE 		country IS NOT NULL AND city IS NOT NULL
GROUP BY 	v2ProductCategory, category_group

```