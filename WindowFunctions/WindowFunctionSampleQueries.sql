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
   
		
		
		
-- Third Example
-- Rank Function
-- ----------------------------------------------------------------------

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
-- This has a different PARTITION BY in the RANK, so we get the highest
-- temp days, regardless of where in the state they occured
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
    City, Year, Month, Day, DailyHighTemp,
	RANK() OVER (ORDER BY DailyHighTemp DESC) As TemperatureRank
	FROM DailyHighTemps;

	
	
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
	
	
	