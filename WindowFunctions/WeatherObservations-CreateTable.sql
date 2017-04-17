CREATE TABLE WeatherObservations
(
	ObservationId     int IDENTITY(1,1) NOT NULL,
	StationCode       varchar(10)       NOT NULL,
	City              varchar(30)       NOT NULL,
	State             varchar(2)        NOT NULL,
	ObservationDate   datetime          NOT NULL,
	SkyCondition      varchar(30)       NULL,
	Visibility        decimal(8, 4)     NULL,
	DryBulbFarenheit  decimal(8, 4)     NULL,
	DryBulbCelsius    decimal(8, 4)     NULL,
	WetBulbFarenheit  decimal(8, 4)     NULL,
	WetBulbCelsius    decimal(8, 4)     NULL,
	DewPointFarenheit decimal(8, 4)     NULL,
	DewPointCelsius   decimal(8, 4)     NULL,
	RelativeHumidity  decimal(8, 4)     NULL,
	WindSpeed         decimal(8, 4)     NULL,
	WindDirection     varchar(10)       NULL,
	StationPressure   decimal(8, 4)     NULL,
	SeaLevelPressure  decimal(8, 4)     NULL,
	RecordType        varchar(12)       NULL,
	HourlyPrecip      decimal(8, 4)     NULL,
	Altimeter         decimal(8, 4)     NULL,
   CONSTRAINT PK_WeatherObservations 
       PRIMARY KEY (ObservationId)
);