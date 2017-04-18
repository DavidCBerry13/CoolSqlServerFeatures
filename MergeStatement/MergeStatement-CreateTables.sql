-- Customers would be considers the primary data table in this example
-- and CustomersStaging a staging table where new data (like from a file)
-- is initially loaded into before being merged into the customers table

CREATE TABLE Customers
(
    CustomerId      VARCHAR(5)    NOT NULL,
	FirstName       VARCHAR(30)   NOT NULL,
	LastName        VARCHAR(30)   NOT NULL,
	DateOfBirth     DATE          NULL,
	PhoneNumber     VARCHAR(20)   NULL,
	Email           VARCHAR(50)   NULL,    
	CONSTRAINT PK_Customers
	    PRIMARY KEY (CustomerId)
);



CREATE TABLE CustomersStaging
(
    CustomerId      VARCHAR(5)    NOT NULL,
	FirstName       VARCHAR(30)   NOT NULL,
	LastName        VARCHAR(30)   NOT NULL,
	DateOfBirth     DATE          NULL,
	PhoneNumber     VARCHAR(20)   NULL,
	Email           VARCHAR(50)   NULL,    
	CONSTRAINT PK_CustomersStaging
	    PRIMARY KEY (CustomerId)
);