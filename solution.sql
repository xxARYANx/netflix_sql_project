-- 15 Business Problems & Solutions using Netflix Data

-- 1. Count the number of Movies vs TV Shows
SELECT type, COUNT(*) AS total_count
FROM netflix
GROUP BY type;

-- 2. Find the most common rating for movies and TV shows
SELECT type, rating, count, ranking
FROM (
    SELECT type, rating, COUNT(*) AS count,
           RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
    FROM netflix
    GROUP BY type, rating
) AS ranked_ratings
WHERE ranking = 1;

-- 3. List all movies released in a specific year (e.g., 2020)
SELECT * 
FROM netflix
WHERE release_year = 2020 AND type = 'Movie';

-- 4. Find the top 5 countries with the most content on Netflix
SELECT TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS country, COUNT(*) AS total_content
FROM netflix
WHERE country IS NOT NULL
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;

-- 5. Identify the longest movie
SELECT *
FROM netflix
WHERE type = 'Movie'
ORDER BY duration DESC
LIMIT 1;

-- 6. Find content added in the last 5 years
SELECT * 
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'
ORDER BY date_added;

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'
SELECT *
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons
SELECT *
FROM netflix
WHERE type ILIKE '%TV Show%'
AND SPLIT_PART(duration, ' ', 1)::NUMERIC > 5;

-- 9. Count the number of content items in each genre
SELECT COUNT(*) AS total_count, TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre
FROM netflix
GROUP BY genre
ORDER BY total_count DESC;

-- 10. Find the top 5 years with the highest average content release in India
SELECT release_year, COUNT(show_id) AS total_release,
       ROUND(COUNT(show_id)::NUMERIC / (SELECT COUNT(show_id) FROM netflix WHERE country='India')::NUMERIC * 100, 2) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY release_year
ORDER BY avg_release DESC
LIMIT 5;

-- 11. List all movies that are documentaries
SELECT * 
FROM netflix 
WHERE listed_in ILIKE '%documentaries%';

-- 12. Find all content without a director
SELECT *
FROM netflix
WHERE director = '';

-- 13. Find how many movies actor 'Salman Khan' appeared in the last 10 years
SELECT *
FROM netflix
WHERE casts ILIKE '%Salman Khan%'
AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India
SELECT TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) AS actor, COUNT(*) AS movie_count
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY movie_count DESC
LIMIT 10;

-- 15. Categorize content as 'Good' or 'Bad' based on the presence of 'kill' or 'violence' in description
SELECT category, type, COUNT(*) AS content_count
FROM (
    SELECT *,
           CASE 
               WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
               ELSE 'Good'
           END AS category
    FROM netflix
) AS categorized_content
GROUP BY category, type
ORDER BY type;
