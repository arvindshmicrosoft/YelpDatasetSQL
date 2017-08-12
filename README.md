This sample code shows how to import and work with the Yelp Dataset (https://www.yelp.com/dataset_challenge) using Microsoft SQL Server 2017.

Please first review the terms of use for the dataset on the Yelp website (https://www.yelp.com/html/pdf/Dataset_Challenge_Academic_Dataset_Agreement.pdf).

The following techniques are demonstrated in this set of samples:

- How to import the JSON data provided as part of the Yelp Reviews dataset into SQL Server 2017
- How to construct an in-database graph comprising of nodes (corresponding to users) and edges (representing the friendship between two users). Once the graph is constructed, we show how to query it using the new MATCH predicate in SQL Server 2017
- How to use in-database Machine Learning services (specifically R) to perform multi-class classification of restaurant food category based on text in the review; and for fun we also show how to build a word cloud from the text in the restaurant reviews