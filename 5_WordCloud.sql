/*
This sample code shows how to import and work with the Yelp Dataset (https://www.yelp.com/dataset_challenge) using Microsoft SQL Server 2017.
Please first review the terms of use for the dataset on the Yelp website (https://www.yelp.com/html/pdf/Dataset_Challenge_Academic_Dataset_Agreement.pdf).
*/

USE YelpReviews
GO

-- This example shows how to build a word cloud based on the text in the Yelp Reviews dataset.

-- Prior to running this example, please install the 'tm' and 'wordcloud' R packages by following the steps
-- from https://docs.microsoft.com/en-us/sql/advanced-analytics/r/install-additional-r-packages-on-sql-server
-- In addition, you will also need sufficient memory (16GB or higher is recommended) because
-- the tm and wordcloud routines are resource-intensive, especially on a large dataset like the
-- Yelp Reviews dataset.

-- Finally you will need to increase the resource limit for memory allocated to SQL Server R Services
-- to 50% of RAM or even higher. Failure to do this will typically result in 'insufficient memory'
-- errors. Steps to do this are in https://docs.microsoft.com/en-us/sql/advanced-analytics/r/resource-governance-for-r-services

DECLARE @R_script AS NVARCHAR (MAX) = CONCAT(N'
library(tm)
library(wordcloud)

sqlServerConnString <- "Server=', REPLACE(@@SERVERNAME, '\', '\\'), N';Database=YelpReviews;trusted_connection=true;"

ReviewDataRaw <- RxSqlServerData(sqlQuery = "
	SELECT TOP 10000 R.review_text
	FROM Review R JOIN BusinessCategory BC
	ON R.business_id = BC.business_id
	WHERE BC.category IN (''American'', ''Mexican'', ''French'', ''Italian'', ''Chinese'', ''Japanese'', ''Indian'', ''Malay'')
", connectionString = sqlServerConnString, rowBuffering = FALSE, stringsAsFactors = FALSE
, 
);

ReviewsDataSet <- rxImport(ReviewDataRaw, maxRowsByCols = 1000000)

additionalNoiseWords <- c("run", "set", "number", "will", "work", "best", "large", "new", 
                          "possible", "also", "option", "questions", "want", "looking", "way", 
                          "take", "get", "like", "table", "can", "need", "better", "multiple", "server", 
                          "database", "sql", "data", "using", "question", "answer", "use", 
                          "processing", "system", "issues", "amp", "version", "can", "sqlserver",
                          "user", "one", "query", "time", "node", "log" );

aggregate.plurals <- function(v) {
  aggr_fn <- function(v, singular, plural) {
    if (!is.na(v[plural])) {
      v[singular] <- v[singular] + v[plural]
      v <- v[ - which(names(v) == plural)]
    }
    return(v)
  }
  for (n in names(v)) {
    n_pl <- paste(n, ''s'', sep = '''')
    v <- aggr_fn(v, n, n_pl)
    n_pl <- paste(n, ''es'', sep = '''')
    v <- aggr_fn(v, n, n_pl)
  }
  return(v)
}

# this is adding two arrays
finalWordList <- c(additionalNoiseWords, stopwords("english"))

# next step: breaking down the text into words
reviewText <- Corpus(VectorSource(ReviewsDataSet$review_text))

#normalize all the text into lowercase
reviewText <- tm_map(reviewText, content_transformer(tolower))

# next step is to remove all the noise words
reviewText <- tm_map(reviewText, function(x) removeWords(x, finalWordList))

# remove punctuation marks
reviewText <- tm_map(reviewText, removePunctuation)

# create the matrix of all the words
tdm <- TermDocumentMatrix(reviewText)

m <- as.matrix(tdm)
v <- sort(rowSums(m), decreasing = TRUE)

# replaceing plurals with singular equivalent
v <- aggregate.plurals(v)

# this is the dataset with the word - frequency pairing
wordfreq <- data.frame(word = names(v), freq = v)
wordfreq <- subset(wordfreq, wordfreq$freq > 5)

# top 100 words only
wordfreq <- head(wordfreq[order(wordfreq$freq, decreasing = TRUE),], 100)

#dump it out to get top 25 word-frequency pairing
print(head(wordfreq, 50))

# the code below will actually generate a graph in a file - need to figure out how to pass that on to PowerBI (optional)
# prepare a device for rendering the word cloud
png("C:\\YelpDatasetSQLServerData\\wordcloud.png", width = 1280, height = 800)

# really create the wordcloud
wordcloud(wordfreq$word, wordfreq$freq, scale = c(5, .5), min.freq = 2, max.words = 50, use.r.layout = FALSE, random.order = FALSE, rot.per = .15, colors = brewer.pal(8, "Dark2"))
dev.off()
')

EXEC sp_execute_external_script @language = N'R',
@script = @R_script

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