🎬 Netflix Titles — From Kaggle CSV to SQL Server Insights
This project walks through the entire pipeline we followed to turn the public Netflix Titles dataset (from Kaggle) into a clean, relational model in SQL Server, then answer five business‑style questions.

🚦 Process Overview

#	Steps

1	Download	Pulled netflix_titles.csv from Kaggle.

2	Import	Loaded the CSV into Python using pandas.

3	Connect to SQL Server	Opened a SQLAlchemy/pyodbc connection to our SQL Server instance.

4	Initial sanity check	Pushed the raw file into a staging table and ran row‑counts / schema checks in SSMS.

Data cleaning	  * removed duplicates

 * fixed data types (date_added ➜ DATE, duration ➜ INT minutes,varchar data size)
 
 * check if there are any duplicates in show id,title
 * 
 * checked for the null values in the duration column and misleading data
 * 
 * appended fresh rows if the CSV is updated later.
 
5.Normalisation	Split multi‑value columns into four helper tables, each keyed by show_id: netflix_director, netflix_genre, netflix_country, netflix_cast.


🗂️ Schema

Table	Purpose	Important columns
netflix	--------- one title (core data)	show_id (PK), type, title, date_added, duration

netflix_director  --------- show_id, director

netflix_genre	---------	show_id, genre

netflix_country	---------	show_id, country

netflix_cast	---------	show_id, cast_name


🔍 Analytical Questions & Key Queries

#	Business question	
1	For each director, how many Movies and TV Shows have they created?
Also list only directors who have done both.	

2	Which country has the highest number of Comedy movies?	

3	Per year (based on date_added), which director released the most movies?	

4	What’s the average duration of movies in each genre?	

5	List directors who have made both Horror and Comedy movies; show their counts.	


📝 License
Dataset: © Netflix via Kaggle – provided for educational use only.

Happy binge‑querying! 🍿
