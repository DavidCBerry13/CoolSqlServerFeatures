-- To run these queries, you need the WeatherStations and WeatherObservations
-- tables, which are both located in the Window Functions Directories


SELECT 
        s.StationCode,
		s.City,
		s.State,
		observations.ObservationDate,
		observations.DryBulbFarenheit As Temperature,
		observations.RelativeHumidity,
		observations.WindDirection,
		observations.WindSpeed
    FROM WeatherStations s
    INNER JOIN WeatherObservations observations
	    ON s.StationCode = observations.StationCode 
	WHERE
	    s.State = 'WI'
	    AND observations.ObservationDate > '2016-06-01'
		AND observations.ObservationDate < '2016-06-04'
	    FOR JSON AUTO;


-- Using FOR JSON PATH - Not how everything is flattened out
SELECT 
        s.StationCode,
		s.City,
		s.State,
		observations.ObservationDate,
		observations.DryBulbFarenheit As Temperature,
		observations.RelativeHumidity,
		observations.WindDirection,
		observations.WindSpeed
    FROM WeatherStations s
    INNER JOIN WeatherObservations observations
	    ON s.StationCode = observations.StationCode 
	WHERE
	    s.State = 'WI'
	    AND observations.ObservationDate > '2016-06-01'
		AND observations.ObservationDate < '2016-06-04'
	    FOR JSON PATH;


-- Creating a Child object with for path
SELECT 
        s.StationCode,
		s.City,
		s.State,
		observations.ObservationDate,
		observations.DryBulbFarenheit AS [Data.Temperature],
		observations.RelativeHumidity AS [Data.Relativehumidity],
		observations.WindDirection AS [Data.WindDirection],
		observations.WindSpeed AS [Data.WindSpeed]
    FROM WeatherStations s
    INNER JOIN WeatherObservations observations
	    ON s.StationCode = observations.StationCode 
	WHERE
	    s.State = 'WI'
	    AND observations.ObservationDate > '2016-06-01'
		AND observations.ObservationDate < '2016-06-04'
	    FOR JSON PATH;






SELECT 
        s.StationCode,
		s.City,
		s.State,		
		(
		    SELECT 
			    obsdata.ObservationDate AS [ObservationDate],
		        obsdata.DryBulbFarenheit AS [Temperature],
		        obsdata.RelativeHumidity AS [Relativehumidity],
		        obsdata.WindDirection AS [WindDirection],
		        obsdata.WindSpeed AS [WindSpeed]
			FROM WeatherObservations obsdata
			WHERE s.StationCode = obsdata.StationCode
		        AND obsdata.ObservationDate > '2016-06-01'
		        AND obsdata.ObservationDate < '2016-06-04'
			FOR JSON PATH
		) As ObservationData
    FROM WeatherStations s 
	WHERE
	    s.State = 'WI'
	FOR JSON PATH, ROOT('WisconsinWeather');