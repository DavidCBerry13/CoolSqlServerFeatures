
-- A most basic table.  A primary key and a column to store our JSON obect in
-- ------------------------------------------------------------------------------
CREATE TABLE BasicWeatherDataJson
(
    ObservationId     INT IDENTITY(1,1)  NOT NULL,
    ObservationData   VARCHAR(4000)      NOT NULL,
    CONSTRAINT PK_BasicWeatherDataJson
        PRIMARY KEY (ObservationId)
)


-- This gets the data into the table from the main WeatherDataJson table
-- ------------------------------------------------------------------------------
INSERT INTO BasicWeatherDataJson (ObservationData)
    SELECT ObservationData 
	FROM WeatherDataJson


-- If we don't do anything else, we can write queries like this to pull values out
-- of our JSON and have them show up as columns in our result set
-- --------------------------------------------------------------------------------
SELECT 
        ObservationId,
        JSON_VALUE(ObservationData, '$.stationCode') As StationCode,
        JSON_VALUE(ObservationData, '$.location.city') As City,		
        JSON_VALUE(ObservationData, '$.location.state') As State,
        CONVERT(datetime2(3), JSON_VALUE(ObservationData, '$.observationDateTime'), 126) As ObservationDate,		
        JSON_VALUE(ObservationData, '$.dryBulbFarenheit') As Temperature,
        JSON_VALUE(ObservationData, '$.relativeHumidity') As Humidity
    FROM BasicWeatherDataJson
    WHERE
        JSON_VALUE(ObservationData, '$.location.city') = 'Appleton'
        AND JSON_VALUE(ObservationData, '$.location.state') = 'WI'
        AND CONVERT(datetime2(3), JSON_VALUE(ObservationData, '$.observationDateTime'), 126) > '2016-07-01'
        AND CONVERT(datetime2(3), JSON_VALUE(ObservationData, '$.observationDateTime'), 126) < '2016-07-02';

		
-- We can make our lives easier though by defining some virtual (computed) columns
-- These will pull the appropriate value out of the JSON real time when our query
-- is run, so it is a little easier to write our query.  Basically this makes our
-- data appear relational, even though it is stored as JSON
-- ----------------------------------------------------------------------------------
ALTER TABLE BasicWeatherDataJson
    ADD StationCode AS JSON_VALUE(ObservationData, '$.stationCode');

ALTER TABLE BasicWeatherDataJson
    ADD City AS JSON_VALUE(ObservationData, '$.location.city');
	    
ALTER TABLE BasicWeatherDataJson
    ADD State AS JSON_VALUE(ObservationData, '$.location.state');

ALTER TABLE BasicWeatherDataJson
    ADD ObservationDate AS CONVERT(datetime2(3), JSON_VALUE(ObservationData, '$.observationDateTime'), 126);

ALTER TABLE BasicWeatherDataJson
    ADD Temperature AS JSON_VALUE(ObservationData, '$.dryBulbFarenheit');

ALTER TABLE BasicWeatherDataJson
    ADD Humidity AS JSON_VALUE(ObservationData, '$.relativeHumidity');

	
-- Note how this query is much simpler
-- However, this query will not perform very well since SQL Server has to do
-- full table scan to process the WHERE clause and find out data
-- ----------------------------------------------------------------------------
SELECT 
        ObservationId,
        StationCode,
        City,		
        State,
        ObservationDate,		
        Temperature,
        Humidity
    FROM BasicWeatherDataJson
    WHERE
        City = 'Appleton'
        AND State = 'WI'
        AND ObservationDate > '2016-07-01'
        AND ObservationDate < '2016-07-02';
		
		
-- What we can do though is create an index over the computed columns. 
-- SQL Server can then use these indexes like any other indexes when
-- processing WHERE clauses or JOIN conditions
-- ----------------------------------------------------------------------------
CREATE INDEX IX_BasicWeatherJson_ObservationDate_StationCode
    ON BasicWeatherDataJson (ObservationDate, StationCode);

CREATE INDEX IX_BasicWeatherJson_ObservationDate_State_City
    ON BasicWeatherDataJson (ObservationDate, State, City);		