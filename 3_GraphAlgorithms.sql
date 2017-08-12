/*
This sample code shows how to import and work with the Yelp Dataset (https://www.yelp.com/dataset_challenge) using Microsoft SQL Server 2017.
Please first review the terms of use for the dataset on the Yelp website (https://www.yelp.com/html/pdf/Dataset_Challenge_Academic_Dataset_Agreement.pdf).
*/

-- Graph traversal / search algorithms for the Yelp Reviews Dataset in SQL Server 2017
USE YelpReviews;
GO

-- The requirement which is being addressed below is eventually a shortest-path calculation
-- We are using 2 users from the Yelp dataset (represented below by their anonymous user IDs)
-- Then a variety of approaches are used to find paths between these 2 users

-- ===================== Graph Traversal EXAMPLE 1 =====================
-- First, we use a primitive / brute force approach by explictly checking for fixed-length
-- paths; first 1-hop, then 2-hop and so on. This approach does not check for cycles
-- and is limted by number of hops
DECLARE @OriginUser AS VARCHAR (100) = 'V8M1Txtrx0SomcnhxfDM5A';

DECLARE @DestUser AS VARCHAR (100) = 'aT_AzbpcsbodNNtFzPqRVg';
-- Fixed length paths
SELECT CONCAT(U1.user_id, '->', U2.user_id) AS FriendPath,
       1 AS PathLength
FROM   FinalUser AS U1, FinalUser AS U2, FinalFriend AS F
WHERE  U1.user_id = @OriginUser
       AND U2.user_id = @DestUser
       AND MATCH(U1-(F)->U2)
UNION ALL
SELECT CONCAT(U1.user_id, '->', U2.user_id, '->', U3.user_id) AS FriendPath,
       2 AS PathLength
FROM   FinalUser AS U1, FinalUser AS U2, FinalUser AS U3, FinalFriend AS F1, FinalFriend AS F2
WHERE  U1.user_id = @OriginUser
       AND U3.user_id = @DestUser
       AND MATCH(U1-(F1)->U2
                 AND U2-(F2)->U3)
UNION ALL
SELECT CONCAT(U1.user_id, '->', U2.user_id, '->', U3.user_id, '->', U4.user_id) AS FriendPath,
       3 AS PathLength
FROM   FinalUser AS U1, FinalUser AS U2, FinalUser AS U3, FinalUser AS U4, FinalFriend AS F1, FinalFriend AS F2, FinalFriend AS F3
WHERE  U1.user_id = @OriginUser
       AND U4.user_id = @DestUser
       AND MATCH(U1-(F1)->U2
                 AND U2-(F2)->U3
                 AND U3-(F3)->U4)
UNION ALL
SELECT CONCAT(U1.user_id, '->', U2.user_id, '->', U3.user_id, '->', U4.user_id, '->', U5.user_id) AS FriendPath,
       4 AS PathLength
FROM   FinalUser AS U1, FinalUser AS U2, FinalUser AS U3, FinalUser AS U4, FinalUser AS U5, FinalFriend AS F1, FinalFriend AS F2, FinalFriend AS F3, FinalFriend AS F4
WHERE  U1.user_id = @OriginUser
       AND U5.user_id = @DestUser
       AND MATCH(U1-(F1)->U2
                 AND U2-(F2)->U3
                 AND U3-(F3)->U4
                 AND U4-(F4)->U5);
GO
-- ===================== END Graph Traversal EXAMPLE 1 =====================

-- ===================== Graph Traversal EXAMPLE 2 =====================
-- Next, we use BFS to compute length and actual path for the shortest path
-- between two specific users
CREATE TABLE #t (
    user_id VARCHAR (100)  UNIQUE CLUSTERED,
    level   INT           ,
    path    VARCHAR (8000)
);

CREATE INDEX il
    ON #t(level)
    INCLUDE(path);

DECLARE @OriginUser AS VARCHAR (100) = 'V8M1Txtrx0SomcnhxfDM5A';
DECLARE @DestUser AS VARCHAR (100) = 'aT_AzbpcsbodNNtFzPqRVg';
DECLARE @level AS INT = 0;

