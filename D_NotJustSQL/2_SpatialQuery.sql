/*
This sample code shows how to import and work with the Yelp Dataset (https://www.yelp.com/dataset/) using
the Microsoft SQL family of products and services. Tested with Azure SQL DB and with SQL Server 2019

Please first review the terms of use and documenation for the Yelp dataset
at https://www.yelp.com/dataset/documentation/main

Your use of these sample T-SQL scripts is also subject to standard license terms and legal terms - see footer for those
*/

USE [YelpReviews]
GO

SELECT COUNT(*)
FROM Business
GO

-- Review all the business establishments (in this dataset) located in Arizona
SELECT GEOGRAPHY::Point(latitude, longitude, 4326)
	,latitude
	,longitude
FROM Business
WHERE business_state = 'AZ'
GO

-- What's the magic number 4326? It is a Spatial Reference ID (SRID)
SELECT *
FROM sys.spatial_reference_systems
WHERE spatial_reference_id = 4326
GO

-- Imagine we are at State Farm Stadium (informally the University of Phoenix Stadium)
-- List all businesses within 5 miles of the stadium and categorized as food-related
DECLARE @univPhoenixStadium GEOGRAPHY

SET @univPhoenixStadium = GEOGRAPHY::Point(33.528, -112.263, 4326)

SELECT TOP (10) B.business_name
	,B.business_address
	,B.stars
	,B.geo_location
	,latitude
	,longitude
FROM Business B
WHERE business_state = 'AZ'
	AND @univPhoenixStadium.STDistance(geo_location) < (5.0 * 1609.344) -- 1609.344 is meters / mile
	AND (
		SELECT COUNT(*)
		FROM BusinessCategory BC
		WHERE B.business_id = BC.business_id
			AND BC.category LIKE 'Food'
		) > 0
ORDER BY B.stars DESC
	,B.review_count DESC
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