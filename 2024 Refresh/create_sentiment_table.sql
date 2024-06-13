-- creating sentiment table 
WITH sent_table AS 
	(
	SELECT DISTINCT sku, sentimentscore, sentimentmagnitude
	FROM products_clean

	UNION ALL 
	SELECT DISTINCT productsku, sentimentscore, sentimentmagnitude
	FROM sales_report
	ORDER BY sku
		), 

sent_result AS 
( SELECT DISTINCT * 
FROM sent_table
ORDER BY sku )

INSERT INTO sentiment (sku, sentimentscore, sentimentscoremag)
SELECT sku, sentimentscore, sentimentmagnitude
FROM sent_result; 

-- SELECT * 
-- FROM sent_result