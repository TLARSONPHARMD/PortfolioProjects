-- Question 1: Find the Number of Stolen Vehicles Each Year
SELECT
	YEAR(date_stolen) as Year,
    COUNT(vehicle_id) as num_vehicles
FROM stolen_vehicles
GROUP BY YEAR(date_stolen);

-- Question 2: Find the Number of Stolen Vehicles Each Month
SELECT
YEAR(date_stolen), month(date_stolen), count(vehicle_id)
FROM stolen_vehicles
GROUP BY YEAR(date_stolen), month(date_stolen)
ORDER BY YEAR(date_stolen), month(date_stolen);

-- Question 3: Find the Number of Stolen Vehicles Each week
SELECT
dayofweek(date_stolen) as day_of_week,
count(vehicle_id)
FROM stolen_vehicles
GROUP BY dayofweek(date_stolen)
ORDER BY dayofweek(date_stolen);

-- Question 4: Replace the numerical day of week with the full name of the day of week
SELECT dayofweek(date_stolen) as dow,
CASE 
	WHEN dayofweek(date_stolen) = 1 THEN 'Sunday'
    WHEN dayofweek(date_stolen) = 2 THEN 'Monday'
    WHEN dayofweek(date_stolen) = 3 THEN 'Tuesday'
    WHEN dayofweek(date_stolen) = 4 THEN 'Wednesday'
    WHEN dayofweek(date_stolen) = 5 THEN 'Thursday'
    WHEN dayofweek(date_stolen) = 6 THEN 'Friday'
    WHEN dayofweek(date_stolen) = 7 THEN 'Saturday'
ELSE 'Check logic'
END AS day_of_week_words,
count(vehicle_id)
FROM stolen_vehicles
GROUP BY dayofweek(date_stolen),
	CASE 
	WHEN dayofweek(date_stolen) = 1 THEN 'Sunday'
    WHEN dayofweek(date_stolen) = 2 THEN 'Monday'
    WHEN dayofweek(date_stolen) = 3 THEN 'Tuesday'
    WHEN dayofweek(date_stolen) = 4 THEN 'Wednesday'
    WHEN dayofweek(date_stolen) = 5 THEN 'Thursday'
    WHEN dayofweek(date_stolen) = 6 THEN 'Friday'
    WHEN dayofweek(date_stolen) = 7 THEN 'Saturday'
ELSE 'Check logic'
END
ORDER BY dayofweek(date_stolen);

-- Question 5: Create a bar chart that shows the number of vehicles stolen on each day of the week
-- In Excel

/*Objective 2
Identify which vehicles are likely to be stolen
Your second objective is to explore the vehicle type, age, luxury vs standard and color fields in the stolen_vehicles table to identify which vehicles are most likely to be stolen.*/

-- Task 1: Find the vehicle types that are most often and least often stolen

SELECT 
    vehicle_type, COUNT(*)
FROM
    stolen_vehicles
GROUP BY vehicle_type
ORDER BY COUNT(*) DESC;

-- Task 2: For each vehicle type, find the average age of the cars that are stolen

SELECT vehicle_type,
		AVG(year(date_stolen) - model_year) as Avg_Age
FROM stolen_vehicles
GROUP BY vehicle_type
ORDER BY Avg_Age DESC;


-- Task 3: For each vehicle type, find the percent of vehicles stolen that are luxury versus standard

SELECT 
    vehicle_type,
    AVG(CASE WHEN make_type = 'Luxury' THEN 1 ELSE 0 END) * 100 AS percent_luxury
FROM stolen_vehicles
LEFT JOIN make_details 
	ON stolen_vehicles.make_id = make_details.make_id
GROUP BY vehicle_type
ORDER BY percent_luxury DESC;

/* Task 4: For each vehicle type, find the percent of vehicles stolen that are luxury versus standardCreate a table where the rows represent the top 10 vehicle types, the columns represent the top 7 vehicle colors (plus 1 column for all other colors) 
and the values are the number of vehicles stolen (Silver, Black ,Blue ,White ,Grey , Green, Yellow, Red, Brown, Orange, Cream, Gold, Purple, Pink*/
SELECT 
	color,
	COUNT(vehicle_id) AS vehicles_stolen
FROM stolen_vehicles
GROUP BY COLOR
ORDER BY vehicles_stolen desc;
		

SELECT 
vehicle_type, COUNT(vehicle_id) AS num_vehicles,
SUM(CASE WHEN COLOR ='Silver' THEN 1 ELSE 0 END) AS Silver,
SUM(CASE WHEN COLOR ='White' THEN 1 ELSE 0 END) AS White,
SUM(CASE WHEN COLOR ='Blue' THEN 1 ELSE 0 END) AS Black,
SUM(CASE WHEN COLOR ='Black' THEN 1 ELSE 0 END) AS Blue,
SUM(CASE WHEN COLOR ='Red' THEN 1 ELSE 0 END)AS Red,
SUM(CASE WHEN COLOR ='Grey' THEN 1 ELSE 0 END) AS Grey,
SUM(CASE WHEN COLOR ='Green' THEN 1 ELSE 0 END) AS Green,
SUM(CASE WHEN COLOR IN ('Pink' ,'Cream' ,'Purple','Yellow','Gold' ,'Orange','Brown') THEN 1 ELSE 0 END) AS Other
FROM stolen_vehicles
GROUP BY vehicle_type
ORDER BY num_vehicles DESC
LIMIT 10;

-- Task 5: Create a heatmap. See Excel Obj 2 results.

/*Objective 3:

Task 1: Find the number of vehicles that were stolen in each region*/

SELECT 
l.region, 
COUNT(sv.vehicle_id) as num_stolen
FROM stolen_vehicles sv 
LEFT JOIN locations l
on sv.location_id = l.location_id
GROUP BY region
ORDER BY num_stolen desc;

-- Task 2: Combine the previous output with the population and density statistics for each region

SELECT l.region, COUNT(sv.vehicle_id) as num_stolen,
	   l.population, l.density
FROM stolen_vehicles sv LEFT JOIN locations l 
	 ON sv.location_id = l.location_id
GROUP BY l.region, l.population, l.density
ORDER BY num_stolen DESC;

-- Do the types of vehicles stolen in the three most dense regions differ from the three least dense regions?

-- 3 MOST DENSE
(SELECT 'High Density',
sv.vehicle_type, COUNT(vehicle_id) num_stolen
FROM stolen_vehicles sv 
LEFT JOIN locations l
on sv.location_id = l.location_id
WHERE l.region IN('Auckland','Nelson', 'Wellington')
GROUP BY sv.vehicle_type
ORDER BY num_stolen DESC
LIMIT 5)

UNION

-- 3 LEAST DENSE
(SELECT 'Low_Density', 
sv.vehicle_type, 
COUNT(vehicle_id) num_stolen
FROM locations l
LEFT JOIN stolen_vehicles sv
ON l.location_id = sv.location_id
WHERE region IN('Otago', 'Gisborne', 'Southland')
GROUP BY region, density, vehicle_type
ORDER BY num_stolen DESC
LIMIT 5);

-- Task 4- Create a scatter plot of population versus density, and change the size of the points based on the number of vehicles stolen in each region
-- Exported the data from the query below as csv file to Excel
SELECT 
l.region,
l.population,
l.density,
COUNT(vehicle_id) as num_stolen
FROM locations l
LEFT JOIN stolen_vehicles sv
ON l.location_id = sv.location_id
GROUP BY region, population, density
ORDER BY num_stolen DESC;

-- Task 5- Create a map of the regions and color the regions based on the number of stolen vehicles

-- In Excel