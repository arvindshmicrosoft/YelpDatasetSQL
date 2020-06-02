/*
This sample code shows how to import and work with the Yelp Dataset (https://www.yelp.com/dataset/) using
the Microsoft SQL family of products and services. Tested with Azure SQL DB and with SQL Server 2019

Please first review the terms of use and documenation for the Yelp dataset
at https://www.yelp.com/dataset/documentation/main

Your use of these sample T-SQL scripts is also subject to standard license terms and legal terms - see footer for those
*/

-- ***** RUN THIS SCRIPT IF YOU ARE USING AZURE SQL ****
IF SERVERPROPERTY ('edition') != 'SQL Azure'
	RAISERROR('This script is only for Azure SQL DB', 17, 1)

GO

:setvar blobContainer 'https://<<storage account name>>.blob.core.windows.net/<<container name>>'
:setvar blobSAS '<<SAS goes here, without the leading ? mark>>'
:setvar blobDataSourceName 'YelpDataContainer'
:setvar businessJSONFilePath 'Yelp/yelp_academic_dataset_business.json'
:setvar formatFilePath 'Yelp/LineByLine.xml'

DROP VIEW IF EXISTS [dbo].[BusinessJSON];

DROP VIEW IF EXISTS [dbo].[CheckinJSON];

DROP VIEW IF EXISTS [dbo].[ReviewJSON];

DROP VIEW IF EXISTS [dbo].[TipJSON];

DROP VIEW IF EXISTS [dbo].[UserJSON];

DROP TABLE IF EXISTS [dbo].[FinalUser];

DROP TABLE IF EXISTS [dbo].[FinalFriend];

DROP TABLE IF EXISTS [dbo].[YelpUserFriend];

DROP TABLE IF EXISTS [dbo].[YelpUser];

DROP TABLE IF EXISTS [dbo].[Tip];

DROP TABLE IF EXISTS [dbo].[Review];

DROP TABLE IF EXISTS [dbo].[Checkin];

DROP TABLE IF EXISTS [dbo].[BusinessCategory];

DROP TABLE IF EXISTS [dbo].[Business];

DROP EXTERNAL DATA SOURCE YelpDataContainer;

DROP DATABASE SCOPED CREDENTIAL BlobSASCred;

DROP MASTER KEY;




drop external DATA SOURCE YelpDataContainer
drop DATABASE SCOPED CREDENTIAL BlobSASCred
DROP MASTER KEY

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