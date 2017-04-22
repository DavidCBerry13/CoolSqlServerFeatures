-- 
-- JSON Demos - Part 2 - JSON Arrays
--
-- ------------------------------------------------------------------------------------------------


SELECT * 
    FROM DailyWeatherDataJson
	WHERE City = 'Minneapolis'
	    AND State = 'MN'
		AND ObservationDate = '2016-08-15';


SELECT 
        ObservationId,
		StationCode,
		City, 
		State,
		ObservationDate,
		JSON_VALUE(ObservationData, '$.weatherObservations[0].observationDateTime') AS ObservationTime,
		JSON_VALUE(ObservationData, '$.weatherObservations[0].dryBulbFarenheit') AS Temperature
    FROM DailyWeatherDataJson
	WHERE City = 'Minneapolis'
	    AND State = 'MN'
		AND ObservationDate = '2016-08-15';



SELECT 
        ObservationId,
		StationCode,
		City, 
		State,
		ObservationDate,
		JSON_QUERY(ObservationData, '$.weatherObservations') As Observations
    FROM DailyWeatherDataJson
	WHERE City = 'Minneapolis'
	    AND State = 'MN'
		AND ObservationDate = '2016-08-15';




-- This is a sample query to be able to pull the JSON array elements out and make them look
-- like rows
SELECT 
        ObservationId,
        StationCode,
        City,
        State,
        ObservationDate,        
        CONVERT(datetime, JSON_VALUE(Observations.[Value], '$.observationDateTime'), 126) As ObservationTime,
        JSON_VALUE(Observations.[Value], '$.dryBulbFarenheit') As Temperature,
        JSON_VALUE(Observations.[Value], '$.relativeHumidity') As Humidity,
        JSON_VALUE(Observations.[Value], '$.windDirection') As WindDIrection,
        JSON_VALUE(Observations.[Value], '$.windSpeed') As WindSpeed
    FROM DailyWeatherDataJson d
	CROSS APPLY OPENJSON(JSON_QUERY(ObservationData, '$.weatherObservations')) Observations
    WHERE City = 'Minneapolis'
    AND State = 'MN'
    AND ObservationDate = ('2016-08-15');
GO











-- Most likely, you will want to encapsulate such a query in a view which would look something like this.
CREATE VIEW DailyWeatherDataJsonView AS
SELECT
        ObservationId,
        StationCode,
        City,
        State,
        ObservationDate,        
        CONVERT(datetime, JSON_VALUE(Observations.[Value], '$.observationDateTime'), 126) As ObservationTime,
        JSON_VALUE(Observations.[Value], '$.dryBulbFarenheit') As Temperature,
        JSON_VALUE(Observations.[Value], '$.relativeHumidity') As Humidity,
        JSON_VALUE(Observations.[Value], '$.windDirection') As WindDIrection,
        JSON_VALUE(Observations.[Value], '$.windSpeed') As WindSpeed,
		ObservationData
    FROM DailyWeatherDataJson d
	CROSS APPLY OPENJSON(JSON_QUERY(ObservationData, '$.weatherObservations')) Observations;