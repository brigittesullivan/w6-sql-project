# Final Project Transforming and Analyzing Data with SQL </br>
By : Brigitte Sullivan <br>
Submitted on: July 24th, 2023 <br>
Lighthouse Labs Data Science Program <br>


## Project Goal:
Load data into pgadmin, clean the data sufficiently to be able to draw insights and perform analysis on data. 

## Process 
1. Complete high priority data cleaning tasks items. 
2. Review insights (time permitting)

### Assumptions
- unit cost (analytics) and product price (all_sessions) have the same meaning, but used unit cost (analytics) since data was more complete to calculate revenue. Ignored all columns with revenue in column name.  
- columns with the same name have same meaning/value 
- visitid is the most unique identifier that can be used to join analytics and all_sessions

1. Load the 5 e-commerce csv data files into pgadmin successfully, using broad data types initially and converting data types where loading was blocked. Used online converter to take csv file and generate create table queries to avoid manually typing all column names and have seeded column data types. Where errors were returned, adjusted the data type accordingly so that the data would load completely and successfully. 

2.  Explore and attempt starting with questions answers. As I answered the questions, I noted areas that needed to be cleaned. If I needed to clean right away (e.g., unitprice), I performed the cleaning within the query for the starting with questions.
    * Attempt to gain initial insights from the data set 
    * identify highest priority cleaning tasks. Priority determined based on cleaning tasks that blocked analysis (e.g., data type conflict, unit cost)
    * QA each insight to ensure accuracy.
 
3. Write cleaning queries  
4. Add cleaned data/table into a 'clean' table (not enough time). If I had enough time, these would be the steps taken to create a 'clean table'
    * Steps to create a clean table: 
        * I would have combined the queries from the cleaning data file into a single query, 
        * write a Common Table expression to confirm I had the correct the result, 
        * then embed the query into a create table function and name the table using the format **<table_name>_clean** to distinguish between the raw data and the cleaned data. No source data would be deleted, or modified. 
        * **<table_name>_clean** would only have one version of each column (e.g., if Unit price column was cleaned, there would only be one column showing the 'clean' unit price.  
4. Document steps taken to do QA. QA is something out of habit that I as I build every query, and not a process I complete at the end. 

## Results
* Should focus streamline efforts on the USA market. Most revenue from this area with New York generating 25% of total revenue and Sunnyvale and Mountain view generating the other 25%. 

* Missing data for the 2nd highest revenue generating city(or cities). Highlights that data quality / QA is a key issue with this data.Unable to captialize on second highest revenue generating city due to data quality issue. 


## Challenges 

* difficult to get a sense of the data, still unclear what is a "visitor". When doing QA found a data integrity issue. 
* Data Quality - 
    * no clear primary keys 
    * data not normalized
* when attempting to answer Question 3: - find the total number of unique visitors (`fullVisitorID`) from starting with data, found that there is no commonality between all_sessions and analytics tables. eg., only 3% of fullvisitor ID's are found in both tables. Similar issue also arose when analyzing visitorid between all_sessions and analytics. 

## Future Goals

* Note: Get better business context before implementing any of the suggestions before to confirm they are appropriate

### Data quality:
* Normalize the data, and perform a complete re-organization of the database. For example:
    * each table has a clear easily identifiable and intuitive purpose, each having unique primirary key where required, and foreign keys to link to other tables
    * clear consistent definition to identify a 'visitor', and tracking each unique site visit that visitor has made. If an order is placed, a orderid is created and a customer ID is also created to efficiently track purchases/orders
    * create dashboards for reports rather than having duplicate data (e.g., sales report table - is it really necessary?)
    * clear source of truth for website traffic data, purchases/orders, inventory/products, refunds, with relationships to other tables where necessary. One column represents one piece of information.  
        * Example 1: : Information related to revenue can be found in 10 different columns over 2 tables, revenue information should only be located in purchase/orders table. Impossible to know which column is correct.
        * Example 2: The "purchases" table could have visitid info as FK joined from other tables, fullvisitorid and customerid as FK joined from customers table.
    * remove unecessary columns with no data 
* Implement data quality guardrails 
    * currency is a required field, automatically generated based on IP location
    * identify columns that are "NON NULL" for tables, prevent users from inputting "(not set)" as a city or country, especially when tracking order data. 
    
### QA:
* From Starting with Questions #2, Chicago and Pittsburgh have intergers as average number of products per order. It is suspicious that this is truly an average and could just be large single orders. Additional QA needed to determine if this is a single order with high amount of products ordered creating a whole number average or if it is coincidence that the average happens to be a whole number. If it is a single order with unusually large number of products ordered, should these data points be considered outliers and be removed from analysis? Check standard deviation distance from mean or IQR 

### Cleaning: 
* create clean table versions for each table

### Analysis: 
* Is it profitable to operate and ship to so many countries considering all costs of doing business ? 
