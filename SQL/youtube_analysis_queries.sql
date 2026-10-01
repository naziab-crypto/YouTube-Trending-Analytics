CREATE TABLE staging_youtube (
 video_id VARCHAR(50), trending_date DATE, title TEXT, channel_title VARCHAR(255),
 category_id INT, category_name VARCHAR(150), publish_time TIME, publish_date DATE,
 publish_hour INT,publish_day VARCHAR(10), publish_month VARCHAR(10),
 country_code CHAR(2), country VARCHAR(100), tags TEXT, tag_count INT, title_length INT,
 views BIGINT, likes BIGINT, dislikes BIGINT, comment_count BIGINT,
 engagement_rate DECIMAL(12,8), like_ratio DECIMAL(12,8), time_to_trend_days INT,
 comments_disabled VARCHAR(5), ratings_disabled VARCHAR(5), video_error_or_removed VARCHAR(5),
 thumbnail_link TEXT, description TEXT
);
CREATE TABLE countries (
 country_code CHAR(2) PRIMARY KEY, country_name VARCHAR(100) NOT NULL
);
CREATE TABLE categories (
 country_code CHAR(2), category_id INT, category_name VARCHAR(150) NOT NULL,
 PRIMARY KEY(country_code,category_id),
 FOREIGN KEY(country_code) REFERENCES countries(country_code)
);
CREATE TABLE channels (
    channel_id BIGSERIAL PRIMARY KEY,
    channel_title VARCHAR(255) NOT NULL,
   -- CONSTRAINT uq_channel UNIQUE (channel_title)
);
CREATE TABLE videos1 (
    video_key BIGSERIAL PRIMARY KEY,
    video_id VARCHAR(50) NOT NULL,
    trending_date DATE NOT NULL,
    country_code CHAR(2) NOT NULL,
    title TEXT,
    channel_id BIGINT,
    category_id INT,
    publish_time TIMESTAMP,
    publish_date DATE,
    publish_hour SMALLINT,
    publish_day VARCHAR(10),
    publish_month VARCHAR(10),
    tags TEXT,
    tag_count INT,
    title_length INT,
    views BIGINT,
    likes BIGINT,
    dislikes BIGINT,
    comment_count BIGINT,
    engagement_rate DECIMAL(12,8),
    like_ratio DECIMAL(12,8),
    time_to_trend_days INT,
    comments_disabled BOOLEAN,
    ratings_disabled BOOLEAN,
    video_error_or_removed BOOLEAN,
    thumbnail_link TEXT,
    description TEXT,

    CONSTRAINT uq_record
        UNIQUE (video_id, trending_date, country_code),

    FOREIGN KEY (country_code)
        REFERENCES countries(country_code),

    FOREIGN KEY (country_code, category_id)
        REFERENCES categories(country_code, category_id),

    FOREIGN KEY (channel_id)
        REFERENCES channels(channel_id)
);
CREATE INDEX idx_date
ON videos(trending_date);

CREATE INDEX idx_category
ON videos(country_code, category_id);

CREATE INDEX idx_channel
ON videos(channel_id);
TRUNCATE TABLE staging_youtube;
SELECT COUNT(*) FROM staging_youtube;
--insert country
INSERT INTO countries (country_code, country_name)
SELECT DISTINCT country_code, country
FROM staging_youtube
ON CONFLICT (country_code) DO NOTHING;
SELECT * FROM countries
ORDER BY country_code;
--category
INSERT INTO categories (country_code, category_id, category_name)
SELECT DISTINCT country_code, category_id, category_name
FROM staging_youtube
WHERE category_id IS NOT NULL
ON CONFLICT (country_code, category_id) DO NOTHING;
SELECT *
FROM categories
ORDER BY country_code, category_id;
--channels
INSERT INTO channels (channel_title)
SELECT DISTINCT channel_title
FROM staging_youtube
WHERE channel_title IS NOT NULL
  AND channel_title <> ''
