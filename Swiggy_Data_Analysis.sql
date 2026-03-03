SELECT * FROM swiggy_data

--DATA Validation & Cleaning
--Null Check

SELECT 
    SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS null_state,
    SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS null_city,
    SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
    SUM(CASE WHEN Restaurant_Name IS NULL THEN 1 ELSE 0 END) AS null_restaurant,
    SUM(CASE WHEN Location IS NULL THEN 1 ELSE 0 END) AS null_location,
    SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) AS null_category,
    SUM(CASE WHEN Dish_Name IS NULL THEN 1 ELSE 0 END) AS null_dish,
    SUM(CASE WHEN Price_INR IS NULL THEN 1 ELSE 0 END) AS null_price,
    SUM(CASE WHEN Rating IS NULL THEN 1 ELSE 0 END) AS null_rating,
    SUM(CASE WHEN Rating_Count IS NULL THEN 1 ELSE 0 END) AS null_rating_count
FROM swiggy_data;


--Blank or Empty Strings
SELECT *
FROM swiggy_data
WHERE
State = '' OR City='' OR Restaurant_Name = '' OR Category = '' OR Dish_Name =''

--Duplicate Detection
SELECT
State, City, order_date, restaurant_name, location, category,
dish_name, price_INR, rating, rating_count, count(*) as CNT
FROM swiggy_data
GROUP BY
State, City, order_date, restaurant_name, location, category,
dish_name, price_INR, rating, rating_count
Having count(*)>1

--Delete Duplication
SELECT Order_Date, Restaurant_Name, Dish_Name, Price_INR, COUNT(*)
FROM swiggy_data
GROUP BY Order_Date, Restaurant_Name, Dish_Name, Price_INR
HAVING COUNT(*) > 1;

-- Duplicate Removal using ROW_NUMBER()
WITH CTE AS (
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY Order_Date, Restaurant_Name, Dish_Name, Price_INR 
        ORDER BY (SELECT NULL)) as row_num
    FROM swiggy_data
)
DELETE FROM CTE WHERE row_num > 1;

--CREATING SCHEMA
--DIMENSION TABLES
--DATE TABLE
CREATE TABLE dim_date (
    date_id INT IDENTITY(1,1) PRIMARY KEY,
    Full_Date DATE,
    Year INT,
    Month INT,
    Month_Name varchar(20),
    Quarter INT,
    Day INT,
    Week INT
)

--dim_location
CREATE TABLE dim_location (
    Location_id INT IDENTITY(1,1) PRIMARY KEY,
    State VARCHAR(100),
    City VARCHAR(100),
    Location VARCHAR(200)
);

--dim_restaurant
CREATE TABLE dim_restaurant (
    Restaurant_id INT IDENTITY(1,1) PRIMARY KEY,
    Restaurant_Name VARCHAR(200)
);

--dim_category
CREATE TABLE dim_category (
    Category_id INT IDENTITY(1,1) PRIMARY KEY,
    Category VARCHAR(200)
);

--dim_dish
CREATE TABLE dim_dish (
    Dish_id INT IDENTITY(1,1) PRIMARY KEY,
    Dish_Name VARCHAR(200)
);

SELECT * FROM swiggy_data

--FACT TABLE
CREATE TABLE fact_swiggy_orders (
    order_id INT IDENTITY(1,1) PRIMARY KEY,
    
    date_id INT,
    Price_INR DECIMAL(10,2),
    Rating DECIMAL(4,2),
    Rating_Count INT,
    
    location_id INT,
    restaurant_id INT,
    category_id INT,
    dish_id INT,
    
    FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
    FOREIGN KEY (location_id) REFERENCES dim_location(location_id),
    FOREIGN KEY (restaurant_id) REFERENCES dim_restaurant(restaurant_id),
    FOREIGN KEY (category_id) REFERENCES dim_category(category_id),
    FOREIGN KEY (dish_id) REFERENCES dim_dish(dish_id)
);
SELECT * FROM fact_swiggy_orders


