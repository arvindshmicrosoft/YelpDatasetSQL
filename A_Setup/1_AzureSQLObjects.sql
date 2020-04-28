/*
This sample code shows how to import and work with the Yelp Dataset (https://www.yelp.com/dataset/) using
the Microsoft SQL family of products and services. Tested with Azure SQL DB and with SQL Server 2019

Please first review the terms of use and documenation for the Yelp dataset
at https://www.yelp.com/dataset/documentation/main

Your use of these sample T-SQL scripts is also subject to standard license terms and legal terms - see footer for those
*/

-- ***** RUN IN SQLCMD MODE FROM SSMS *****
-- ***** RUN THIS SCRIPT ONLY IF YOU ARE USING AZURE SQL *****
IF SERVERPROPERTY ('edition') != 'SQL Azure'
	RAISERROR('This script is only for Azure SQL DB', 17, 1)
GO

-- For convenience let's select Azure SQL Hyperscale with 2 vCores
-- We will later leverage the quick scaling capability of Hyperscale to scale up
ALTER DATABASE YelpReviews
MODIFY (SERVICE_OBJECTIVE = 'HS_Gen5_2')
GO

-- ***** Change the following to match a blob storage account where the
-- Yelp dataset JSON files have been extracted. You also need to copy
-- the LineByLine.xml from this repo to that blob container for
-- bulk import to work ****
:setvar blobContainer 'https://<<storage account name>>.blob.core.windows.net/<<container name>>'
:setvar blobSAS '<<SAS goes here, without the leading ? mark>>'
:setvar blobDataSourceName 'YelpDataContainer'

-- ***** If your files are within a "sub-folder" in the above blob storage
-- container, please specify that below. In the examples below, it is assumed
-- that the files are within a sub-folder called Yelp/ ******
:setvar formatFilePath 'Yelp/LineByLine.xml'
:setvar businessJSONFilePath 'Yelp/yelp_academic_dataset_business.json'
:setvar tipJSONFilePath 'Yelp/yelp_academic_dataset_tip.json'
:setvar userJSONFilePath 'Yelp/yelp_academic_dataset_user.json'
:setvar reviewJSONFilePath 'Yelp/yelp_academic_dataset_review.json'
:setvar checkinJSONFilePath 'Yelp/yelp_academic_dataset_checkin.json'

CREATE MASTER KEY
GO

CREATE DATABASE SCOPED CREDENTIAL BlobSASCred
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = $(blobSAS);
GO

CREATE EXTERNAL DATA SOURCE YelpDataContainer
    WITH (
        TYPE = BLOB_STORAGE,
        LOCATION = $(blobContainer),
        CREDENTIAL = BlobSASCred
    );
GO

CREATE OR ALTER VIEW dbo.BusinessJSON
AS
SELECT j.SingleLine
FROM OPENROWSET (
   BULK $(businessJSONFilePath),
   DATA_SOURCE = $(blobDataSourceName),
   FORMATFILE= $(formatFilePath),
   FORMATFILE_DATA_SOURCE = $(blobDataSourceName),
   CODEPAGE = '65001'
	) as j
GO

CREATE OR ALTER VIEW dbo.TipJSON
AS
SELECT j.SingleLine
FROM OPENROWSET (
   BULK $(tipJSONFilePath),
   DATA_SOURCE = $(blobDataSourceName),
   FORMATFILE= $(formatFilePath),
   FORMATFILE_DATA_SOURCE = $(blobDataSourceName),
   CODEPAGE = '65001'
	) as j
GO

CREATE OR ALTER VIEW dbo.UserJSON
AS
SELECT j.SingleLine
FROM OPENROWSET (
   BULK $(userJSONFilePath),
   DATA_SOURCE = $(blobDataSourceName),
   FORMATFILE= $(formatFilePath),
   FORMATFILE_DATA_SOURCE = $(blobDataSourceName),
   CODEPAGE = '65001'
	) as j
GO

CREATE OR ALTER VIEW dbo.ReviewJSON
AS
SELECT j.SingleLine
FROM OPENROWSET (
   BULK $(reviewJSONFilePath),
   DATA_SOURCE = $(blobDataSourceName),
   FORMATFILE= $(formatFilePath),
   FORMATFILE_DATA_SOURCE = $(blobDataSourceName),
   CODEPAGE = '65001'
	) as j
GO

CREATE OR ALTER VIEW dbo.CheckinJSON
AS
SELECT j.SingleLine
FROM OPENROWSET (
   BULK $(checkinJSONFilePath),
   DATA_SOURCE = $(blobDataSourceName),
   FORMATFILE= $(formatFilePath),
   FORMATFILE_DATA_SOURCE = $(blobDataSourceName),
   CODEPAGE = '65001'
	) as j
GO

/*
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

This sample code is not supported under any Microsoft standard support program or service.
The entire risk arising out of the use or performance of the sample scripts and documentation remains with you.
In no event shall Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts
be liable for any damages whatsoever (including, without limitation, damages for loss of business profits,
business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability
to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages.
*/