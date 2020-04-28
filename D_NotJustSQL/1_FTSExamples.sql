/*
This sample code shows how to import and work with the Yelp Dataset (https://www.yelp.com/dataset/) using
the Microsoft SQL family of products and services. Tested with Azure SQL DB and with SQL Server 2019

Please first review the terms of use and documenation for the Yelp dataset
at https://www.yelp.com/dataset/documentation/main

Your use of these sample T-SQL scripts is also subject to standard license terms and legal terms - see footer for those
*/

USE [YelpReviews]
GO

ALTER TABLE Business
ALTER COLUMN business_id varchar(100) NOT NULL
GO

CREATE UNIQUE NONCLUSTERED INDEX [UK_BusinessId] ON [dbo].[Business]
(
	[business_id] ASC
)
GO

CREATE FULLTEXT CATALOG [YelpFT]
WITH ACCENT_SENSITIVITY = ON
GO

CREATE FULLTEXT INDEX ON [dbo].[Business]
    ([attributes] LANGUAGE 'English', [business_address] LANGUAGE 'English', [business_hours] LANGUAGE 'English', [business_name] LANGUAGE 'English', [categories] LANGUAGE 'English', [neighborhood] LANGUAGE 'English')
    KEY INDEX [UK_BusinessId]
    ON ([YelpFT], FILEGROUP [PRIMARY])
    WITH CHANGE_TRACKING AUTO, STOPLIST SYSTEM;
GO

-- Check to see if the Index population has completed
SELECT *
FROM sys.dm_fts_index_population
WHERE  database_id = db_id('YelpReviews')
    AND table_id = object_id('Business');
GO

-- Sample query on address
-- Use the estimated execution plan to illustrate the fact that the fulltext index is being used
SELECT *
FROM Business
-- WHERE business_address LIKE '%Major Mackenzie Drive%'
where CONTAINS (business_address, 'Major AND Mackenzie AND Drive')
GO

-- Example with CONTAINSTABLE so that the rank can be obtained and we (in this case) filter by top 10 for example
SELECT *
FROM Business AS B INNER JOIN
    CONTAINSTABLE(Business, business_address, 'Major AND Mackenzie AND Drive', 10) AS CT
    ON B.business_id = CT.[KEY];
GO

-- Look at another column using FTS, this time use PF Changs
-- This is spelt as PF Changs sometimes but mostly P.F. Chang's
-- It is interesting to know that FTS will behave ("correctly", from a human point of view)
-- retrieve all the occurrences of P.F. Chang's also.
SELECT *
FROM Business
-- WHERE business_name LIKE '%PF Chang%'
where CONTAINS (business_name, 'PF AND Chang''s')
GO
