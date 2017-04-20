-- First Example  
-- Using a Max Function, two different partition types
-- --------------------------------------------------------------------------------
SELECT DISTINCT
        YEAR(ObservationDate) AS Year,
	    MONTH(ObservationDate) AS Month,
		DAY(ObservationDate) As Day,
		MAX(o.DryBulbFarenheit) OVER (PARTITION BY YEAR(ObservationDate), MONTH(ObservationDate)) As MonthlyHighTemp,
		MAX(o.DryBulbFarenheit) OVER (PARTITION BY YEAR(ObservationDate), MONTH(ObservationDate), DAY(ObservationDate)) As DailyHighTemp
    FROM WeatherObservations o
	WHERE
	    State = 'MN'
		AND City = 'Minneapolis'
		AND ObservationDate BETWEEN '2016-05-01' AND '2016-06-01';
		
		
-- Second Example
-- FIRST VALUE (Show Ordering in Set)
-- Show Daily High Temperature and the time that it occurred
-- This is nice because in a GROUP BY we have to join back to the original data set
-- ------------------------------------------------------------------------------------

SELECT DISTINCT
        YEAR(ObservationDate) AS Year,
	    MONTH(ObservationDate) AS Month,
		DAY(ObservationDate) As Day,
		FIRST_VALUE(o.DryBulbFarenheit) OVER 
		    (PARTITION BY YEAR(ObservationDate), MONTH(ObservationDate), DAY(ObservationDate) 
			ORDER BY o.DryBulbFarenheit DESC) As DailyHighTemp,
		FIRST_VALUE(o.ObservationDate) OVER 
		    (PARTITION BY YEAR(ObservationDate), MONTH(ObservationDate), DAY(ObservationDate) 
			ORDER BY o.DryBulbFarenheit DESC) As HighTempTime
    FROM WeatherObservations o
	WHERE
	    State = 'MN'
		AND City = 'Minneapolis'
		AND o.ObservationDate BETWEEN '2016-05-01' AND '2016-06-01';
   
		
		
-- Third Example - Cannot use Window Function in WHERE clause
-- -------------------------------------------------------------------------------		
		
-- This will fail
SELECT DISTINCT
        YEAR(ObservationDate) AS Year,
	    MONTH(ObservationDate) AS Month,
		DAY(ObservationDate) As Day,		
		MAX(o.DryBulbFarenheit) OVER (PARTITION BY YEAR(ObservationDate), MONTH(ObservationDate), DAY(ObservationDate)) As DailyHighTemp
    FROM WeatherObservations o
	WHERE
	    State = 'MN'
		AND City = 'Minneapolis'
		AND ObservationDate BETWEEN '2016-01-01' AND '2016-12-31'
		MAX(o.DryBulbFarenheit) OVER (PARTITION BY YEAR(ObservationDate), MONTH(ObservationDate), DAY(ObservationDate)) > 90;
		
		
		
		
-- So we can introduce a Common Table Expression
		
WITH DailyHighTemps AS
(
    SELECT DISTINCT
        YEAR(ObservationDate) AS Year,
	    MONTH(ObservationDate) AS Month,
		DAY(ObservationDate) As Day,		
		MAX(o.DryBulbFarenheit) OVER (PARTITION BY YEAR(ObservationDate), MONTH(ObservationDate), DAY(ObservationDate)) As DailyHighTemp
    FROM WeatherObservations o
	WHERE
	    State = 'MN'
		AND City = 'Minneapolis'
		AND ObservationDate BETWEEN '2016-01-01' AND '2016-12-31'
)
SELECT * 
    FROM DailyHighTemps
	WHERE DailyHighTemp > 90

		
		
		
		
-- Fourth Example
-- Rank Function
-- ----------------------------------------------------------------------

-- This is the rank function for just one city to show how it works
WITH DailyHighTemps AS
(
    SELECT DISTINCT
        YEAR(ObservationDate) AS Year,
	    MONTH(ObservationDate) AS Month,
		DAY(ObservationDate) As Day,		
		MAX(o.DryBulbFarenheit) OVER (PARTITION BY YEAR(ObservationDate), MONTH(ObservationDate), DAY(ObservationDate)) As DailyHighTemp
    FROM WeatherObservations o
	WHERE
	    State = 'MN'
		AND City = 'Minneapolis'
		AND ObservationDate BETWEEN '2016-01-01' AND '2016-12-31'
)
SELECT 
        Year,
		Month,
		Day,
		DailyHighTemp,
		RANK() OVER (ORDER BY DailyHighTemp DESC)  As HottestDayRank
    FROM DailyHighTemps
	





-- This query just gets the daily high temperature for each city and date
SELECT DISTINCT
        City,
		YEAR(ObservationDate) AS Year,
	    MONTH(ObservationDate) AS Month,
		DAY(ObservationDate) As Day,		
		MAX(o.DryBulbFarenheit) OVER 
		    (PARTITION BY City, YEAR(ObservationDate), MONTH(ObservationDate), DAY(ObservationDate) ) As DailyHighTemp
    FROM WeatherObservations o
	WHERE
	    State = 'WI'
		AND o.ObservationDate BETWEEN '2016-01-01' AND '2017-01-01'
	ORDER BY 
	    City,
		DailyHighTemp DESC;

-- Here we are getting the 5 hottest days for each city for the year.

