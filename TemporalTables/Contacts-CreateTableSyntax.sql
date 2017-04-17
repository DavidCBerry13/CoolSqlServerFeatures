CREATE TABLE Contacts
(
    ContactID        INT IDENTITY(1,1)      NOT NULL,
	FirstName        VARCHAR(30)            NOT NULL,
	LastName         VARCHAR(30)            NOT NULL,
	CompanyName      VARCHAR(30)            NULL,
	PhoneNumber      VARCHAR(20)            NULL,
	Email            VARCHAR(50)            NULL,
	ValidFrom        DATETIME2(3) GENERATED ALWAYS AS ROW START,
    ValidTo          DATETIME2(3) GENERATED ALWAYS AS ROW END,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo), 
	CONSTRAINT PK_Contacts PRIMARY KEY (ContactId)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.ContactsHistory));