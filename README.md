# Swiggy-Sales-Analysis
An end-to-end SQL-based data engineering and analytics project performing data cleaning, dimensional modelling (Star Schema), and KPI development on a dataset of 53,000+ Swiggy food delivery records.

📌 Project Overview
This project transforms raw, messy food delivery data into a structured analytical database. The goal was to build a robust Star Schema to enable fast and efficient business reporting on sales trends, customer behavior, and restaurant performance.

🚀 Key Features & Workflow
1. Data Cleaning & Validation
Null Check: Comprehensive validation to identify and count missing values in critical fields like Order_Date, Price_INR, and Rating.

Duplicate Management: Used ROW_NUMBER() and CTEs to detect and remove duplicate entries, ensuring data accuracy for over 53k rows.

2. Dimensional Modelling (Star Schema)
Designed and implemented a normalized database structure featuring:

dim_date: Time-based attributes (Year, Month, Quarter, Week).

dim_location: Geographical data (State, City, Location).

dim_restaurant, dim_category, dim_dish: Categorical master tables.

fact_swiggy_orders: A central fact table linking all dimensions with metrics like Price_INR and Rating.

3. Business Insights & KPIs
Developed queries to calculate:

Sales Trends: Monthly and quarterly order volume.

Customer Spending: Segmentation based on price buckets (Under 100, 100-499, 500+).

Operational Performance: Top cities and most-ordered dish categories.

🛠️ Tech Stack
Database: Microsoft SQL Server (SSMS).

Language: T-SQL (Advanced Joins, CTEs, Window Functions, DDL/DML).
