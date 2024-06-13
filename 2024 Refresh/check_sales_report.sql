-- PRODUCTS and SALES REPORT - can sales report be deleted? 

SELECT 'sales_report' AS source, productsku, TRIM(name), total_ordered, stocklevel, restockingleadtime
FROM sales_report_clean
UNION ALL 
SELECT 'products_table' AS source, sku, TRIM(name), orderedquantity, stocklevel, restockingleadtime
FROM products_clean
ORDER BY productsku

-- JOIN 
SELECT 
	p.sku AS prod_sku, s.productsku AS sales_sku, 
	p.name,
	p.orderedquantity, s.total_ordered, 
	p.stocklevel,
	p.restockingleadtime
FROM products_clean AS p
FULL OUTER JOIN sales_report_clean AS s
ON p.sku = s.productsku

-- DECISION: sales report clean doesn't have any information that isn't in products table. 
-- Sales - total ordered, slight variation, but will assume this is a timing issue. 

-- Can sales by sku be deleted? Does it contain any unique information? 
-- WITH temp_sales AS (
-- 	SELECT productsku, SUM(total_ordered) AS total_sales
-- 	FROM sales_report_clean
-- 	GROUP BY productsku
-- 	ORDER BY total_sales DESC
-- 	)
-- SELECT tmp.productsku, tmp.total_sales, s.*
-- FROM temp_sales as tmp
-- FULL OUTER JOIN sales_by_sku AS s
-- ON tmp.productsku = s.productsku