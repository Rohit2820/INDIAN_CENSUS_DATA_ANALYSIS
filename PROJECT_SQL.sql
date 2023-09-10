SELECT * FROM SYS.DATABASES;
-- creating a new database for project --

CREATE DATABASE project_sql;

-- using the newly created database --

USE project_sql
GO

-- retreiving data from dataset1  AND dataset2--

SELECT * FROM dataset1;
SELECT * FROM dataset2;


--1. How many rows are there in dataset1 --

SELECT COUNT(*) AS Total_Rows FROM dataset1;

--2. Sex Ratio in district where state is bihar and uttarpradesh in decreasing order --

SELECT DISTINCT District,State,Sex_Ratio 
FROM dataset1 
WHERE State in ('Bihar','Uttar Pradesh') 
ORDER BY Sex_Ratio DESC;

--3. What is the avg growth --

SELECT AVG(Growth)*100 as Average_Growth FROM dataset1;

-- 4. which district has maximum literacy rate --

SELECT TOP 1 DISTRICT FROM dataset1 ORDER BY Literacy DESC;

-- 5. what is the avg growth of each state --

SELECT State,AVG(Growth)*100 AS Avg_Growth
FROM dataset1 group by State 
ORDER BY Avg_Growth DESC;

--6. What is the avg sex ratio--

SELECT round(AVG(Sex_Ratio),0) AS Avg_Sex_Ratio FROM dataset1;

-- 7. What is avg sex ratio of each state and which state has highest avg sex ratio --

SELECT State, round(AVG(Sex_Ratio),0) as Avg_Sex_Ratio FROM dataset1
GROUP BY State ORDER BY Avg_Sex_Ratio DESC;

-- 8. Average Literacy rate --

SELECT round(AVG(Literacy),2) AS Avg_Literacy_rate FROM dataset1;

-- 9. what is the average literacy rate of each state and find out only those state which is having avg literacy rate greater than 90 --

SELECT State, ROUND(AVG(Literacy),0) AS Avg_literacy_Rate FROM dataset1 
GROUP BY State HAVING ROUND(AVG(Literacy),0) >90
ORDER BY Avg_literacy_Rate DESC;

-- 10. top 3 states showing highest growth


SELECT TOP 3 State , SUM(Growth)
FROM dataset1
GROUP BY State
ORDER BY SUM(Growth) DESC;

-- 11. top 3 states having highest avg grwoth percentage


SELECT TOP 3 State,(AVG(Growth)*100) AS Growth_Percentage
FROM dataset1
GROUP BY State
ORDER BY Growth_Percentage DESC;


--12. BOTTOM 3 states having highest avg grwoth percentage


SELECT TOP 3 State,ROUND(AVG(Growth)*100,2) AS Growth_Percentage
FROM dataset1
GROUP BY State
ORDER BY Growth_Percentage ASC;

--13. BOTTOM 3 states showing lowest avg sex ratio 

SELECT TOP 3 State,AVG(Sex_Ratio) AS Avg_sex_ratio
FROM dataset1
GROUP BY State
ORDER BY Avg_sex_ratio;
 

 -- 14. top and bottom 3 states in literacy state

 SELECT * FROM(SELECT TOP 3 State, SUM(Literacy) as Literacy
 FROM dataset1 
 GROUP BY State
 ORDER BY Literacy DESC) AS t1
 UNION
 SELECT * FROM (SELECT TOP 3 State, SUM(Literacy) as Literacy
 FROM dataset1 
 GROUP BY State
 ORDER BY Literacy ASC) AS t2;

 --- 15.  SELECT STATE STARTING WITH LETTER A 

 SELECT Distinct State 
 FROM dataset1 
 WHERE State like 'A%';

 --- 16.  SELECT STATES STARTING WITH A OR B 

 SELECT DISTINCT State 
 FROM dataset1
 WHERE State  like 'A%' or State like 'B%' ; 



---- 17. CALCULATING TOTAL NO. OF MALES AND FEMALES IN A DISTRICT --- 


SELECT District, State, Population ,FLOOR(Population/(1+Sex_Ratio))AS Male, (Population-FLOOR(Population/(1+Sex_Ratio))) AS Female
FROM(SELECT d1.District,d1.State,d1.Sex_Ratio/1000 AS Sex_Ratio,d2.Population
FROM dataset1 d1
JOIN dataset2 d2
ON d1.District = d2.District) AS c_data;


---- 18.  CALCULATING TOTAL NO. OF MALES AND FEMALES IN A STATE  --- 

SELECT State,POPULATIONS,FLOOR((POPULATIONS/(1+Sex_Ratio))) AS Male , FLOOR((POPULATIONS - (POPULATIONS/(1+Sex_Ratio)))) AS Female
FROM(SELECT d1.State,SUM(d2.Population) AS POPULATIONS,ROUND((AVG(d1.Sex_Ratio)/1000),3) AS Sex_Ratio
FROM dataset1 d1
JOIN dataset2 d2
ON d1.District = d2.District
GROUP BY d1.State) AS N_DATA;


--- 19.  CALCULATING TOTAL NO. OF LITERATE PEOPLE AND ILLITERATE PEOPLE IN DISTRICTS ---
WITH DATA 
AS(SELECT  d1.District,d1.Literacy/100 as literacy,d2.Population 
FROM dataset1 d1
JOIN dataset2 d2
ON d1.District = d2.District)
SELECT District,population,FLOOR(population*(1-literacy)) as Illiterate,Population-FLOOR(population*(1-literacy)) AS literate
FROM DATA;

--- 20. calculating previous census district populatin --- 
WITH prev_pop 
AS(SELECT d1.District,d1.Growth,d2.Population
FROM dataset1 d1
JOIN dataset2 d2
ON d1.District = d2.District)
SELECT District, Population, FLOOR(Population/(1+Growth)) AS prev_Population, (Population - FLOOR(Population/(1+Growth))) AS INC_Population 
FROM prev_pop;

-- 21. calculating previous_census state population--

WITH State_Pop
AS (SELECT d1.State,AVG(d1.Growth) AS Growth,SUM(d2.Population) AS Population
FROM dataset1 d1
JOIN dataset2 d2
ON d1.District = d2.District
GROUP BY d1.State)
SELECT State, Population, FLOOR(Population/(1+Growth)) AS prev_Population, (Population - FLOOR(Population/(1+Growth))) AS INC_Population 
FROM State_Pop;

-- 22. CALCULATING INDIA'S TOTAL POPULATION IN CURRENT CENSUS AND IN PREVIOUS CENSUS --

WITH India_Pop
AS(SELECT State, Population, FLOOR(Population/(1+Growth)) AS prev_Population, (Population - FLOOR(Population/(1+Growth))) AS INC_Population 
FROM  (SELECT d1.State,AVG(d1.Growth) AS Growth,SUM(d2.Population) AS Population
FROM dataset1 d1
JOIN dataset2 d2
ON d1.District = d2.District
GROUP BY d1.State) as State_population)
SELECT SUM(Population) AS Current_Census_Population , SUM(Prev_Population) AS Previous_Census_Population 
FROM India_Pop ;


-- 23. TOP 1 DISTRICT FROM EACH STATE WHICH HAVING HIGHEST LITERACY ---


SELECT DISTINCT District,State,Literacy
FROM(SELECT   *,
ROW_NUMBER() OVER(PARTITION BY State ORDER BY Literacy DESC) AS rown
FROM dataset1 )AS data
WHERE data.rown < 2;