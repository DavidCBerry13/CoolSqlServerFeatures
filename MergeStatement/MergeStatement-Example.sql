-- In this example the delete at the end is commented out, because we don't
-- want to delete records in our main table that are not in the stage table.
-- But you can see the syntax in case this is important to you

MERGE INTO Customers AS Target
USING (
    SELECT 
	    CustomerId,
		FirstName,
		LastName,
		DateOfBirth, 
		PhoneNumber,
		Email
	FROM CustomersStaging
) AS Staging
ON (Staging.CustomerId = Target.CustomerId)
    WHEN MATCHED THEN
        UPDATE SET
	        FirstName = Staging.FirstName,
		    LastName = Staging.LastName,
		    DateOfBirth = Staging.DateOfBirth,
		    PhoneNumber = Staging.PhoneNumber,
		    Email = Staging.Email
    WHEN NOT MATCHED BY Target THEN
        INSERT (CustomerId, FirstName, LastName, DateOfBirth, PhoneNumber, Email)
		    VALUES (CustomerId, FirstName, LastName, DateOfBirth, PhoneNumber, Email );
	--WHEN NOT MATCHED BY Staging THEN
	--    DELETE;