ON CONFLICT (channel_title) DO NOTHING;
SELECT COUNT(*) FROM channels;
INSERT INTO videos (
    video_id,
    trending_date,
    country_code,
    title,
    channel_id,
    category_id,
    publish_time,
    publish_date,
    publish_hour,
    publish_day,
    publish_month,
    tags,
    tag_count,
    title_length,
    views,
    likes,
    dislikes,
    comment_count,
    engagement_rate,
    like_ratio,
    time_to_trend_days,
    comments_disabled,
    ratings_disabled,
    video_error_or_removed,
    thumbnail_link,
    description
)
SELECT
    s.video_id,
    s.trending_date,
    s.country_code,
    s.title,
    c.channel_id,
    s.category_id,
    (s.publish_date + s.publish_time),
    s.publish_date,
    s.publish_hour,
    s.publish_day,
    s.publish_month,
    s.tags,
    s.tag_count,
    s.title_length,
    s.views,
    s.likes,
    s.dislikes,
    s.comment_count,
    s.engagement_rate,
    s.like_ratio,
    s.time_to_trend_days,
    CASE 
        WHEN LOWER(TRIM(s.comments_disabled)) = 'true' THEN TRUE
        ELSE FALSE
    END,

    CASE 
        WHEN LOWER(TRIM(s.ratings_disabled)) = 'true' THEN TRUE
        ELSE FALSE
    END,

    CASE 
        WHEN LOWER(TRIM(s.video_error_or_removed)) = 'true' THEN TRUE
        ELSE FALSE
    END,

    s.thumbnail_link,
    s.description
FROM staging_youtube s
LEFT JOIN channels c
    ON s.channel_title = c.channel_title
ON CONFLICT (video_id, trending_date, country_code)
DO NOTHING;
SELECT COUNT(*) FROM videos;
SELECT * FROM videos;

DROP INDEX IF EXISTS idx_date;
DROP INDEX IF EXISTS idx_category;
DROP INDEX IF EXISTS idx_channel;

SELECT COUNT(*) AS staging_rows FROM staging_youtube;
SELECT COUNT(*) AS countries FROM countries;
SELECT COUNT(*) AS channels FROM channels;
SELECT COUNT(*) AS videos FROM videos;

CREATE OR REPLACE VIEW vw_video_analytics AS
SELECT v.video_key,v.video_id,v.trending_date,v.country_code,co.country_name country,
v.title,ch.channel_title,v.category_id,ca.category_name,v.publish_time,v.publish_date,
v.publish_hour,v.publish_day,v.publish_month,v.tag_count,v.title_length,v.views,v.likes,
v.dislikes,v.comment_count,v.engagement_rate,v.like_ratio,v.time_to_trend_days
FROM videos v JOIN countries co ON co.country_code=v.country_code
LEFT JOIN categories ca ON ca.country_code=v.country_code AND ca.category_id=v.category_id
LEFT JOIN channels ch ON ch.channel_id=v.channel_id;

CREATE OR REPLACE VIEW vw_category_performance AS
SELECT country,category_name,COUNT(*) trending_records,SUM(views) total_views,
ROUND(AVG(views),0) avg_views,ROUND(AVG(engagement_rate)*100,2) avg_engagement_pct
FROM vw_video_analytics GROUP BY country,category_name;

CREATE OR REPLACE VIEW vw_channel_performance AS
SELECT channel_title,COUNT(*) trending_records,COUNT(DISTINCT video_id) distinct_videos,
SUM(views) total_views,ROUND(AVG(views),0) avg_views,
ROUND(AVG(engagement_rate)*100,2) avg_engagement_pct
FROM vw_video_analytics GROUP BY channel_title;

SELECT *
FROM vw_category_performance
ORDER BY total_views DESC
LIMIT 10;
SELECT *
FROM vw_channel_performance
ORDER BY total_views DESC
LIMIT 10;

analytical queries
-- 1. Total records
SELECT COUNT(*) total_records FROM vw_video_analytics;
-- 2. Records by country
SELECT country,COUNT(*) records FROM vw_video_analytics GROUP BY country ORDER BY records DESC;
-- 3. Views by country
SELECT country,SUM(views) total_views FROM vw_video_analytics GROUP BY country ORDER BY total_views DESC;
- 4. Highest-view categories
SELECT category_name,SUM(views) total_views FROM vw_video_analytics GROUP BY category_name ORDER BY total_views DESC;
-- 5. Average views by category
SELECT category_name,ROUND(AVG(views),0) avg_views FROM vw_video_analytics GROUP BY category_name ORDER BY avg_views DESC;
-- 6. Engagement by category
SELECT category_name,ROUND(AVG(engagement_rate)*100,2) engagement_pct FROM vw_video_analytics GROUP BY category_name ORDER BY engagement_pct DESC;
- 7. Category by country
SELECT country,category_name,SUM(views) total_views FROM vw_video_analytics GROUP BY country,category_name ORDER BY country,total_views DESC;
-- 8. Top channels by views
SELECT channel_title,SUM(views) total_views FROM vw_video_analytics GROUP BY channel_title ORDER BY total_views DESC LIMIT 20;
- 9. Channels by distinct videos
SELECT channel_title,COUNT(DISTINCT video_id) trending_videos FROM vw_video_analytics GROUP BY channel_title ORDER BY trending_videos DESC LIMIT 20;
-- 10. Channels by trending appearances
SELECT channel_title,COUNT(*) appearances FROM vw_video_analytics GROUP BY channel_title ORDER BY appearances DESC LIMIT 20;
 11. Best publish day
