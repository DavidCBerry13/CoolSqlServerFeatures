-- Creates just the plain table
--    JSON will be stored in the ObservationData column
CREATE TABLE WeatherDataJson
(
	ObservationId    int IDENTITY(1,1)  NOT NULL,
	StationCode      varchar(10)        NOT NULL,
	City             varchar(30)        NOT NULL,
	State            varchar(2)         NOT NULL,
	ObservationDate  datetime           NOT NULL,
	ObservationData  varchar(4000)      NOT NULL,
    CONSTRAINT PK_WeatherDataJson 
	    PRIMARY KEY (ObservationId)
);


-- This is how you would create a computed (virtual) column to expose a JSON property
-- as a column on the table
-- ------------------------------------------------------------------------------------------
--ALTER TABLE WeatherDataJson
--    ADD Temperature  AS (json_value(ObservationData,'$.dryBulbFarenheit'));

--ALTER TABLE WeatehrDataJson
--    ADD Humidity  AS (json_value(ObservationData,'$.relativeHumidity'));



-- To create the computed columns from the start, youwould use this create table syntax
-- ------------------------------------------------------------------------------------------
--CREATE TABLE WeatherDataJson
--(
--	ObservationId    int IDENTITY(1,1)      NOT NULL,
--	StationCode      varchar(10)            NOT NULL,
--	City             varchar(30)            NOT NULL,
--	State            varchar(2)             NOT NULL,
--	ObservationDate  datetime               NOT NULL,
--	ObservationData  varchar(4000)          NOT NULL,
--	Temperature  AS (json_value(ObservationData,'$.dryBulbFarenheit')),
--	Humidity  AS (json_value(ObservationData,'$.relativeHumidity')),
--    CONSTRAINT PK_WeatherDataJson 
--	    PRIMARY KEY (ObservationId)
--);