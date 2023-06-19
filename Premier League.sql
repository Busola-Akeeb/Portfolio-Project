SELECT *
FROM results;


-- 1. Most prolific attacking team

SELECT Team, SUM(goals) AS Total_goals
FROM(
     SELECT HomeTeam AS Team, FTHG AS goals
     FROM results
     UNION ALL
     SELECT AwayTeam AS Team, FTAG AS goals
     FROM results
) Subquery
GROUP BY Team
ORDER BY Total_goals DESC;

-- Strongest team defensively 

SELECT Team, SUM(goals) AS Goals_conceded
FROM(
     SELECT HomeTeam AS Team, FTAG AS goals
     FROM results
     UNION ALL
     SELECT AwayTeam AS Team, FTHG AS goals
     FROM results
) Subquery
GROUP BY Team
ORDER BY Goals_conceded;

-- 2. CLeansheets kept by each team

SELECT Team, SUM(goals) AS Total_cleansheets
FROM(
     SELECT HomeTeam AS Team, COUNT(FTAG) AS goals
     FROM results
	 WHERE FTAG = 0
	 GROUP BY HomeTeam
     UNION ALL
     SELECT AwayTeam AS Team, COUNT(FTHG) AS goals
     FROM results
	 WHERE FTHG = 0
	 GROUP BY AwayTeam
) Subquery
GROUP BY Team
ORDER BY Total_cleansheets DESC;

-- 3. Average number of goals scored per match

SELECT Team, AVG(goals) AS Avg_goals_per_match
FROM(
SELECT HomeTeam AS Team, FTHG AS goals
FROM results
UNION ALL
SELECT AwayTeam AS Team, FTAG AS goals
FROM results
) Subquery
GROUP BY Team
ORDER BY Avg_goals_per_match DESC;

-- 4. Home vs Away Performance (Goals scored and cleansheets kept)

SELECT Team, SUM(Home_goals) AS Home_goals, SUM(Away_goals) AS Away_goals,
       SUM(Home_cleansheets) AS Home_cleansheets, SUM(Away_cleansheets) AS Away_cleansheets
FROM (
    SELECT HomeTeam AS Team, SUM(FTHG) AS Home_goals, 0 AS Away_goals,
           COUNT(CASE WHEN FTAG = 0 THEN 1 END) AS Home_cleansheets, 0 AS Away_cleansheets
    FROM results
    GROUP BY HomeTeam
    UNION ALL
    
    SELECT AwayTeam AS Team, 0 AS Home_goals, SUM(FTAG) AS Away_goals,
           0 AS Home_cleansheets, COUNT(CASE WHEN FTHG = 0 THEN 1 END) AS Away_cleansheets
    FROM results
    GROUP BY AwayTeam
) Subquery
GROUP BY Team
ORDER BY Home_goals DESC;

-- Home vs Away Performance (Matches won/lost)

SELECT Team, SUM(Home_Wins) AS Home_Wins, SUM(Away_Wins) AS Away_Wins,
       SUM(Home_Losses) AS Home_Losses, SUM(Away_Losses) AS Away_Losses
FROM (
    SELECT HomeTeam AS Team, COUNT(CASE WHEN FTHG > FTAG THEN 1 END) AS Home_Wins, 0 AS Away_Wins,
           COUNT(CASE WHEN FTHG < FTAG THEN 1 END) AS Home_Losses, 0 AS Away_Losses
    FROM results
    GROUP BY HomeTeam
    
    UNION ALL
    
    SELECT AwayTeam AS Team, 0 AS Home_Wins, COUNT(CASE WHEN FTAG > FTHG THEN 1 END) AS Away_Wins,
           0 AS Home_Losses, COUNT(CASE WHEN FTAG < FTHG THEN 1 END) AS Away_Losses
    FROM results
    GROUP BY AwayTeam
) Subquery
GROUP BY Team
ORDER BY Home_Wins DESC;

-- 5. How did the teams performance change over the course of the season?

SELECT team, SUM(points) AS total_points
FROM
(
    SELECT HomeTeam AS team,
           CASE WHEN FTHG > FTAG THEN 3
                WHEN  FTHG = FTAG THEN 1
                ELSE 0
           END AS points
    FROM results
    
    UNION ALL
    
    SELECT AwayTeam AS team,
           CASE WHEN FTAG > FTHG THEN 3
                WHEN FTAG = FTHG THEN 1
                ELSE 0
           END AS points
    FROM results
) AS subquery
GROUP BY team
ORDER BY total_points DESC;

-- Cummulative Points

WITH team_results AS (
    SELECT Date, HomeTeam, AwayTeam, FTHG, FTAG,
           CASE
               WHEN FTHG > FTAG THEN 3
               WHEN FTHG = FTAG THEN 1
               ELSE 0
           END AS points
    FROM results

    UNION ALL

    SELECT Date, AwayTeam AS team, HomeTeam, FTAG, FTHG,
           CASE
               WHEN FTAG > FTHG THEN 3
               WHEN FTAG = FTHG THEN 1
               ELSE 0
           END AS points
    FROM results
)

SELECT Date, HomeTeam, AwayTeam, FTHG, FTAG,
       SUM(points) OVER (PARTITION BY team ORDER BY Date) AS cumulative_points
FROM team_results
ORDER BY Date;

   
   
   SELECT Date, HomeTeam, AwayTeam, FTHG, FTAG, SUM(points) OVER (PARTITION BY team ORDER BY Date) AS cumulative_points,
           CASE
               WHEN FTHG > FTAG THEN 3
               WHEN FTHG = FTAG THEN 1
               ELSE 0
           END AS points
    FROM results

    UNION ALL

    SELECT Date, AwayTeam AS team, HomeTeam, FTAG, FTHG, SUM(points) OVER (PARTITION BY team ORDER BY Date) AS cumulative_points,
           CASE
               WHEN FTAG > FTHG THEN 3
               WHEN FTAG = FTHG THEN 1
               ELSE 0
           END AS points
    FROM results


-- Disciplinary Actions per team


SELECT Team, SUM(Red_Cards) AS Total_Red_Cards
FROM(
     SELECT HomeTeam AS Team, HR AS Red_Cards
     FROM results
     UNION ALL
     SELECT AwayTeam AS Team, AR AS Red_Cards
     FROM results
) Subquery
GROUP BY Team
ORDER BY Team;

SELECT Team, SUM(Yellow_Cards) AS Total_Yellow_Cards
FROM(
     SELECT HomeTeam AS Team, HY AS Yellow_Cards
     FROM results
     UNION ALL
     SELECT AwayTeam AS Team, AY AS Yellow_Cards
     FROM results
) Subquery
GROUP BY Team
ORDER BY Team;




