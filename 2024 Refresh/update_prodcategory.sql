-- check that product table was updated with sku's from all sessions
WITH cte_sku_no_category AS (
SELECT sku
FROM products_clean
WHERE category_name IS NULL )

UPDATE 
SELECT productsku, v2productcategory
FROM all_sessions_clean
WHERE productsku IN (
		SELECT *
		FROM cte_sku_no_category)


UPDATE products_clean p
SET category_name = (
    SELECT DISTINCT a.v2productcategory
    FROM all_sessions a
    WHERE a.productsku = p.sku
    LIMIT 1
)
WHERE category_name IS NULL
-- AND EXISTS (
--     SELECT 1
--     FROM all_sessions a
--     WHERE a.product_sku = p.sku
-- );

-- QA: checked that SKU only appears once in table (returns no rows)
SELECT name, sku, count(sku)
FROM products_clean
GROUP BY name, sku
HAVING COUNT(sku) > 1
ORDER BY sku
