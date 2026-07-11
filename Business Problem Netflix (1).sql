-- 15 Business Problems & Solutions

use netflix_sql;
show tables;
SELECT 
    *
FROM
    netflix;


-- 1. Count the number of Movies vs TV Shows

SELECT 
    type, COUNT(type)
FROM
    netflix
GROUP BY type;

-- 2. Find the most common rating for movies and TV shows
with most_common as (
	select 
		type ,rating, 
		count(*) as total_rating,
		rank() over (partition by type order by count(*) desc) as ranking from netflix
		group by type , rating 
	)
select type ,rating ,total_rating from most_common
where ranking = 1;



-- 3. List all movies released in a specific year (e.g., 2020)

SELECT 
    title
FROM
    netflix
WHERE
    release_year = 2020 AND type = 'Movie';

-- 3. count  all movies released in a specific year (e.g., 2020)
SELECT 
    COUNT(title)
FROM
    (SELECT 
        title
    FROM
        netflix
    WHERE
        release_year = 2020 AND type = 'Movie') AS release_2020;

--  4. Find the top 5 countries with the most content on Netflix
SELECT 
    country, COUNT(show_id)
FROM
    netflix
WHERE
    country IS NOT NULL
GROUP BY country
ORDER BY COUNT(show_id) DESC
LIMIT 500;







with recursive country_split as (
select 
trim(substring_index(country,',',1 )) as country_new,
substring(country,locate(',',country)+1)as remaining_country             
from netflix
where show_id is not null 
union all
 SELECT 
        TRIM(SUBSTRING_INDEX(remaining_country, ',', 1)) AS country_new,
        IF(LOCATE(',', remaining_country) > 0, SUBSTRING(remaining_country, LOCATE(',', remaining_country) + 1), '')
    FROM country_split
    WHERE remaining_country <> ''
    )select  country_new,count(*) as total from country_split
    where country_new is not null
    group by country_new 
    order by total desc
    limit 5;
    
    
-- 5. Identify the longest movie

with longest_movie as ( 
select title,
cast(substring_index( duration ,' ',1)as signed ) as duration_ ,
duration from netflix
order by duration_ desc)
select title, duration from longest_movie;


 
SELECT 
    title,duration
FROM
    netflix
ORDER BY (duration + 0) DESC
LIMIT 1;
  
  

-- 6. Find content added in the last 5 years  

SELECT 
    title, release_year
FROM
    netflix
WHERE
    release_year >= (SELECT 
            MAX(release_year)
        FROM
            netflix) - 5
ORDER BY release_year DESC;


SELECT 
    *
FROM
    netflix;
    
-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT 
    COUNT(show_id)
FROM
    netflix
WHERE
    director LIKE '%Rajiv Chilaka%';

 

--  8. List all TV shows with more than 5 seasons

SELECT 
    title, duration
FROM
    netflix
WHERE
    duration >= '5 Seasons'
        AND type = 'TV Show'
ORDER BY duration DESC;



-- 9. Count the number of content items in each genere

with recursive content_split as (
	select trim(substring_index(listed_in,',',1)) as genre,
    substring( listed_in,locate(',',listed_in)+1)as remaining_gen
     FROM netflix
   
UNION ALL
    SELECT 
        TRIM(SUBSTRING_INDEX(remaining_gen, ',', 1)) AS genre,
        IF(LOCATE(',', remaining_gen) > 0, SUBSTRING(remaining_gen, LOCATE(',', remaining_gen) + 1), '')
    FROM content_split
    WHERE remaining_gen <> ''
) 
select genre,count(*) from content_split
group by genre
order by count(*) desc;
    ;
    



-- 10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!
  
SELECT 
    release_year, ROUND(AVG(title), 2)
FROM
    netflix
WHERE
    country LIKE '%India%'
GROUP BY release_year
ORDER BY AVG(title) DESC
LIMIT 5;


-- 11. List all movies that are documentaries
SELECT 
    title, listed_in
FROM
    netflix
