CREATE DATABASE IF NOT EXISTS Retail_Analytics;
USE Retail_Analytics;

SELECT * FROM sales_transactions;
SELECT * FROM customer_profiles;
SELECT * FROM product_inventory;

/* 
Write a query to identify the number of duplicates in sales_transaction. Also, create a separate table containing the unique values and 
remove the the original table from the databases and replace the name of the new table with the original name. 
*/
SELECT * FROM sales_transactions;
ALTER TABLE sales_transactions
CHANGE COLUMN `ï»¿TransactionID` `TransactionID` VARCHAR(255);

SELECT TransactionID,COUNT(*)
FROM sales_transactions
GROUP BY TransactionID
HAVING COUNT(*)>1;

CREATE TABLE sales_transactionsx
SELECT DISTINCT * FROM sales_transactions;

SELECT * FROM sales_transactionsx;
DROP TABLE sales_transactions;

ALTER TABLE sales_transactionsx
RENAME TO sales_transactions;

SELECT * FROM sales_transactions;

/*
Identify and fix incorrect prices in sales transactions

Write a query to identify the discrepancies in the price of the same product in “sales_transaction” and product_inventory.
Also, update those discrepancies to match the price in both the tables.
*/

SELECT *  FROM product_inventory;
SELECT * FROM sales_transactions;
ALTER TABLE product_inventory
CHANGE COLUMN `ï»¿ProductID` `ProductID`  VARCHAR(255);


SELECT p.ProductID,p.ProductName, p.Category,p.Price,s.Price
FROM product_inventory p 
JOIN sales_transactions s ON p.ProductID=s.ProductID
HAVING p.Price <> s.Price
ORDER BY p.ProductID ASC;
-- fix the discrepancies
SET SQL_SAFE_UPDATES =0;
UPDATE sales_transactions s
JOIN product_inventory p ON s.ProductID = p.ProductID
SET s.Price = p.Price
WHERE s.Price <> p.Price;

SELECT * FROM sales_transactions
WHERE ProductID=51;

/* To indetify the nulls in the dataset and then replace it by "Unknown"
Write a SQL query to identify the null values in the dataset and replace those by “Unknown”.
*/

ALTER TABLE customer_profiles
CHANGE COLUMN `ï»¿CustomerID` `CustomerID` VARCHAR(255);

SET SQL_SAFE_UPDATES =0;
SELECT COUNT(*) FROM customer_profiles
WHERE Location='';
UPDATE customer_profiles
SET Location='Unknown' 
WHERE Location='';
SELECT * FROM customer_profiles;

/*
Write a SQL query to clean the DATE column in the dataset.*/

SELECT * FROM customer_profiles;

SET SQL_SAFE_UPDATES=0;
ALTER TABLE customer_profiles
MODIFY COLUMN JoinDate date;

CREATE TABLE customer_profilex
SELECT * FROM customer_profiles;

DROP TABLE customer_profiles;
SELECT * FROM customer_profilex;

ALTER TABLE customer_profilex
RENAME TO customer_profiles;

SELECT * FROM sales_transactions;
SET SQL_SAFE_UPDATES=0;
ALTER TABLE sales_transactions
MODIFY COLUMN TransactionDate DATE;

CREATE TABLE sales_transactionsx
SELECT * FROM sales_transactions;

DROP TABLE sales_transactions;
ALTER TABLE sales_transactionsx
RENAME TO sales_transactions;

SELECT * FROM sales_transactions;
SELECT * , CAST(TransactionDate AS DATE) AS Transaction_Dateup
FROM sales_Transactions;

/*
Write a SQL query to summarize the total sales and quantities sold per product by the company. 
(Here, the data has been already cleaned in the previous steps and from here we will be understanding the different 
types of exploratory data analysis from the given dataset. )
*/
SELECT * FROM sales_transactions;
SELECT ProductID,ROUND(SUM(QuantityPurchased*Price),2) AS TotalSales, SUM(QuantityPurchased) AS TotalQuantity
FROM sales_transactions
GROUP BY ProductID
ORDER BY TotalSales DESC;

/*
Count the number of transactions per customer to understand purchase frequency.
Write a SQL query to count the number of transactions per customer to understand purchase frequency. 
*/
SELECT * FROM sales_transactions;
SELECT CustomerID, COUNT(TransactionID) AS nooftransactions
FROM sales_transactions
GROUP BY CustomerID
ORDER BY nooftransactions DESC;

/*
Evaluate performance of product categories based on total sales.
Write a SQL query to evaluate the performance of the product categories based on the total sales which help us understand the product categories 
which needs to be promoted in the marketing campaigns.
*/
SELECT * FROM sales_transactions;
SELECT * FROM product_inventory;