INSERT  #t
VALUES (@OriginUser, @level, @OriginUser);

WHILE @@rowcount > 0
      AND NOT EXISTS (SELECT *
                      FROM   #t
                      WHERE  user_id = @DestUser)
    BEGIN
        SET @level += 1;
        INSERT #t
        SELECT user_id,
               level,
               concat(path, ' -> ', user_id)
        FROM   (SELECT   u2.user_id,
                         @level AS level,
                         min(t1.path) AS path
                FROM     #t AS t1 WITH (FORCESEEK), FinalUser AS u1, FinalFriend AS f, FinalUser AS u2
                WHERE    t1.level = @level - 1
                         AND t1.user_id = u1.user_id
                         AND MATCH(u1-(f)->u2)
                         AND NOT EXISTS (SELECT *
                                         FROM   #t AS t2 WITH (FORCESEEK)
                                         WHERE  t2.user_id = u2.user_id)
                GROUP BY u2.user_id) AS q;
    END

SELECT *
FROM   #t
WHERE  user_id = @DestUser;

DROP TABLE #t;
GO
-- ===================== END Graph Traversal EXAMPLE 2 =====================

-- ===================== Graph Traversal EXAMPLE 3 =====================
-- Next, compute single source shortest path (distance only)
-- This outputs shortest paths from the given start node to each of the nodes
-- which are reachable from this start node. Note again that this query only
-- lists the *distance* and not the actual path
CREATE TABLE #t (
    user_id VARCHAR (100) UNIQUE CLUSTERED,
    level   INT           INDEX il NONCLUSTERED
);

DECLARE @OriginUser AS VARCHAR (100) = 'V8M1Txtrx0SomcnhxfDM5A';

DECLARE @level AS INT = 0;

INSERT  #t
VALUES (@OriginUser, @level);

WHILE @@rowcount > 0
    BEGIN
        SET @level += 1;
        INSERT #t
        SELECT DISTINCT u2.user_id,
                        @level
        FROM   #t AS t1 WITH (FORCESEEK), FinalUser AS u1, FinalFriend AS f, FinalUser AS u2
        WHERE  t1.level = @level - 1
               AND t1.user_id = u1.user_id
               AND MATCH(u1-(f)->u2)
               AND NOT EXISTS (SELECT *
                               FROM   #t AS t2 WITH (FORCESEEK)
                               WHERE  t2.user_id = u2.user_id);
    END

SELECT *
FROM   #t;

DROP TABLE #t;
GO
-- ===================== END Graph Traversal EXAMPLE 3 =====================

-- ===================== Graph Traversal EXAMPLE 4 =====================
-- Finally, compute single source shortest path (with full path) to all other nodes
-- This takes a bit longer than Example 3 above for obvious reasons
CREATE TABLE #t (
    user_id VARCHAR (100)  UNIQUE CLUSTERED,
    level   INT           ,
    path    VARCHAR (8000)
);

CREATE INDEX il
    ON #t(level)
    INCLUDE(path);

DECLARE @OriginUser AS VARCHAR (100) = 'V8M1Txtrx0SomcnhxfDM5A';

DECLARE @level AS INT = 0;

INSERT  #t
VALUES (@OriginUser, @level, @OriginUser);

WHILE @@rowcount > 0
    BEGIN
        SET @level += 1;
        INSERT #t
        SELECT user_id,
               level,
               concat(path, ' -> ', user_id)
        FROM   (SELECT   u2.user_id,
                         @level AS level,
                         min(t1.path) AS path
                FROM     #t AS t1 WITH (FORCESEEK), FinalUser AS u1, FinalFriend AS f, FinalUser AS u2
                WHERE    t1.level = @level - 1
                         AND t1.user_id = u1.user_id
                         AND MATCH(u1-(f)->u2)
                         AND NOT EXISTS (SELECT *
                                         FROM   #t AS t2 WITH (FORCESEEK)
                                         WHERE  t2.user_id = u2.user_id)
                GROUP BY u2.user_id) AS q;
    END

SELECT *
FROM   #t;

DROP TABLE #t;
GO
-- ===================== END Graph Traversal EXAMPLE 4 =====================

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
