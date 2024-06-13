--- product category table
--- get all product sku's and product categories 
WITH cte AS (
SELECT 	p.sku AS prod_sku, 
		p.name AS prod_nam, 
		ses.productsku AS ses_sku, 
		ses.v2productname AS ses_name, 
		ses.v2productcategory
FROM all_sessions_clean AS ses
FULL OUTER JOIN products_clean AS p
ON TRIM(ses.productsku) = TRIM(p.sku)
-- WHERE ses.productsku IS NULL
WHERE p.sku IS NULL) 

INSERT INTO products_clean (sku, name, category_name)
SELECT DISTINCT ON (ses_sku, prod_sku) TRIM(BOTH ' ' FROM ses_sku), ses_name, v2productcategory
FROM cte


-- UNION and drop duplicates

SELECT 'all_sessions' AS source, productsku, v2productname
FROM all_sessions_clean
UNION ALL 
SELECT 'products_clean', sku, name 
FROM products_clean
ORDER BY productsku

--- ALL SESSIONS 