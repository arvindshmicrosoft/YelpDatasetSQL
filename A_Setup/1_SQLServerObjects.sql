/*
This sample code shows how to import and work with the Yelp Dataset (https://www.yelp.com/dataset/) using
the Microsoft SQL family of products and services. Tested with Azure SQL DB and with SQL Server 2019

Please first review the terms of use and documenation for the Yelp dataset
at https://www.yelp.com/dataset/documentation/main

Your use of these sample T-SQL scripts is also subject to standard license terms and legal terms - see footer for those
*/

-- Skip this statement if you already have a database
CREATE DATABASE YelpReviews
GO

-- ***** RUN IN SQLCMD MODE FROM SSMS *****
-- ***** RUN THIS SCRIPT ONLY IF YOU ARE USING SQL SERVER ****
IF SERVERPROPERTY ('edition') = 'SQL Azure'
	RAISERROR('This script is for SQL Server - please use the Azure SQL DB version instead', 17, 1)
GO

-- ***** Please change the folder path below to where the extracted JSON files are placed *****
:setvar dataFolder "C:\YelpDatasetSQLServerData"
-- ***** Please change the folder path below to where the extracted JSON files are placed *****
:setvar repoFolder "C:\workarea\YelpDatasetSQLServer"
GO

CREATE OR ALTER VIEW dbo.BusinessJSON
AS
	SELECT j.SingleLine
	FROM OPENROWSET (BULK '$(dataFolder)\yelp_academic_dataset_business.json'
	,FORMATFILE = '$(repoFolder)\LineByLine.xml'
	,CODEPAGE = '65001'
	) as j
GO

CREATE OR ALTER VIEW dbo.TipJSON
AS
	SELECT j.SingleLine
	FROM OPENROWSET (BULK '$(dataFolder)\yelp_academic_dataset_tip.json'
	,FORMATFILE = '$(repoFolder)\LineByLine.xml'
	,CODEPAGE = '65001'
	) as j
GO

CREATE OR ALTER VIEW dbo.UserJSON
AS
	SELECT j.SingleLine
	FROM OPENROWSET (BULK '$(dataFolder)\yelp_academic_dataset_user.json'
	,FORMATFILE = '$(repoFolder)\LineByLine.xml'
	,CODEPAGE = '65001'
	) as j
GO

CREATE OR ALTER VIEW dbo.ReviewJSON
AS
	SELECT j.SingleLine
	FROM OPENROWSET (BULK '$(dataFolder)\yelp_academic_dataset_review.json'
	,FORMATFILE = '$(repoFolder)\LineByLine.xml'
	,CODEPAGE = '65001'
	) as j
GO

CREATE OR ALTER VIEW dbo.CheckinJSON
AS
	SELECT j.SingleLine
	FROM OPENROWSET (BULK '$(dataFolder)\yelp_academic_dataset_checkin.json'
	,FORMATFILE = '$(repoFolder)\LineByLine.xml'
	,CODEPAGE = '65001'
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