WITH DailyTemps AS
(
    SELECT DISTINCT
        City,
		YEAR(ObservationDate) AS Year,
	    MONTH(ObservationDate) AS Month,
		DAY(ObservationDate) As Day,		
		MAX(o.DryBulbFarenheit) OVER 
		    (PARTITION BY City, YEAR(ObservationDate), MONTH(ObservationDate), DAY(ObservationDate) ) As DailyHighTemp,
		MIN(o.DryBulbFarenheit) OVER 
		    (PARTITION BY City, YEAR(ObservationDate), MONTH(ObservationDate), DAY(ObservationDate) ) As DailyLowTemp
    FROM WeatherObservations o
	WHERE
	    State = 'WI'
		AND o.ObservationDate BETWEEN '2016-01-01' AND '2017-01-01'
),
RankedDailyHighs AS
(
SELECT
    City, Year, Month, Day, DailyLowTemp,
	RANK() OVER (PARTITION BY City ORDER BY DailyLowTemp) As RankOrder
FROM DailyTemps
)
SELECT * FROM RankedDailyHighs
    WHERE RankOrder <= 5




-- Warmest days across the state (vary our rank partition)
-- Shows ranking in terms of across the state and for that city
-- Uses DENSE_RANK, which has no gaps
-- ----------------------------------------------------------------------------------
WITH DailyHighTemps AS
(
    SELECT DISTINCT
        City,
		YEAR(ObservationDate) AS Year,
	    MONTH(ObservationDate) AS Month,
		DAY(ObservationDate) As Day,		
		MAX(o.DryBulbFarenheit) OVER 
		    (PARTITION BY City, YEAR(ObservationDate), MONTH(ObservationDate), DAY(ObservationDate) ) As DailyHighTemp
    FROM WeatherObservations o
	WHERE
	    State = 'WI'
		AND o.ObservationDate BETWEEN '2016-01-01' AND '2017-01-01'
)
SELECT 
    City, 
	Year, 
	Month, 
	Day, 
	DailyHighTemp,
	DENSE_RANK() OVER (ORDER BY DailyHighTemp DESC) As StateTemperatureRank,
	DENSE_RANK() OVER (PARTITION BY City ORDER BY DailyHighTemp DESC) As CityRank
FROM DailyHighTemps
ORDER BY DailyHighTemp DESC;

	
	
-- Days with the highest low temp (the yuck factor when it doesn't cool off at night)
-- This shows how you can answer interesting questions by just playing with your sort order
-- ------------------------------------------------------------------------------------------------
WITH DailyLowTemps AS
(
SELECT DISTINCT
        s.City,
		YEAR(ObservationDate) AS Year,
	    MONTH(ObservationDate) AS Month,
		DAY(ObservationDate) As Day,		
		MIN(o.DryBulbFarenheit) OVER 
		    (PARTITION BY s.City, YEAR(ObservationDate), MONTH(ObservationDate), DAY(ObservationDate) ) As DailyLowTemp
    FROM WeatherObservations o
	INNER JOIN WeatherStations s
	    ON o.StationCode = s.StationCode
	WHERE
	    s.State = 'WI'
		AND o.ObservationDate BETWEEN '2016-01-01' AND '2017-01-01'
)
SELECT 
    City, Year, Month, Day, DailyLowTemp,
	RANK() OVER (ORDER BY DailyLowTemp DESC) As TemperatureRank
	FROM DailyLowTemps;


	
-- Lead/Lag Functions
-- Biggest Change from previous day
-- Note use of two common table expressions as well
-- -----------------------------------------------------------------------	
WITH DailyHighTemps AS
(
    SELECT DISTINCT
        City,
		YEAR(ObservationDate) AS Year,
	    MONTH(ObservationDate) AS Month,
		DAY(ObservationDate) As Day,		
		MAX(o.DryBulbFarenheit) OVER 
		    (PARTITION BY City, YEAR(ObservationDate), MONTH(ObservationDate), DAY(ObservationDate) ) As DailyHighTemp
    FROM WeatherObservations o
	WHERE
	    State = 'WI'
		AND o.ObservationDate BETWEEN '2016-01-01' AND '2017-01-01'
),
TempChanges AS
(
    SELECT 
        City,
        Year,
        Month,
        Day, 
        DailyHighTemp,
        LAG(DailyHighTemp) OVER (PARTITION BY City ORDER BY Year, Month, Day) As PreviousDayHigh,
        DailyHighTemp - LAG(DailyHighTemp) OVER (PARTITION BY City ORDER BY Year, Month, Day) TempChangeFromPreviousDay
    FROM DailyHighTemps
)
SELECT 
    *,
	RANK() OVER (ORDER BY TempChangeFromPreviousDay DESC) As TempChangeRank
	FROM TempChanges
	WHERE PreviousDayHigh IS NOT NULL
	ORDER BY TempChangeRank;		
	
	
	
	
	
-- Find the 50th percentile of a continuous distribution
	
WITH DailyHighTemps AS
(
    SELECT DISTINCT
	    State,
        City,
		YEAR(ObservationDate) AS Year,
	    MONTH(ObservationDate) AS Month,
		DAY(ObservationDate) As Day,		
		MAX(o.DryBulbFarenheit) OVER 
		    (PARTITION BY State, City, YEAR(ObservationDate), MONTH(ObservationDate), DAY(ObservationDate) ) As DailyHighTemp,
		MIN(o.DryBulbFarenheit) OVER 
		    (PARTITION BY State, City, YEAR(ObservationDate), MONTH(ObservationDate), DAY(ObservationDate) ) As DailyLowTemp
    FROM WeatherObservations o
	WHERE
	   o.ObservationDate BETWEEN '2016-01-01' AND '2017-01-01'
)
SELECT DISTINCT
        State,
		City,
		PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY DailyHighTemp) OVER (PARTITION BY State, City) As MedianHighTemp
    FROM DailyHighTemps
	ORDER BY MedianHighTemp	