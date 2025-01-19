
-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

select * from public.spotify
limit 100

-- EDA

--Total rows
select count(*) from spotify s 

--Total artists
 select count(distinct artist) from spotify  
 
 --Total albums
 select count(distinct album) from  spotify
 
 --Total album types
 select distinct album_type from spotify
 
 --Longest and shortest song length
 select max(duration_min) from spotify
 
 select min(duration_min) from spotify 
 
--Remove all songs with duration_min = 0
 select * from spotify 
 where duration_min = 0

 	-- And delete them
 	delete from spotify 
 	where duration_min = 0
 	
 
 --Distinct channels	
 select distinct channel from spotify 

 --Distinct platforms
 select distinct most_played_on from spotify
 
-- Tracks with more than 1 billion streams
select * from spotify
where stream > 1000000000

 
--List of all albums along with their respective artists.
select distinct album, artist from spotify
order by 1

--Total number of comments for tracks where licensed = TRUE.
select sum(comments) as total_comments
	from spotify 
where licensed = 'true'

--All tracks that belong to the album type single.
select (track) from spotify
where album_type = 'single'

--Total number of tracks by each distinct artist.
 select 
 	artist, 
 	count(*) as total_no_songs
 from spotify
 group by artist
 order by 2 desc
 
 
 -- Average "danceability" of tracks in each album.
select 
	album, 
	avg(danceability) as avg_dance
 from spotify
 group by 1
 order by 2 desc 
 
 -- Top 5 tracks with the highest energy values.
 select 
 	track,
 	max(energy)
 from spotify 
 group by 1
 order by 2 desc
 limit 5
 
 --List all tracks along with their views and likes where official_video = TRUE.
 
select 
	track, 
	sum(views) as total_views,
	sum(likes) as total_likes
from spotify
where official_video = 'true'
group by 1
order by 2 desc
--limit 5

-- Total views of all associated tracks for each album
select
	album, 
	track, 
	sum(views) as total_view
from spotify
group by album, track 
order by 3 desc


-- Tracks that have been streamed on Spotify more than YouTube.

select * from 
(select 
 	track,
 	coalesce(sum(case when most_playedon = 'Youtube' then stream end),0) as streamed_on_youtube,
 	coalesce(sum(case when most_playedon = 'Spotify' then stream end),0) as streamed_on_spotify
from spotify 
group by 1
) as t1 
where 
	streamed_on_youtube > streamed_on_spotify 
	and
	streamed_on_youtube <> 0
 
 	
-- Top 3 most-viewed tracks for each artist using window functions.
with artist_rank 
as 
(select 
	artist, 
	track, 
	sum(views) as total_view,
	dense_rank() over(partition by artist order by sum(views) desc) as rank
from spotify 
group by 1, 2
order by 1, 3 desc
)
select * from artist_rank  
where rank <= 3

-- Find tracks where the liveness score is above the average.
select 
	track,
	artist,
	liveness
from spotify
where liveness > (select avg(liveness) from spotify)

-- Calculate the difference between the highest and lowest energy values for tracks in each album.
with cte 
as 
(select
   	album, 
   	max(energy) as highest_energy,
   	min(energy) as lowest_energy
   from spotify 
   group by 1
   )
   select
   	album, 
   	highest_energy - lowest_energy as energy_diff
   from cte
   order by 2 desc

   
 -- Tracks where the energy-to-liveness ratio is greater than 1.2.
select
	track, 
	energy / liveness as e_to_l_ratio
from spotify
where energy / liveness > 1.2
order by 2 asc 

-- Cumulative sum of likes for tracks ordered by the number of views
select
	track, 
	sum(likes) over (order by views) as cumulative_sum
from spotify
	order by cumulative_sum desc

 
 
 