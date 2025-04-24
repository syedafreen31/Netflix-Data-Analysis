select * from netflix_raw;
-- there were columns which had forgien characters and we have tackled them by changing the data type
-- varcahr to nvarchar

-- drop table and created a new table data type and append the data set

drop table netflix_raw;


create table netflix_raw(
			[show_id] varchar(10) Primary key,
			[type] varchar(10) NULL,
			[title] nvarchar(200) NULL,
			[director] varchar(250) NULL,
			[cast] varchar(800) NULL,
			[country] varchar(150) NULL,
			[date_added] varchar(50) NULL,
			[release_year] int NULL,
			[rating] varchar(10) NULL,
			[duration] varchar(10) NULL,
			[listed_in] varchar(100) NULL,
			[description] varchar(500) NULL
			);


select * from netflix_raw;
-- handle the foreign characters
select * from netflix_raw where show_id = 's5023';

-- remove duplicates

-- check if there are any duplicates in show id
select show_id, count(*)
from netflix_raw
group by show_id
having count(*) > 1;
-- no duplicates in show_id

-- check if there are any duplicates in title
select * from netflix_raw
where title in (
select concat(title,type)
from netflix_raw
group by concat(title,type)
having count(*) > 1
)
order by title desc;

with cte as (
select *,
row_number() over (partition by title order by show_id) as rn
from netflix_raw)
select * from cte 
where rn = 1;

-- create new table for all these values seperatly
-- listed in ,country , cast, director


select show_id , trim(value) as genre
into netflix_genre
from netflix_raw
cross apply string_split(listed_in,',')

select * from netflix_genre

select show_id , trim(value) as country
into netflix_country
from netflix_raw
cross apply string_split(country,',')

select * from netflix_country

select show_id , trim(value) as cast
into netflix_cast
from netflix_raw
cross apply string_split(cast,',')


 

select show_id , trim(value) as director
into netflix_director
from netflix_raw
cross apply string_split(director,',')

select * from netflix_director

select * from netflix_raw where duration is null;

-- the duration column data is present in rating column
-- so loacte the value of the rating into the duration

with cte as (
select * 
,ROW_NUMBER() over(partition by title , type order by show_id) as rn
from netflix_raw
)
select show_id,type,title,cast(date_added as date) as date_added,release_year
,rating,case when duration is null then rating else duration end as duration,description
into netflix
from cte 

select * from netflix;



-- data analysis of the the netflix data
/*1  for each director count the no of movies and tv shows created by them in separate columns 
for directors who have created tv shows and movies both */

select * from netflix_director;
select * from netflix;

-- Using cte
WITH cte AS (
    SELECT director,
           CASE WHEN n.type = 'Movie'   THEN 1 ELSE 0 END AS movie_flag,
           CASE WHEN n.type = 'TV Show' THEN 1 ELSE 0 END AS tv_flag
    FROM   netflix_director nd
    JOIN   netflix n ON nd.show_id = n.show_id
)
SELECT director,
       SUM(movie_flag) AS countofmovie,
       SUM(tv_flag)    AS countoftv
FROM   cte
GROUP  BY director
HAVING SUM(movie_flag) > 0               -- at least one movie
   AND SUM(tv_flag)    > 0               -- and at least one TV show
ORDER  BY director;

--other
select nd.director 
,COUNT(distinct case when n.type='Movie' then n.show_id end) as no_of_movies
,COUNT(distinct case when n.type='TV Show' then n.show_id end) as no_of_tvshow
from netflix n
inner join netflix_director nd on n.show_id=nd.show_id
group by nd.director
having COUNT(distinct n.type)>1


--2 which country has highest number of comedy movies 

select * from netflix_country;
select * from netflix_genre;
select * from netflix;

select  top 1 nc.country , COUNT(distinct ng.show_id ) as no_of_movies
from netflix_genre ng
inner join netflix_country nc on ng.show_id=nc.show_id
inner join netflix n on ng.show_id=nc.show_id
where ng.genre='Comedies' and n.type='Movie'
group by  nc.country
order by no_of_movies desc

--3 for each year (as per date added to netflix), which director has maximum number of movies released

select * from netflix;

WITH per_dir_year AS (                     -- 1? movies per director per year
    SELECT
        YEAR(n.date_added) AS yr,
        nd.director,
        COUNT(DISTINCT n.show_id) AS movie_cnt
    FROM   netflix n
    JOIN   netflix_director nd ON nd.show_id = n.show_id
    WHERE  n.type = 'movie'                      -- movies only
    GROUP  BY YEAR(n.date_added), nd.director
),
ranked AS (                               -- 2? rank directors inside each year
    SELECT  *,
            ROW_NUMBER() OVER (PARTITION BY yr
                               ORDER BY movie_cnt DESC) AS rnk
    FROM    per_dir_year
)
SELECT  yr,
        director,
        movie_cnt
FROM    ranked
WHERE   rnk = 1                   -- 3? keep the yearly maximum
ORDER BY yr, director;


--4 what is average duration of movies in each genre
select * from netflix

	
select ng.genre , avg(cast(REPLACE(duration,' min','') AS int)) as avg_duration
from netflix n
inner join netflix_genre ng on n.show_id=ng.show_id
where type='Movie'
group by ng.genre
order by avg_duration desc;

--5  find the list of directors who have created horror and comedy movies both.
-- display director names along with number of comedy and horror movies directed by them 

select * from netflix;
select * from netflix_director;
select * from netflix_genre;

select nd.director 
,COUNT(distinct case when ng.genre='Comedies' then n.show_id end) as no_of_comedies
,COUNT(distinct case when ng.genre='Horror Movies' then n.show_id end) as no_of_Horror_Movies
from netflix n
inner join netflix_director nd on n.show_id = nd.show_id
inner join netflix_genre ng on n.show_id = ng.show_id
where n.type = 'movie' and ng.genre in ('Comedies','Horror Movies')
group by nd.director
having COUNT(distinct ng.genre)>1