WHERE
    type = 'Movie'
        AND listed_in LIKE '%Documentaries%';



-- 12. Find all content without a director
SELECT 
    title
FROM
    netflix
WHERE
    director IS NULL;





-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT 
    title, cast
FROM
    netflix
WHERE
    cast LIKE '%Salman Khan%'
        AND release_year >= (SELECT 
            MAX(release_year)
        FROM
            netflix) - 10;


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.;
WITH RECURSIVE actor_split AS (
    -- Base case: Get the first actor from the list
    SELECT 
        TRIM(SUBSTRING_INDEX(cast, ',', 1)) AS actor_name,
        SUBSTRING(cast, LOCATE(',', cast) + 1) AS remaining_cast
    FROM netflix
    WHERE type = 'Movie' 
      AND country LIKE '%India%'
      AND cast IS NOT NULL
    
    UNION ALL
    
    -- Recursive step: Keep extracting the next actor until the string is empty
    SELECT 
        TRIM(SUBSTRING_INDEX(remaining_cast, ',', 1)) AS actor_name,
        IF(LOCATE(',', remaining_cast) > 0, SUBSTRING(remaining_cast, LOCATE(',', remaining_cast) + 1), '')
    FROM actor_split
    WHERE remaining_cast <> ''
) 
select actor_name,count(*) from actor_split
group by actor_name
order by count(*) desc;


/* 15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.*/


SELECT 
    CASE
        WHEN
            description LIKE '%kill%'
                OR description LIKE '%violence%'
        THEN
            'Bad'
        ELSE 'Good'
    END AS category,
    COUNT(*) AS item_count
FROM
    netflix
GROUP BY CASE
    WHEN
        description LIKE '%kill%'
            OR description LIKE '%violence%'
    THEN
        'Bad'
    ELSE 'Good'
END;



/*
select * from netflix;
WITH RECURSIVE actor_split AS (
    -- Base case: Get the first actor from the list
    SELECT 
        TRIM(SUBSTRING_INDEX(cast, ',', 1)) AS actor_name,
        SUBSTRING(cast, LOCATE(',', cast) + 1) AS remaining_cast
    FROM netflix
    WHERE type = 'Movie' 
      AND country LIKE '%India%'
      AND cast IS NOT NULL
    
    UNION ALL
    
    -- Recursive step: Keep extracting the next actor until the string is empty
    SELECT 
        TRIM(SUBSTRING_INDEX(remaining_cast, ',', 1)) AS actor_name,
        IF(LOCATE(',', remaining_cast) > 0, SUBSTRING(remaining_cast, LOCATE(',', remaining_cast) + 1), '')
    FROM actor_split
    WHERE remaining_cast <> ''
)
SELECT 
    actor_name, 
    COUNT(*) AS movie_count
FROM actor_split
WHERE actor_name <> ''
GROUP BY actor_name
ORDER BY movie_count DESC
LIMIT 10;
WITH RECURSIVE actor_split AS (
    -- Base case: Get the first actor from the list
    SELECT 
        TRIM(SUBSTRING_INDEX(cast, ',', 1)) AS actor_name,
        SUBSTRING(cast, LOCATE(',', cast) + 1) AS remaining_cast
    FROM netflix
    WHERE type = 'Movie' 
      AND country LIKE '%India%'
      AND cast IS NOT NULL
    
    UNION ALL
    
    -- Recursive step: Keep extracting the next actor until the string is empty
    SELECT 
        TRIM(SUBSTRING_INDEX(remaining_cast, ',', 1)) AS actor_name,
        IF(LOCATE(',', remaining_cast) > 0, SUBSTRING(remaining_cast, LOCATE(',', remaining_cast) + 1), '')
    FROM actor_split
    WHERE remaining_cast <> ''
)
SELECT 
    actor_name, 
    COUNT(*) AS movie_count
FROM actor_split
WHERE actor_name <> ''
GROUP BY actor_name
ORDER BY movie_count DESC
LIMIT 10;*/
