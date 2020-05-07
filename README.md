This sample code shows how to import and work with the Yelp Dataset (https://www.yelp.com/dataset/) using
the Microsoft SQL family of products and services. Tested with Azure SQL DB and with SQL Server 2019

Please first review the terms of use and documenation for the Yelp dataset
at https://www.yelp.com/dataset/documentation/main

Your use of these sample T-SQL scripts is also subject to standard license terms and legal terms documented in each script

The following techniques are demonstrated in this set of samples:

* How to import the JSON data provided as part of the Yelp Reviews dataset into Azure SQL / SQL Server
* In-database graph comprising of nodes (corresponding to users) and edges (representing the friendship between two users). Once the graph is constructed, we show how to query it using the MATCH predicate and finding shortest path between nodes
* A few "beyond SQL" queries which leverage full-text indexes and spatial query support
* In-database Machine Learning services (specifically R) to perform multi-class classification of restaurant food category based on text in the review; and for fun we also show how to build a word cloud from the text in the restaurant reviews - SQL Server only for now
