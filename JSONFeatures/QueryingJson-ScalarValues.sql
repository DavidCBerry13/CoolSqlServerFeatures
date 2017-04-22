-- JSON_VALUE can be used to access scalar values inside of a JSON object
-- --------------------------------------------------------------------------
SELECT 
        ObservationId,
		StationCode,
		City,
		State,
		ObservationDate,
		JSON_VALUE(ObservationData, '$.dryBulbFarenheit') As Temperature,
		JSON_VALUE(ObservationData, '$.relativeHumidity') As Humidity,
		ObservationData
    FROM WeatherDataJson
	WHERE State = 'MN'
	    AND City = 'Minneapolis'
	    AND ObservationDate > '2016-08-15'
		AND ObservationDate < '2016-08-16';





-- You can also create a computed column to make it easier to query the data
-- The value is still stored in JSON, but will appear as a regular column on the table
-- -------------------------------------------------------------------------------------

ALTER TABLE WeatherDataJson
    ADD Temperature  AS (json_value(ObservationData,'$.dryBulbFarenheit'));

ALTER TABLE WeatehrDataJson
    ADD Humidity  AS (json_value(ObservationData,'$.relativeHumidity'));