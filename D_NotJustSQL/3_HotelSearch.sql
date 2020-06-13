/*
This sample code shows how to import and work with the Yelp Dataset (https://www.yelp.com/dataset/) using
the Microsoft SQL family of products and services. Tested with Azure SQL DB and with SQL Server 2019

Please first review the terms of use and documenation for the Yelp dataset
at https://www.yelp.com/dataset/documentation/main

Your use of these sample T-SQL scripts is also subject to standard license terms and legal terms - see footer for those
*/

USE [YelpReviews]
GO

-- Imagine we are at State Farm Stadium (informally the University of Phoenix Stadium)
-- List all hotels within 5 miles of the stadium
DECLARE @univPhoenixStadium GEOGRAPHY

SET @univPhoenixStadium = GEOGRAPHY::Point(33.528, -112.263, 4326)

SELECT TOP (10) B.business_id
	,B.business_name
	,B.business_address
	,B.stars
	,@univPhoenixStadium.STDistance(geo_location) / 1609.34 as DistanceInMiles
	,B.geo_location
FROM Business B
WHERE business_state = 'AZ'
	AND @univPhoenixStadium.STDistance(geo_location) < (5.0 * 1609.344)
	AND (
		SELECT COUNT(*)
		FROM BusinessCategory BC
		WHERE B.business_id = BC.business_id
			AND BC.category = 'HOTELS'
		) > 0
ORDER BY @univPhoenixStadium.STDistance(geo_location);
GO

-- Let's pretend we are user_id 'SqLjqDFQb4st12C7tt_mFA' and we want to stay at
-- Residence Inn Phoenix Glendale (business_id 'n3z1qddNQpRdBjuLspRiwg')
-- Next, we'll search reviews for that hotel and find at least 1 user who submitted 
-- reviews and to whom we are connected to as a friend
SELECT TOP (1) *
FROM (
	SELECT Person1.user_id AS PersonName
		,STRING_AGG(Person2.user_id, '->') WITHIN GROUP (GRAPH PATH) AS Friends
		,LAST_VALUE(Person2.user_id) WITHIN GROUP (GRAPH PATH) AS LastNode
	FROM FinalUser AS Person1
		,FinalFriend FOR PATH AS fo
		,FinalUser FOR PATH AS Person2
	WHERE MATCH(SHORTEST_PATH(Person1(-(fo)-> Person2) {1, 2}))
		AND Person1.user_id = 'SqLjqDFQb4st12C7tt_mFA'
	) AS Paths
WHERE Paths.LastNode
	IN (
		SELECT user_id AS review_user_id
		FROM dbo.Review
		WHERE business_id = 'n3z1qddNQpRdBjuLspRiwg'
		)
GO

-- If the query takes longer than you'd like, check the service tier of the DB
select DATABASEPROPERTYEX('YelpReviews', 'ServiceObjective')
GO

-- Try resizing to a 16-vCore DB and see if it makes things any faster
-- Notice how quickly the resize takes place for Hyperscale
ALTER DATABASE YelpReviews
MODIFY (SERVICE_OBJECTIVE = 'HS_Gen5_16')
GO

-- Retry the previous query and see how quickly it comes back

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