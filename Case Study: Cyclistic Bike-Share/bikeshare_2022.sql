-- Combining all 12-month bike-share datasets and creating a new table named "bikeshare_2022"

USE [Bike-Share]

SELECT 
	* 
INTO 
	bikeshare_2022
FROM 
	(
	SELECT *
	FROM [Bike-Share].[dbo].[202201-divvy-tripdata]

	UNION
	
	SELECT *
	FROM [Bike-Share].[dbo].[202202-divvy-tripdata]

	UNION
	
	SELECT *
	FROM [Bike-Share].[dbo].[202203-divvy-tripdata]

	UNION
	
	SELECT *
	FROM [Bike-Share].[dbo].[202204-divvy-tripdata]

	UNION
	
	SELECT *
	FROM [Bike-Share].[dbo].[202205-divvy-tripdata]

	UNION
	
	SELECT *
	FROM [Bike-Share].[dbo].[202206-divvy-tripdata]

	UNION
	
	SELECT *        
	FROM [Bike-Share].[dbo].[202207-divvy-tripdata]

	UNION
	
	SELECT *
	FROM [Bike-Share].[dbo].[202208-divvy-tripdata]

	UNION
	
	SELECT *
	FROM [Bike-Share].[dbo].[202209-divvy-tripdata]

	UNION
	
	SELECT *
	FROM [Bike-Share].[dbo].[202210-divvy-tripdata]

	UNION
	
	SELECT *
	FROM [Bike-Share].[dbo].[202211-divvy-tripdata]

	UNION
	
	SELECT *
	FROM [Bike-Share].[dbo].[202212-divvy-tripdata]
	) 
	AS bikeshare_2022


---------- Data Cleaning Process ---------- 

-- Checking max and min number to see if there are any outlier (negtive number) in 'started' and 'ended' time. 


SELECT 
	MAX(ride_length) AS max_length, MIN(ride_length) AS min_length
FROM 
	[Bike-Share].[dbo].[Original]


-- Finding outlier - any outlier in 'started' > and = 'ended' time. 

SELECT 
	started_at, ended_at
FROM
	[Bike-Share].[dbo].[Original]
WHERE
	started_at > ended_at OR
	started_at = ended_at



-- Removing outlier with ride_length is less than 60 seconds and creating a temporary table 'rm_outliers'.


USE
	[Bike-Share]
	
SELECT 
	*
INTO
	rm_outliers
FROM
	[Bike-Share].[dbo].[bikeshare_2022]
WHERE
	DATEDIFF(second, started_at, ended_at) > 59;

--  Removing duplicates and null values 
-- Create a new temp table "bikeshare_2022"

USE
    [Bike-Share]    
SELECT 
	DISTINCT ride_id, 
	started_at,
    ended_at,
	ride_length
	day_of_week,
    start_station_name, 
    start_station_id,
    end_station_name,
    end_station_id,
    start_lat,
    start_lng,
    end_lat,
    end_lng,
    member_casual
INTO 
    [Bike-Share].[dbo].[bikeshare_2022]
	
FROM
	[Bike-Share].[dbo].[rm_outliers] -- The table has been deleted.
WHERE 
	ride_id IS NOT NULL
    AND rideable_type IS NOT NULL
    AND started_at IS NOT NULL
    AND ended_at IS NOT NULL
	AND ride_length IS NOT NULL
	AND day_of_week IS NOT NULL
    AND start_station_name IS NOT NULL
	AND start_station_id IS NOT NULL
	AND end_station_name IS NOT NULL
	AND end_station_id IS NOT NULL
	AND start_lat IS NOT NULL
	AND start_lng IS NOT NULL
	AND end_lat IS NOT NULL
	AND end_lng IS NOT NULL
	AND member_casual IS NOT NULL






---------- Analysis ----------

-- Adding and calculalting a new column - "ride_length"

ALTER TABLE 
	bikeshare_2022
ADD 
	ride_length INT

UPDATE 
	[Bike-Share].[dbo].[bikeshare_2022]
SET
	ride_length = DATEDIFF(MINUTE, started_at, ended_at)


