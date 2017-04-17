-- Plain old SQL
-- Gets just the records that are 'active' (current) right now
SELECT * 
    FROM Contacts;

	
-- Get Records valid in a certain time period
SELECT *
    FROM Contacts
        FOR SYSTEM_TIME    
            BETWEEN '2017-04-11 12:00:00.0000000' AND '2017-04-13 12:00:00.0000000'   
	ORDER BY ValidFrom;  


-- Gets records active on a certain date
SELECT *
    FROM Contacts
        FOR SYSTEM_TIME    
            AS OF '2017-04-12 14:00:00.0000000';

			
-- Gets all records
SELECT *
    FROM Contacts
        FOR SYSTEM_TIME    
            ALL;