--INSERT DATA IN TABLES
--dim_date
INSERT INTO dim_date (Full_Date, Year, Month, Month_Name, Quarter, Day, Week)
SELECT DISTINCT 
    Order_Date, 
    YEAR(Order_Date), 
    MONTH(Order_Date), 
    DATENAME(MONTH, Order_Date), 
    DATEPART(QUARTER, Order_Date), 
    DAY(Order_Date), 
    DATEPART(WEEK, Order_Date)
FROM swiggy_data;

SELECT * FROM dim_date

-- Inserting into dim_location
INSERT INTO dim_location (State, City, Location)
SELECT DISTINCT State, City, Location 
FROM swiggy_data;

-- Inserting into dim_restaurant
INSERT INTO dim_restaurant (Restaurant_Name)
SELECT DISTINCT Restaurant_Name 
FROM swiggy_data;

-- Inserting into dim_category
INSERT INTO dim_category (Category)
SELECT DISTINCT Category 
FROM swiggy_data;

-- Inserting into dim_dish
INSERT INTO dim_dish (Dish_Name)
SELECT DISTINCT Dish_Name 
FROM swiggy_data;

--fact-table
INSERT INTO fact_swiggy_orders
(
    date_id,
    Price_INR,
    Rating,
    Rating_Count,
    location_id,
    restaurant_id,
    category_id,
    dish_id
)
SELECT
    dd.date_id,
    s.Price_INR,
    s.Rating,
    s.Rating_Count,

    dl.location_id,
    dr.restaurant_id,
    dc.category_id,
    dsh.dish_id
FROM swiggy_data s

JOIN dim_date dd
    ON dd.Full_Date = s.Order_Date

JOIN dim_location dl
    ON dl.State = s.State
    AND dl.City = s.City
    AND dl.Location = s.location

JOIN dim_restaurant dr
    ON dr.Restaurant_Name = s.Restaurant_Name

JOIN dim_category dc
    ON dc.Category = s.Category

JOIN dim_dish dsh
    ON dsh.Dish_Name = s.Dish_Name;

    SELECT * FROM fact_swiggy_orders

    

SELECT * FROM fact_swiggy_orders f
JOIN dim_date d ON f.date_id = d.date_id
JOIN dim_location l ON f.location_id = l.location_id
JOIN dim_restaurant r ON f.restaurant_id = r.restaurant_id
JOIN dim_category c ON f.category_id = c.category_id
JOIN dim_dish di ON f.dish_id = di.dish_id;


--KPI's
--Total Orders
SELECT 
    COUNT(*) AS Total_Orders, --
    SUM(Price_INR) / 1000000 AS Total_Revenue_INR_Million, --
    AVG(Price_INR) AS Average_Dish_Price, --
    AVG(Rating) AS Average_Rating --
FROM swiggy_data;

--Deep-Dive Business Analysis
-- Top 10 Cities by Order Volume
SELECT TOP 10 City, COUNT(*) AS Order_Volume
FROM swiggy_data
GROUP BY City
ORDER BY Order_Volume DESC;

-- Monthly Order Trends
SELECT FORMAT(Order_Date, 'yyyy-MM') AS Month, COUNT(*) AS Monthly_Orders
FROM swiggy_data
GROUP BY FORMAT(Order_Date, 'yyyy-MM')
ORDER BY Month;

-- Customer Spending Buckets
SELECT 
    CASE 
        WHEN Price_INR < 100 THEN 'Under 100'
        WHEN Price_INR BETWEEN 100 AND 199 THEN '100-199'
        WHEN Price_INR BETWEEN 200 AND 299 THEN '200-299'
        WHEN Price_INR BETWEEN 300 AND 499 THEN '300-499'
        ELSE '500+'
    END AS Spending_Range,
    COUNT(*) AS Total_Orders
FROM swiggy_data
GROUP BY 
    CASE 
        WHEN Price_INR < 100 THEN 'Under 100'
        WHEN Price_INR BETWEEN 100 AND 199 THEN '100-199'
        WHEN Price_INR BETWEEN 200 AND 299 THEN '200-299'
        WHEN Price_INR BETWEEN 300 AND 499 THEN '300-499'
        ELSE '500+'
    END;