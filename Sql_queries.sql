create database ecommerce;
use ecommerce;

-- 1.Retrieve the total number of orders.
    SELECT COUNT(*) as total_orders FROM salesdata;
    
-- 2.List the unique regions in the dataset.
   select distinct Region from salesdata;
   
-- 3.	Calculate the total sales for each region.
    SELECT Region,sum(Sales) from salesdata
    group by Region;
    
-- 4.	Find the average sales per product.
    SELECT Product,avg(Sales) from salesdata
    group by Product;
    
-- 5.	Identify the top 5 customers with the highest total sales.
    SELECT `Customer Name`, SUM(Sales) as total_sales FROM salesdata 
    GROUP BY `Customer Name` 
    ORDER BY total_sales 
    DESC LIMIT 5;
    
-- 6.	Retrieve the orders where the refund status is TRUE.
    select * from salesdata
    where Refunded='true';
    
-- 7.	List the products that have never been refunded.
    SELECT DISTINCT Product FROM salesdata 
    where Refunded='false';
   
-- 8.	Calculate the total sales for each product in the East region.
	SELECT Product, SUM(Sales) FROM salesdata 
    WHERE Region = 'East' 
    GROUP BY Product;

-- 9.	Find the customer who made the highest single purchase.
	select `Customer Name`,sum(sales) from salesdata
    group by `Customer Name`
    order by sum(sales) desc
    limit 1;

-- 10.	Identify the top 3 products with the highest total sales.
SELECT Product, SUM(Sales) as total_sales FROM salesdata 
GROUP BY Product 
ORDER BY total_sales desc
LIMIT 3;

-- 11.	List the customers who have made purchases in all regions.
SELECT `Customer Name` FROM salesdata
GROUP BY `Customer Name`
HAVING COUNT(DISTINCT Region) =(SELECT COUNT(DISTINCT Region) FROM salesdata);

-- 12.	Retrieve the orders with sales greater than the average sales.
select * from salesdata
where Sales > (select avg(Sales) from salesdata);

-- 13.	Calculate the percentage of refunded sales for each product.
SELECT Product, 
       (SUM(CASE 
			WHEN Refunded = TRUE THEN Sales 
            ELSE 0 END) / SUM(Sales)) * 100 AS refund_percentage
FROM salesdata
GROUP BY Product;

-- 14.	Find the customers who have made purchases on more than one day.
SELECT `Customer Name`
FROM salesdata
GROUP BY `Customer Name`
HAVING COUNT(DISTINCT Purchased_At) > 1;

-- 15.	List the customers who have made purchases in both January and February.
select `Customer Name` from salesdata
where month(Purchased_At) IN (1,2)
group by `Customer Name`
having count(distinct month(Purchased_At))=2;

-- 16.	Calculate the average sales per day for each region.
select Region,avg(Sales) from salesdata
group by region;

-- 17.	Retrieve the orders with the earliest and latest purchase times.
select * from salesdata
where Purchased_At= (select max(Purchased_At) from salesdata) or 
      Purchased_At= (select min(Purchased_At) from salesdata);

-- 18.	List the customers who have made purchases on consecutive days.
select `Customer Name`,Purchased_At from salesdata t1
where exists( select 1
              from salesdata t2
              where t1.`Customer Name`= t2.`Customer Name` and
              datediff(t2.Purchased_At,t1.Purchased_At)>1);

-- 19.	Calculate the total sales for each product category (A, B, C, etc.).
SELECT Product, SUM(Sales) AS total_sales
FROM salesdata
GROUP BY Product;

-- 20.	Identify the customers who have made the same purchase multiple times.
select `Customer Name`,Product,count(*) from salesdata
group by Product,`Customer Name`
having count(*)>1;

-- 20.	Retrieve the orders where the purchased date is not equal to the registered date.
SELECT *
FROM salesdata
WHERE DATE(Purchased_At) <> DATE(Registered_At);

-- 21.	List the products with sales greater than 50% of the total sales.
SELECT Product, SUM(Sales) AS product_sales
FROM salesdata
GROUP BY Product
HAVING product_sales > (SELECT 0.5 * SUM(Sales) FROM salesdata);

-- 22.	Calculate the difference in sales between consecutive orders for each customer.
SELECT `Customer Name`, Sales - LAG(Sales) OVER (PARTITION BY `Customer Name` ORDER BY Purchased_At) AS sales_difference
FROM salesdata;

-- 23. Identify the top 2 regions with the highest average sales per order.
SELECT Region, AVG(Sales) AS avg_sales
FROM salesdata
GROUP BY Region
ORDER BY avg_sales DESC
LIMIT 2;

-- 24. Retrieve the customers who have made the highest total purchases in each region.
SELECT `Customer Name`, Region, SUM(Sales) AS total_purchases
FROM salesdata
GROUP BY `Customer Name`, Region
ORDER BY total_purchases DESC;

-- 25.Find the customers who have made purchases on the same day.
SELECT `Customer Name`,DATE(Purchased_At)
FROM salesdata
GROUP BY `Customer Name`, DATE(Purchased_At)
HAVING COUNT(DISTINCT Product) > 1;

-- 26.Retrieve the orders with a gap of more than 3 days between consecutive orders.
select *
FROM salesdata t1
WHERE EXISTS (
    SELECT 1
    FROM salesdata t2
    WHERE t2.`Customer Name` = t1.`Customer Name`
      AND DATEDIFF(t2.Purchased_At, t1.Purchased_At) > 3
);


-- 27.Identify the customers who have made purchases in the first and last week of the dataset.
SELECT `Customer Name`
FROM salesdata
WHERE DATE(Purchased_At) BETWEEN (SELECT MIN(DATE(Purchased_At)) FROM salesdata)
                           AND (SELECT MAX(DATE(Purchased_At)) FROM salesdata)
GROUP BY `Customer Name`
HAVING COUNT(DISTINCT WEEK(Purchased_At)) = 2;

-- 28.List the customers who have made purchases in all product categories.
SELECT `Customer Name`
FROM salesdata
GROUP BY `Customer Name`
HAVING COUNT(DISTINCT Product) = (SELECT COUNT(DISTINCT Product) FROM your_table);

-- 29.Find the customers who have made purchases in every month of the dataset.
SELECT `Customer Name`
FROM salesdata
GROUP BY `Customer Name`
HAVING COUNT(DISTINCT MONTH(Purchased_At)) = (SELECT COUNT(DISTINCT MONTH(Purchased_At)) FROM salesdata);

-- 30.List the products with the highest sales on weekdays and weekends separately.
SELECT Product, 
       MAX(Sales) AS highest_weekday_sales,
       MAX(CASE WHEN DAYOFWEEK(Purchased_At) IN (1, 7) THEN Sales ELSE 0 END) AS highest_weekend_sales
FROM salesdata
GROUP BY Product;

-- 31.Identify the customers who have made purchases on all weekdays.
SELECT `Customer Name`
FROM salesdata
GROUP BY `Customer Name`
HAVING COUNT(DISTINCT DAYOFWEEK(Purchased_At)) = 7;

-- 32.Retrieve the orders with the highest and lowest sales in each region.
WITH RankedSales AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY Region ORDER BY Sales DESC) AS sales_rank_desc,
           ROW_NUMBER() OVER (PARTITION BY Region ORDER BY Sales ASC) AS sales_rank_asc
    FROM salesdata
)
SELECT *
FROM RankedSales
WHERE sales_rank_desc = 1 OR sales_rank_asc = 1;