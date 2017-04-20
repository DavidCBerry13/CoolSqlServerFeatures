CREATE TABLE WeatherStations
(
	StationCode    varchar(10) NOT NULL,
	City           varchar(30) NOT NULL,
	State          varchar(2) NOT NULL,
	Description    varchar(100) NOT NULL,
	Latitude       decimal(8, 6) NULL,
	Longitude      decimal(9, 6) NULL,
    CONSTRAINT PK_WeatherStations 
       PRIMARY KEY (StationCode)
);