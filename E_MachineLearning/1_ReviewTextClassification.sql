/*
This sample code shows how to import and work with the Yelp Dataset (https://www.yelp.com/dataset/) using
the Microsoft SQL family of products and services. Tested with Azure SQL DB and with SQL Server 2019

Please first review the terms of use and documenation for the Yelp dataset
at https://www.yelp.com/dataset/documentation/main

Your use of these sample T-SQL scripts is also subject to standard license terms and legal terms - see footer for those
*/

-- Currently, ML Services is not yet in public preview or GA for Azure SQL
IF SERVERPROPERTY ('edition') = 'SQL Azure'
	RAISERROR('This script is currently only for SQL Server', 17, 1)
GO

-- Machine learning examples on top of the Yelp Reviews dataset
USE YelpReviews;
GO

-- This example shows how to perform multi-class classification based on text data
-- It uses the MicrosoftML functions 'featurizeText' and 'rxLogisticRegression' to
-- build a model with test data and then uses 'rxPredict' to score the training data
-- Training and test are split from the Yelp Reviews table in a 75% - 25% ratio
-- At the end 'rxCrossTabs' is used to print a 'confusion matrix' of the multi-class
-- classification results
DECLARE @R_script AS NVARCHAR (MAX) = CONCAT(N'
library(MicrosoftML)

sqlServerConnString <- "Server=', REPLACE(@@SERVERNAME, '\', '\\'), N';Database=YelpReviews;trusted_connection=true;"

ReviewDataRaw <- RxSqlServerData(sqlQuery = "
	SELECT TOP 10000 R.review_text, BC.category
	FROM Review R JOIN BusinessCategory BC
	ON R.business_id = BC.business_id
	WHERE BC.category IN (''American'', ''Mexican'', ''French'', ''Italian'', ''Chinese'', ''Japanese'', ''Indian'', ''Malay'')
", connectionString = sqlServerConnString, rowBuffering = FALSE, stringsAsFactors = FALSE
,
);

ReviewsDataSet <- rxImport(ReviewDataRaw, maxRowsByCols = 1000000)
ReviewsDataSet$category <- as.factor(ReviewsDataSet$category)

boundary <- floor((nrow(ReviewsDataSet) / 4)*3)

train_complete_data <- ReviewsDataSet[1:boundary, ]
test_complete_data <- ReviewsDataSet[(boundary+1):nrow(ReviewsDataSet),]

multiFormula = category ~ review_text
mlTransList = list (featurizeText(vars = ''review_text'',
	stopwordsRemover = stopwordsDefault(),
	vectorNormalizer = ''none'',
	wordFeatureExtractor = ngramCount(),
	keepPunctuations = FALSE))

modelLR = rxLogisticRegression(
	formula = multiFormula,
	type = "multiClass",
	mlTransforms = mlTransList,
	normalize = "no",
	data = train_complete_data
)

scored_data = rxPredict(modelLR, data = test_complete_data, extraVarsToWrite = "category")

print(rxCrossTabs(~ category:PredictedLabel, scored_data, verbose= 0))
');

EXECUTE sp_execute_external_script @language = N'R', @script = @R_script;

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