SELECT p.Category,ROUND(SUM(s.Price*s.QuantityPurchased),2) AS TotalSales, SUM(s.QuantityPurchased) AS TotalUnitsSold
FROM sales_transactions s 
JOIN product_inventory p ON p.ProductID=s.ProductID
GROUP BY p.Category
ORDER BY TotalSales DESC;

/*
Write a SQL query to find the top 10 products with the highest total sales revenue from the sales transactions. 
This will help the company to identify the High sales products which needs to be focused to increase the revenue of the company.
*/
SELECT * FROM sales_transactions;
SELECT ProductID, ROUND(SUM(QuantityPurchased*Price),2) AS TotalSales
FROM sales_transactions
GROUP BY ProductID
ORDER BY TotalSales DESC
LIMIT 10;

/* Write a SQL query to find the ten products with the least amount of units sold from the sales transactions, provided that atleast one unit was sold for those products. 
*/
SELECT * FROM sales_transactions;
SELECT ProductID, SUM(QuantityPurchased) AS TotalUnitsSold
FROM sales_transactions
GROUP BY ProductID
HAVING TotalUnitsSold>0
ORDER BY TotalUnitsSold ASC
LIMIT 10;

/*Write a SQL query to identify the sales trend to understand the revenue pattern of the company.*/
SELECT * FROM sales_transactions;
SELECT TransactionDate, COUNT(*) AS NumberofTransactions, ROUND(SUM(QuantityPurchased*Price),2) AS TotalSales, SUM(QuantityPurchased) AS TotalUnitsSold
FROM sales_transactions
GROUP BY TransactionDate
ORDER BY TransactionDate DESC;

/*
Write a SQL query that describes the number of transaction along with the total amount spent by each customer 
which are on the higher side and will help us understand the customers who are the high frequency purchase customers in the company.
*/
SELECT * FROM sales_transactions;
SELECT CustomerID, COUNT(TransactionID) AS NumberofTransactions, ROUND(SUM(QuantityPurchased*Price),2) AS Totalspent
FROM sales_transactions
GROUP BY CustomerID
HAVING NumberofTransactions>10 AND Totalspent>1000
ORDER BY Totalspent DESC;

/*
Write a SQL query that describes the number of transaction along with the total amount spent by each customer, 
which will help us understand the customers who are occasional customers in the company.
*/
SELECT * FROM sales_transactions;
SELECT CustomerID, COUNT(TransactionID) AS NumberofTransactions, ROUND(SUM(QuantityPurchased*Price),2) AS Totalspent
FROM sales_transactions
GROUP BY CustomerID
HAVING NumberofTransactions<=2 
ORDER BY NumberofTransactions ASC, Totalspent DESC;


/*
Write a SQL query that describes the total number of purchases made by each customer against each productID to understand the repeat customers in the company.
*/
SELECT * FROM sales_transactions;
SELECT CustomerID, ProductID, COUNT(*) AS NumberOfPurchases
FROM sales_transactions
GROUP BY CustomerID, ProductID
HAVING NumberOfPurchases>1
ORDER BY NumberOfPurchases DESC;

/*
Write a SQL query that describes the duration between the first and the last purchase of the customer in that particular company to understand the loyalty of the customer.
*/
SELECT * FROM sales_transactions;
SELECT CustomerID,ProductID, MIN(TransactionDate) AS FirstPurchase, MAX(TransactionDate) AS LastPurchase, DATEDIFF(MAX(TransactionDate),MIN(TransactionDate)) AS DaysBetweenPurchase
FROM sales_transactions
GROUP BY CustomerID,ProductID
HAVING DaysBetweenPurchase>0
ORDER BY DaysBetweenPurchase DESC;

/*
Write a SQL query that segments customers based on the total quantity of products they have purchased. Also, count the number of customers in each segment. 
Create Customer segments - 
Total Qty of Products Purchased          Customer Segment
1-10                                      Low 
11-30                                     Mid
>30                                       High
*/
SELECT * FROM customer_profiles;
SELECT * FROM sales_transactions;
WITH CS AS(
SELECT c.CustomerID AS CustomerID , SUM(s.QuantityPurchased) AS TotalQuantity
FROM customer_profiles c
JOIN sales_transactions s ON c.CustomerID=s.CustomerID
GROUP BY CustomerID)
SELECT CASE WHEN TotalQuantity BETWEEN 1 AND 10 THEN 'Low'
WHEN TotalQuantity BETWEEN 11 AND 30 THEN 'Mid'
WHEN TotalQuantity >30 THEN 'High'
ELSE 'None'
END AS CustomerSegment,
COUNT(*) AS CustomerCount
FROM CS
GROUP BY CustomerSegment
ORDER BY CustomerCount DESC;




