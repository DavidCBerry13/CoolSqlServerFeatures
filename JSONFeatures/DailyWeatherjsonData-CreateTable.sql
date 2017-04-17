CREATE TABLE dbo.DailyWeatherDataJson
(
    ObservationId    int IDENTITY(1,1) NOT NULL,
    StationCode      varchar(10)       NOT NULL,
    City             varchar(30)       NOT NULL,
    State            varchar(2)        NOT NULL,
    ObservationDate  date              NOT NULL,
    ObservationData  varchar(max)      NOT NULL,
    CONSTRAINT PK_DailyWeatherDataJson 
	    PRIMARY KEY (ObservationId)
);
GO

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
    WHERE City = 'Chicago'
    AND State = 'IL'
    AND ObservationDate = ('2016-07-15');
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
