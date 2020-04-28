/*
This sample code shows how to import and work with the Yelp Dataset (https://www.yelp.com/dataset/) using
the Microsoft SQL family of products and services. Tested with Azure SQL DB and with SQL Server 2019

Please first review the terms of use and documenation for the Yelp dataset
at https://www.yelp.com/dataset/documentation/main

Your use of these sample T-SQL scripts is also subject to standard license terms and legal terms - see footer for those
*/

USE YelpReviews
GO

-- ================ Yelp Dataset Import step 1: yelp_academic_dataset_business.json ================
DROP TABLE IF EXISTS Business
GO

SELECT business_id
	, business_name
	, business_address
	, business_city
	, business_state
	, postal_code
	, GEOGRAPHY::Point(latitude, longitude, 4326) as geo_location
	, stars
	, review_count
	, is_open
	, attributes
	, categories
	, business_hours
	, item_type
INTO Business
FROM dbo.BusinessJSON
CROSS APPLY OPENJSON(SingleLine) WITH (
		business_id VARCHAR(100) '$.business_id'
		,business_name NVARCHAR(500) '$.name'
		,business_address NVARCHAR(1000) '$.address'
		,business_city NVARCHAR(500) '$.city'
		,business_state VARCHAR(500) '$.state'
		,postal_code VARCHAR(100) '$.postal_code'
		,latitude FLOAT '$.latitude'
		,longitude FLOAT '$.longitude'
		,stars FLOAT '$.stars'
		,review_count INT
		,is_open BIT
		,attributes NVARCHAR(max) AS JSON
		,categories NVARCHAR(max) '$.categories'
		,business_hours NVARCHAR(max) '$.hours' AS JSON
		,item_type VARCHAR(100) '$.type'
		) AS Business
GO

-- ================ Yelp Dataset Import step 2: yelp_academic_dataset_tip.json ================
DROP TABLE IF EXISTS Tip
GO

SELECT tip_text
	, tip_date
	, likes
	, business_id
	, user_id
INTO Tip
FROM TipJSON
CROSS APPLY OPENJSON(SingleLine) WITH (
		tip_text NVARCHAR(max) '$.text'
		,tip_date DATE '$.date'
		,likes INT
		,business_id VARCHAR(100) '$.business_id'
		,[user_id] VARCHAR(100) '$.user_id'
		,item_type VARCHAR(100) '$.type'
		) AS Tip
GO

-- ================ Yelp Dataset Import step 3: yelp_academic_dataset_user.json ================
DROP TABLE IF EXISTS YelpUser
GO

SELECT
	user_id
	, user_name
	, review_count
	, yelping_since
	, friends
	, is_useful
	, is_funny
	, is_cool
	, fans
	, elite
	, average_stars
	, compliment_hot
	, compliment_more
	, compliment_profile
	, compliment_cute
	, compliment_list
	, compliment_note
	, compliment_plain
	, compliment_cool
	, compliment_funny
	, compliment_writer
	, compliment_photos
INTO YelpUser
FROM UserJSON
 CROSS APPLY OPENJSON(SingleLine)
 WITH(
	[user_id] varchar(100) '$.user_id',
	user_name nvarchar(1000) '$.name',
	review_count int,
	yelping_since date,
	friends nvarchar(max),
	is_useful bit '$.useful',
	is_funny bit '$.funny',
	is_cool bit '$.cool',
	fans int,
	elite nvarchar(max),
	average_stars float,
	compliment_hot int,
	compliment_more int,
	compliment_profile int,
	compliment_cute int,
	compliment_list int,
	compliment_note int,
	compliment_plain int,
	compliment_cool int,
	compliment_funny int,
	compliment_writer int,
	compliment_photos int,
	item_type varchar(100) '$.type'
	) as YelpUser
GO

-- ================ Yelp Dataset Import step 4: yelp_academic_dataset_review.json ================
DROP TABLE IF EXISTS Review
GO

SELECT review_id
	, [user_id]
	, business_id
	, stars
	, [review_date]
	, [review_text]
	, is_useful
	, is_funny
	, is_cool
INTO Review
FROM dbo.ReviewJSON
CROSS APPLY OPENJSON(SingleLine) WITH (
		review_id VARCHAR(100) '$.review_id'
		,[user_id] VARCHAR(100) '$.user_id'
		,business_id VARCHAR(100) '$.business_id'
		,stars FLOAT '$.stars'
		,[review_date] DATE '$.date'
		,[review_text] NVARCHAR(MAX) '$.text'
		,is_useful BIT '$.useful'
		,is_funny BIT '$.funny'
		,is_cool BIT '$.cool'
		,[item_type] VARCHAR(100) '$.type'
		) AS Review;
GO

-- ================ Yelp Dataset Import step 5: yelp_academic_dataset_checkin.json ================
DROP TABLE IF EXISTS Checkin
GO

SELECT business_id,
	CAST (cd.value AS DATETIME) AS checkin_ts
INTO   Checkin
FROM (SELECT business_id,
		all_checkins
	FROM CheckinJSON
		CROSS APPLY OPENJSON (SingleLine)
		WITH (business_id VARCHAR (100) '$.business_id', all_checkins NVARCHAR (MAX) '$.date') AS ExplodedJSON) AS all_checkins
CROSS APPLY string_split (all_checkins, ',') AS cd;
GO

-- ================ Yelp Dataset Import step 5: Derive business category data ================
DROP TABLE IF EXISTS BusinessCategory;
GO

SELECT Business.business_id,
	TRIM(category.value) AS category
INTO   BusinessCategory
FROM Business CROSS APPLY string_split (categories, ',') AS category;
GO

-- ================ Yelp Dataset Import step 6: Derive user friendship data ================
DROP TABLE IF EXISTS YelpUserFriend;
GO

SELECT user_id,
	TRIM(userfriend.value) AS friend_user_id
INTO   YelpUserFriend
FROM YelpUser CROSS APPLY string_split (friends, ',') AS userfriend;
GO

UPDATE STATISTICS YelpUserFriend;
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