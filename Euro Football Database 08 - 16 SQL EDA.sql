/*
title: 
author: Matthew Myers
database resource: https://www.kaggle.com/hugomathien/soccer
*/

/*
Link to Tableau Dashboard
https://public.tableau.com/views/EuroSoccerEDA200809-2001516/EuroSoccer1?:language=en-US&:display_count=n&:origin=viz_share_link
*/

-- Queries for Tableau project

-- Breakdown of professional player birthday months
SELECT STRFTIME('%m', birthday) AS month, COUNT(STRFTIME('%m', birthday)) AS births_in_month,
  (SELECT COUNT(id) FROM Player) AS total_players
--  (COUNT(STRFTIME('%m', birthday)) / (SELECT COUNT(*) FROM Player) * 100.0) AS prop_births
FROM Player
GROUP BY month;

-- Proportions of professional player birthday months using CTE
With Prop_Births (month, births_in_month, total_players)

AS
(
-- Distribution of professional player birthday months
SELECT STRFTIME('%m', birthday) AS month, COUNT(STRFTIME('%m', birthday)) AS births_in_month,
  (SELECT COUNT(*) FROM Player) AS total_players
FROM Player
GROUP BY month
)

SELECT CASE month WHEN '01' THEN 'Jan' WHEN '02' THEN 'Feb' WHEN '03' THEN 'Mar' WHEN '04' THEN 'Apr'
  WHEN '05' THEN 'May' WHEN '06' THEN 'Jun' WHEN '07' THEN 'Jul' WHEN '08' THEN 'Aug' WHEN '09' THEN 'Sep'
  WHEN '10' THEN 'Oct' WHEN '11' THEN 'Nov' WHEN '12' THEN 'Dec' ELSE '' END as month, 
  ROUND(births_in_month*100.0/total_players, 2) AS prob_birth_month
FROM Prop_Births;

-- Matches and final scores from Euro Top 6 Leagues with team names(England, France, Germany, Italy, Spain, Portugal)
SELECT c.name AS country, l.name AS league, m.season, m.stage, m.date, m.match_api_id, 
  t1.team_long_name AS home_team, t2.team_long_name AS away_team, m.home_team_goal, 
  m.away_team_goal
FROM Country AS c
LEFT JOIN League AS l ON c.id = l.country_id
LEFT JOIN Match AS m ON c.id = m.country_id AND l.id = m.league_id
LEFT JOIN Team AS t1 ON m.home_team_api_id = t1.team_api_id
LEFT JOIN Team AS t2 ON m.away_team_api_id = t2.team_api_id
WHERE country IN ('England', 'France', 'Germany', 'Italy', 'Portugal', 'Spain');

-- Avg goals per game in all leagues
SELECT c.name AS country, l.name AS league, ROUND(AVG(m.home_team_goal + m.away_team_goal), 2)
  AS avg_goals_per_game
FROM Country AS c
LEFT JOIN League AS l ON c.id = l.country_id
LEFT JOIN Match AS m ON c.id = m.country_id AND l.id = m.league_id
GROUP BY country
ORDER BY avg_goals_per_game DESC;

-- Calculate Avg of team goals in top 6 leagues overall
SELECT c.name AS country, l.name AS league, ROUND(AVG(m.home_team_goal), 2) AS avg_home_goals, 
  ROUND(AVG(m.away_team_goal), 2) AS avg_away_goals, ROUND(AVG(m.home_team_goal + m.away_team_goal), 2)
  AS avg_goals_per_game, ROUND(AVG(m.home_team_goal - m.away_team_goal), 2)
  AS avg_goal_dif, SUM(m.home_team_goal + m.away_team_goal) AS total_goals, 
  COUNT(DISTINCT season) AS seasons, COUNT(DISTINCT stage) AS stages, COUNT(m.id) AS matches
FROM Country AS c
LEFT JOIN League AS l ON c.id = l.country_id
LEFT JOIN Match AS m ON c.id = m.country_id AND l.id = m.league_id
WHERE country IN ('England', 'France', 'Germany', 'Italy', 'Portugal', 'Spain')
GROUP BY country
ORDER BY avg_goals_per_game DESC, total_goals DESC;

-- Best 5 Seasons for Avg Goals per Game in Top 6 leagues
SELECT c.name AS country, l.name AS league, season, ROUND(AVG(m.home_team_goal + m.away_team_goal), 2)
  AS avg_goals_per_game, ROUND(AVG(m.home_team_goal - m.away_team_goal), 2)
  AS avg_goal_dif, SUM(m.home_team_goal + m.away_team_goal) AS total_goals, 
  COUNT(m.id) AS matches
FROM Country AS c
LEFT JOIN League AS l ON c.id = l.country_id
LEFT JOIN Match AS m ON c.id = m.country_id AND l.id = m.league_id
WHERE country IN ('England', 'France', 'Germany', 'Italy', 'Portugal', 'Spain')
GROUP BY country, m.season
ORDER BY avg_goals_per_game DESC, total_goals DESC
LIMIT 5;