SELECT publish_day,ROUND(AVG(views),0) avg_views FROM vw_video_analytics GROUP BY publish_day ORDER BY avg_views DESC;
- 12. Best publish hour
SELECT publish_hour,ROUND(AVG(views),0) avg_views FROM vw_video_analytics GROUP BY publish_hour ORDER BY avg_views DESC;
 14. Time to trend by category
SELECT category_name,ROUND(AVG(time_to_trend_days),2) avg_days FROM vw_video_analytics GROUP BY category_name ORDER BY avg_days;
 15. Fastest trending videos
SELECT title,channel_title,country,time_to_trend_days,views FROM vw_video_analytics WHERE time_to_trend_days IS NOT NULL ORDER BY time_to_trend_days,views DESC LIMIT 25;
 16. Tag count vs engagement
SELECT tag_count,COUNT(*) records,ROUND(AVG(engagement_rate)*100,2) engagement_pct FROM vw_video_analytics GROUP BY tag_count HAVING COUNT(*)>=100 ORDER BY tag_count;
- 17. Title length vs engagement
SELECT CASE WHEN title_length<30 THEN '<30' WHEN title_length<60 THEN '30-59' WHEN title_length<90 THEN '60-89' ELSE '90+' END title_band,COUNT(*) records,ROUND(AVG(engagement_rate)*100,2) engagement_pct FROM vw_video_analytics GROUP BY title_band;
- 18. Most viewed
SELECT title,channel_title,country,category_name,views FROM vw_video_analytics ORDER BY views DESC LIMIT 20;
 19. Most liked
SELECT title,channel_title,likes,views,country FROM vw_video_analytics ORDER BY likes DESC LIMIT 20;
 20. Most commented
SELECT title,channel_title,comment_count,views,country FROM vw_video_analytics ORDER BY comment_count DESC LIMIT 20;
-- 21. Like ratio by category
SELECT category_name,ROUND(AVG(like_ratio)*100,2) like_ratio_pct FROM vw_video_analytics GROUP BY category_name ORDER BY like_ratio_pct DESC;
22. Monthly performance
SELECT publish_month,COUNT(*) records,SUM(views) total_views FROM vw_video_analytics GROUP BY publish_month ORDER BY total_views DESC;
-- 23. Daily trend
SELECT trending_date,SUM(views) total_views FROM vw_video_analytics GROUP BY trending_date ORDER BY trending_date;
-- 24. Country-category engagement
SELECT country,category_name,ROUND(AVG(engagement_rate)*100,2) engagement_pct FROM vw_video_analytics GROUP BY country,category_name ORDER BY country,engagement_pct DESC;
- 25. Multi-country videos
SELECT video_id,MAX(title) title,COUNT(DISTINCT country_code) countries_trended FROM vw_video_analytics GROUP BY video_id HAVING COUNT(DISTINCT country_code)>1 ORDER BY countries_trended DESC;
-- 26. Multi-day trending
SELECT video_id,MAX(title) title,country,COUNT(DISTINCT trending_date) trending_days FROM vw_video_analytics GROUP BY video_id,country HAVING COUNT(DISTINCT trending_date)>1 ORDER BY trending_days DESC;
-- 27. Category competition
SELECT category_name,COUNT(*) trending_records,COUNT(DISTINCT channel_title) distinct_channels FROM vw_video_analytics GROUP BY category_name ORDER BY trending_records DESC;
- 28. Country diversity by category
SELECT category_name,COUNT(DISTINCT country_code) country_count,COUNT(DISTINCT video_id) distinct_videos FROM vw_video_analytics GROUP BY category_name ORDER BY country_count DESC,distinct_videos DESC;
- 29. Day/hour performance
SELECT publish_day,publish_hour,COUNT(*) records,ROUND(AVG(views),0) avg_views,ROUND(AVG(engagement_rate)*100,2) engagement_pct FROM vw_video_analytics GROUP BY publish_day,publish_hour ORDER BY avg_views DESC;

30. Forecast benchmark
SELECT category_name,ROUND(AVG(views),0) expected_avg_views,MIN(views) min_views,MAX(views) max_views,ROUND(AVG(engagement_rate)*100,2) expected_engagement_pct,ROUND(AVG(time_to_trend_days),2) expected_days_to_trend FROM vw_video_analytics GROUP BY category_name ORDER BY expected_avg_views DESC;























--copy staging_youtube FROM 'C:/YouTube_Trending_Videos_PostgreSQL_NO_HEADER.csv' WITH (FORMAT csv, HEADER false, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');
