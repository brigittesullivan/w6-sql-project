-- SELECT *
-- FROM all_sessions

-- Check for productsku in sales_by_sku that do not exist in products
-- SELECT productsku
-- FROM sales_by_sku_clean
-- WHERE productsku NOT IN (SELECT sku FROM products);

-- create copies of tables:
-- CREATE TABLE inventory_clean AS TABLE products
-- CREATE TABLE sales_by_sku_clean AS TABLE sales_by_sku;
-- CREATE TABLE sales_report_clean AS TABLE sales_report;
-- CREATE TABLE all_sessions_clean AS TABLE all_sessions
-- -- CREATE TABLE products_clean AS TABLE products
-- SELECT *
-- FROM sales_by_sku_clean

-- Check for productsku in sales_by_sku that do not exist in products
-- add rows where product sku not in product table but in sales by SKU (to check if I can get data from other tables)


-- INSERT INTO products_clean(sku)
-- SELECT productsku
-- FROM(
-- 	SELECT productsku
-- 	FROM sales_by_sku_clean
-- 	WHERE productsku NOT IN (SELECT sku FROM products_clean)
-- ) as subq;

-- SELECT * FROM products_clean
-- WHERE name IS NULL
-- -- remove whitespace from SKU and name 

-- UPDATE products_clean
-- SET sku = TRIM(sku);

-- UPDATE products_clean
-- SET name = TRIM(name);

-- UPDATE all_sessions_clean
-- SET productsku = TRIM(productsku);
-- UPDATE all_sessions_clean
-- SET v2productname = TRIM(v2productname);

-- UPDATE all_sessions_clean
-- SET productsku = TRIM(BOTH ' ' FROM v2productname);

-- remove 'google', 'android', youtube from product name
-- list of products with two product SKU's 
WITH unique_prods AS (
	SELECT DISTINCT ON (v2productname, productsku)
		v2productname, productsku 
	FROM all_sessions_clean
	ORDER BY v2productname ),

 multi_skus AS (
SELECT v2productname, count(v2productname)
FROM unique_prods
GROUP BY v2productname
HAVING count(v2productname) > 1)

SELECT mult.*, alls.productsku, alls.v2productname, alls.v2productcategory, 
	CASE WHEN
	alls.productsku
FROM multi_skus as mult
JOIN all_sessions_clean as alls 
ON mult.v2productname = alls.v2productname
ORDER BY alls.v2productname

