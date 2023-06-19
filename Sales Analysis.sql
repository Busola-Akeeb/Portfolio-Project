-- Inspecting data
SELECT *
FROM Sales_Data;

-- Checking Unique values
SELECT DISTINCT(status)
FROM Sales_Data;

SELECT DISTINCT(year_id)
FROM Sales_Data;

SELECT DISTINCT(productline)
FROM Sales_Data;

SELECT DISTINCT(country)
FROM Sales_Data;

SELECT DISTINCT(dealsize)
FROM Sales_Data;

SELECT DISTINCT(territory)
FROM Sales_Data;


-- ANALYSIS

-- Grouping sales by product line

SELECT productline, SUM(sales) AS Revenue
FROM Sales_Data
GROUP BY productline
ORDER BY 2 DESC;

-- Grouping sales by Year

SELECT year_id, SUM(sales) AS Revenue
FROM Sales_Data
GROUP BY year_id
ORDER BY 2 DESC;

SELECT DISTINCT(month_id)
FROM Sales_Data
WHERE year_id = 2005;
-- Sales is the lowest in 2005 because the business only operated for the first 5 months of the year.

-- Grouping sales by Dealsize

SELECT dealsize, SUM(sales) AS Revenue
FROM Sales_Data
GROUP BY dealsize
ORDER BY 2 DESC;

-- What was the best month for sales in a particular year? How much was earned that month?
-- We will not be doing a lot of analysis for the year '2005' because it shows data for just 5 months. This would not give a fair reflection
-- on how usiness was that year compared to the previous years

SELECT month_id, SUM(Sales) AS Revenue, COUNT(OrderNumber) AS Frequency
FROM Sales_Data
WHERE year_id = 2003
GROUP BY month_id
ORDER BY 2 DESC;

SELECT month_id, SUM(Sales) AS Revenue, COUNT(OrderNumber) AS Frequency
FROM Sales_Data
WHERE year_id = 2004
GROUP BY month_id
ORDER BY 2 DESC;

SELECT month_id, SUM(Sales) AS Revenue, COUNT(OrderNumber) AS Frequency
FROM Sales_Data
WHERE year_id = 2005
GROUP BY month_id
ORDER BY 2 DESC;


-- November seems to be the best month for sales in 2003 & 2004, what product sold the best in this month?
-- For both years we can see that classic cars were the best selling products in the highest earning month(November)

SELECT month_id, productline, SUM(sales) AS Revenue, COUNT(OrderNumber) AS Frequency
FROM Sales_Data
WHERE year_id = 2003 AND month_id = 11
GROUP BY month_id, productline
ORDER BY 3 DESC;

SELECT month_id, productline, SUM(sales) AS Revenue, COUNT(OrderNumber) AS Frequency
FROM Sales_Data
WHERE year_id = 2004 AND month_id = 11
GROUP BY month_id, productline
ORDER BY 3 DESC;


-- Who is our best customer? We will do this using the RFM Analysis

DROP TABLE IF EXISTS #rfm
;WITH rfm AS
(
   SELECT
      Customername,
      SUM(Sales) AS Monetary_Value,
      AVG(sales) AS AvgMonetary_Value,
      COUNT(OrderNumber) AS Frequency,
      MAX(OrderDate) AS last_order_date,
     (SELECT MAX(OrderDate) FROM Sales_Data) AS Max_Order_Date,
     DATEDIFF(DD, MAX(OrderDate), (SELECT MAX(OrderDate) FROM Sales_Data)) AS Recency
  FROM Sales_Data
  GROUP BY customername
),
rfm_calc AS
(
	SELECT r.*,
       NTILE(4) OVER (ORDER BY Recency DESC) AS rfm_Recency,
	   NTILE(4) OVER (ORDER BY Frequency) AS rfm_Frequency,
	   NTILE(4) OVER (ORDER BY Monetary_Value) AS rfm_Monetary
FROM rfm AS r
)

SELECT c.*, rfm_Recency+ rfm_Frequency+ rfm_Monetary AS rfm_cell,
       CAST(rfm_Recency AS VARCHAR) + CAST(rfm_Frequency AS VARCHAR) + CAST(rfm_Monetary AS VARCHAR) AS rfm_cell_string
into #rfm
FROM rfm_calc AS c;


SELECT *
FROM #rfm;


-- Customer Segmentation

SELECT customername, rfm_Recency, rfm_Frequency, rfm_Monetary,
   CASE
       WHEN rfm_cell_string IN (111, 112, 121, 122, 123, 132, 211, 212, 114, 141) THEN 'Lost_Customers'
	   WHEN rfm_cell_string IN (144, 133, 134, 143, 244, 334, 343, 344, 234) THEN 'Slipping away, cannot lose'
	   WHEN rfm_cell_string IN (311, 411, 331, 421) THEN 'New_Customers'
	   WHEN rfm_cell_string IN (222, 223, 233, 322) THEN 'Potential_Customers'
	   WHEN rfm_cell_string IN (323, 333, 321, 422, 332, 432, 423) THEN 'Active'
	   WHEN rfm_cell_string IN (433, 434, 443, 444) THEN 'Loyal'
	   END AS rfm_Segment
FROM #rfm;

-- What 2 products are most often sold together?

SELECT DISTINCT OrderNumber, STUFF(

    (SELECT ',' + ProductCode
	FROM Sales_Data AS p
	WHERE OrderNumber IN
	     (

	SELECT OrderNumber
	FROM (
	    SELECT OrderNumber, COUNT(*) AS rn
        FROM Sales_Data
        WHERE Status = 'Shipped'
        GROUP BY OrderNumber
    ) m
    WHERE rn = 2
  )
     AND p.OrderNumber = s.OrderNumber
     FOR xml path (''))

	 , 1, 1, '') ProductCodes

	 FROM Sales_Data AS s
	 ORDER BY 2 DESC;


