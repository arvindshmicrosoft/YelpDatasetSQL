/*
This sample code shows how to import and work with the Yelp Dataset (https://www.yelp.com/dataset/) using
the Microsoft SQL family of products and services. Tested with Azure SQL DB and with SQL Server 2019

Please first review the terms of use and documenation for the Yelp dataset
at https://www.yelp.com/dataset/documentation/main

Your use of these sample T-SQL scripts is also subject to standard license terms and legal terms - see footer for those
*/

-- Database creation for the Yelp Dataset in SQL Server 2017. Please read the comments at the bottom as well.
Use YelpReviews
GO

-- This is a 'node' table to store users in a graph data structure inside of the YelpReviews SQL Server 2017 database
DROP TABLE IF EXISTS [dbo].[FinalUser]
GO

CREATE TABLE [dbo].[FinalUser](
	[user_id] [varchar](100) NOT NULL PRIMARY KEY NONCLUSTERED,
	[user_name] [varchar](1000) NULL,
	[review_count] [int] NULL,
	[yelping_since] [date] NULL,
	[is_useful] [bit] NULL,
	[is_funny] [bit] NULL,
	[is_cool] [bit] NULL,
	[fans] [int] NULL,
	[elite] [nvarchar](max) NULL,
	[average_stars] [float] NULL,
	[compliment_hot] [int] NULL,
	[compliment_more] [int] NULL,
	[compliment_profile] [int] NULL,
	[compliment_cute] [int] NULL,
	[compliment_list] [int] NULL,
	[compliment_note] [int] NULL,
	[compliment_plain] [int] NULL,
	[compliment_cool] [int] NULL,
	[compliment_funny] [int] NULL,
	[compliment_writer] [int] NULL,
	[compliment_photos] [int] NULL
) AS NODE
GO

-- for performance purposes, disable default indexes on node table prior to such large insert operations
ALTER INDEX ALL ON [FinalUser] disable;
GO

-- Insert existing data from the imported Yelp dataset into a set of nodes, each representing an user
-- The attributes for each user are stored in the Node table itself
INSERT [FinalUser]
SELECT [user_id]
      ,[user_name]
      ,[review_count]
      ,[yelping_since]
      ,[is_useful]
      ,[is_funny]
      ,[is_cool]
      ,[fans]
      ,[elite]
      ,[average_stars]
      ,[compliment_hot]
      ,[compliment_more]
      ,[compliment_profile]
      ,[compliment_cute]
      ,[compliment_list]
      ,[compliment_note]
      ,[compliment_plain]
      ,[compliment_cool]
      ,[compliment_funny]
      ,[compliment_writer]
      ,[compliment_photos]
  FROM [dbo].[YelpUser]
GO

-- Large insert is completed, enable (rebuild) default index on node table
ALTER INDEX ALL ON [FinalUser] REBUILD;
GO

-- This is an 'edge' table to store the relationships ('friend of') in an edge table
-- For demonstration purposes we store a representative attribute of the *relationship*
-- which in this case is a computed value of the total number of reviews submitted by
-- the two users who are friends with each other
DROP TABLE IF EXISTS [dbo].[FinalFriend]
GO

CREATE TABLE [dbo].[FinalFriend]
(
	CombinedReviews int
)
AS EDGE
GO

-- for performance purposes, disable default indexes on edge table prior to such large insert operations
ALTER INDEX ALL ON [FinalFriend] DISABLE;
GO

-- Actually insert the edge data. To do this we are using the $node_id values from the
-- node table for each user, and combining the review_count for each of the 2 users
INSERT FinalFriend ($FROM_ID, $TO_ID, CombinedReviews)
SELECT U.$NODE_ID,
       F.$NODE_ID,
       U.review_count + F.review_count
FROM   YelpUserFriend AS UF1
       INNER JOIN
       FinalUser AS U
       ON UF1.user_id = U.user_id
       INNER JOIN
       FinalUser AS F
       ON UF1.friend_user_id = F.user_id;
GO

-- Large insert is completed, enable (rebuild) default index on edge table
ALTER INDEX ALL ON [FinalFriend] REBUILD;
GO

-- Create an additional index to help in the performance of queries later on
CREATE NONCLUSTERED INDEX NC_FinalFriend_From_To
ON [dbo].[FinalFriend] ($from_id, $to_id)

-- Additional index to try optimize the RAI algorithm
CREATE NONCLUSTERED INDEX NC_FinalFriend_To
ON [dbo].[FinalFriend] ($to_id)

-- A quick look at the data we have in the SQL graph representation
-- Node the $node_id values in the FinalUser table
SELECT TOP 10 *
FROM FinalUser;
GO

-- Note the $edge_id, $from_id and $to_id values in the FinalFriend table
-- the $from_id and $to_id are actually $node_id values in the corresponding Node table
SELECT TOP 10 *
FROM FinalFriend;
GO

-- Note that there is missing User data for some friend_user_id values
-- So this causes the number of 'edge' table entries to be quite low
-- compared to what you will see in YelpUserFriend!
-- This is a dataset limitation and not an artifact of the import process.
SELECT TOP 50 *
FROM   YelpUserFriend
WHERE  friend_user_id NOT IN (SELECT user_id
                              FROM   YelpUser);

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