-- Adding and calculalting a new column - "day_of_week"

ALTER TABLE 
	bikeshare_2022
ADD 
	day_of_week nvarchar(10)

UPDATE 
	[Bike-Share].[dbo].[bikeshare_2022]
SET day_of_week =
	CASE DATEPART(WEEKDAY, started_at)
	  WHEN 1 THEN 'Sunday'
	  WHEN 2 THEN 'Monday'
	  WHEN 3 THEN 'Tuesday'
	  WHEN 4 THEN 'Wednesday'
	  WHEN 5 THEN 'Thursday'
	  WHEN 6 THEN 'Friday'
	  WHEN 7 THEN 'Saturday'
	END;
	

-- Calculating the average ride_length for casusal and member riders by day_of_week

SELECT 
    member_casual,
	day_of_week, 
    AVG(ride_length) AS avg_length
FROM 
	[Bike-Share].[dbo].[bikeshare_2022]
GROUP BY
    member_casual,
	day_of_week
ORDER BY
    member_casual


-- Calculating the max ride_length

SELECT 
    day_of_week,
	MAX(DATEDIFF(HOUR, started_at, ended_at)) AS max_ride_length
FROM 
	[Bike-Share].[dbo].[bikeshare_2022]
GROUP BY
    day_of_week
ORDER BY
    max_ride_length DESC


-- Calculating the number of trips by type of riders.

SELECT 
	member_casual, COUNT(ride_id) AS num_ride
FROM 
	[Bike-Share].[dbo].[bikeshare_2022]
GROUP BY
	member_casual
ORDER BY
	member_casual, num_ride DESC


-- Calculating the number of trips by type of riders and by day_of_week.

SELECT 
	member_casual, day_of_week, COUNT(ride_id) AS num_ride
FROM 
	[Bike-Share].[dbo].[bikeshare_2022]
GROUP BY
	member_casual,
	day_of_week
ORDER BY
	member_casual, num_ride DESC


-- Calculating number of different rideable_type for riders.

SELECT
    member_casual,
    rideable_type,
    COUNT(rideable_type) AS num_bike_type
FROM 
    [Bike-Share].[dbo].[bikeshare_2022]
GROUP BY
    member_casual,
    rideable_type
ORDER BY
    member_casual,
    num_bike_type DESC; 




-- Calculating the start and end locations of trips for both member and casual riders

SELECT 
   member_casual,
   start_station_name, 
   end_station_name, 
   COUNT(*) AS num_trips
FROM 
    [Bike-Share].[dbo].[bikeshare_2022]
GROUP BY 
	member_casual,
    start_station_name, 
    end_station_name
ORDER BY 
    member_casual,
    num_trips DESC;


-- Calculating ride frequency by month for both group of riders to identify popular months

SELECT 
  member_casual, 
  DATEPART(MONTH, started_at) AS month,
  COUNT(*) AS total_rides 
FROM 
  [Bike-Share].[dbo].[bikeshare_2022]
WHERE 
  member_casual = 'casual'
GROUP BY 
  member_casual, 
  DATEPART(MONTH, started_at)
ORDER By
    total_rides DESC

---------- END ---------


-- OPTIONAL --

-- Calculating distance

SELECT 
    member_casual, geography::Point(start_lat, start_lng, 4326).STDistance(geography::Point(end_lat, end_lng, 4326)) / 
	1000 as distance_in_km
FROM 
    [Bike-Share].[dbo].[bikeshare_2022]
WHERE
	 [start_station_id] IS NOT NULL
     AND [end_station_id] IS NOT NULL
     AND [start_lat] IS NOT NULL
     AND [start_lng] IS NOT NULL
     AND [end_lat] IS NOT NULL
     AND [end_lng] IS NOT NULL
ORDER BY
    distance_in_km DESC

 |
-------------------------------------------------------
SELECT start_station_name, COUNT(*) AS station_count
FROM [Bike-Share].[dbo].[bikeshare_2022]
GROUP BY start_station_name
ORDER BY station_count DESC
OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY;


  