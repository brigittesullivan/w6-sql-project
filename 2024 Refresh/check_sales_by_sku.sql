-- Can sales by sku be deleted? Does it contain any unique information? 
WITH temp_sales AS (
	SELECT productsku, SUM(total_ordered) AS total_sales
	FROM sales_report_clean
	GROUP BY productsku
	ORDER BY total_sales DESC
	)
SELECT tmp.productsku, tmp.total_sales, s.*
FROM temp_sales as tmp
FULL OUTER JOIN sales_by_sku AS s
ON tmp.productsku = s.productsku

-- RESPONSE : CAN DELETE sales by SKU TABL. it is all duplicated and can be found in sales report

-- SELECT * 
-- FROM sales_by_sku_clean


