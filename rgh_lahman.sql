/* 1. What range of years for baseball games played does the provided database cover? */
SELECT MIN(yearid),MAX(yearid)
FROM teams
--1871 to 2016

/* 2a. Find the name and height of the shortest player in the database. 
Created a subquery to grab shortest player only. Then selected all and then narrowed down columns to keep answer precise. */
SELECT height, namegiven, namefirst, namelast
FROM people
WHERE height =
	(SELECT MIN(height)
	FROM people);
--Eddie Gaedel/Edward Carl, 43 inches

/* 2b. How many games did he play in? What is the name of the team for which he played?
Turn above query into a subquery to stick with Eddie, and select all columns from appearances table. Narrow down to 
game count and teamid. Join this to teams table and grab team name.*/
SELECT *
FROM appearances AS a
WHERE playerid IN
	(SELECT playerid
	FROM people
	WHERE height =
		(SELECT MIN(height)
		FROM people));
		
SELECT DISTINCT G_all, a.teamid, t.name, p.playerid, p.namefirst, p.namelast
FROM appearances AS a
LEFT JOIN teams AS t
ON a.teamid = t.teamid
JOIN people AS p
ON a.playerid = p.playerid
WHERE p.playerid IN
	(SELECT playerid
	FROM people
	WHERE height =
		(SELECT MIN(height)
		FROM people));
--played in 1 game, for the St. Louis Browns

/* 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s 
first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order 
by the total salary earned. Which Vanderbilt player earned the most money in the majors?

First, find Vandy id in schools table. Then, search distinct college players with Vandy id in college playing table. Turn that 
search into a subquery, join it to people and salaries. Add salaries for total salaries for all players. */

SELECT *
FROM schools
WHERE schoolname ILIKE '%Vander%';

SELECT DISTINCT(playerid)
FROM collegeplaying
WHERE schoolid = 'vandy';

SELECT *
FROM salaries;

SELECT namegiven, namefirst, namelast, sub.playerid, SUM(s.salary) AS total_salary
FROM people AS p
JOIN 
	(SELECT distinct(playerid)
	FROM collegeplaying
	WHERE schoolid = 'vandy') AS sub
ON sub.playerid = p.playerid
JOIN salaries AS s
ON s.playerid = p.playerid
GROUP BY namegiven, namefirst, namelast, sub.playerid
ORDER BY SUM(s.salary) DESC;
--David Taylor Price earned the most money at $81,851,296

/* 4. Using the fielding table, group players into three groups based on their position: label players with 
position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". 
Determine the number of putouts made by each of these three groups in 2016.*/ --HAAAALLLPPPP

SELECT *
FROM fielding;

SELECT SUM(po)
FROM fielding
WHERE yearid = 2016
--total putouts 2016: 129,918

SELECT SUM(po)
FROM (SELECT playerid, pos, po, yearid,
CASE 
	WHEN pos = 'OF' THEN 'Outfield'
	WHEN pos IN ('SS','1B','2B','3B') THEN 'Infield'
	ELSE 'Battery' 
	END AS position
	FROM fielding
	WHERE yearid = 2016) AS sub
--total putouts 2016: 129,918

/*Group players into three categories of positions. Turn that table into a CTE. Sum putouts by position and pull from CTE table*/

WITH pf AS (
SELECT playerid, pos, po, yearid,
CASE 
	WHEN pos = 'OF' THEN 'Outfield'
	WHEN pos IN ('SS','1B','2B','3B') THEN 'Infield'
	ELSE 'Battery' 
	END AS position
FROM fielding
WHERE yearid = 2016)

SELECT pf.position, SUM(pf.po)
FROM pf
GROUP BY pf.position
--Battery: 41,424 / Infield: 58,934 / Outfield: 29,560

SELECT position_label, SUM(po) AS total_putouts
FROM(
	SELECT playerid, po, pos,
	CASE WHEN pos = 'OF' THEN 'Outfield'
	WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
	WHEN pos IN ('P', 'C') THEN 'Battery' END AS position_label
	FROM fielding
	WHERE yearID = 2016) AS sub
GROUP BY position_label

/* 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. 
Do the same for home runs per game. Do you see any trends?*/

/*comparing strikout numbers from different tables*/
SELECT SUM(b.so), SUM(p.so)
FROM batting AS b
JOIN pitching AS p
ON b.playerid = p.playerid

SELECT SUM(so)
FROM batting
UNION ALL
SELECT SUM(so)
FROM battingpost

/*Select all relevant columns from teams, add case statement for decades column. Create CTE */
WITH ths AS (
	SELECT yearid, teamid, (so) AS strikeouts_per_season, (hr) AS homeruns_per_season, g AS games_per_season,
CASE 
	WHEN yearid BETWEEN 1920 AND 1929 THEN 1920
	WHEN yearid BETWEEN 1930 AND 1939 THEN 1930
	WHEN yearid BETWEEN 1940 AND 1949 THEN 1940
	WHEN yearid BETWEEN 1950 AND 1959 THEN 1950
	WHEN yearid BETWEEN 1960 AND 1969 THEN 1960
	WHEN yearid BETWEEN 1970 AND 1979 THEN 1970
	WHEN yearid BETWEEN 1980 AND 1989 THEN 1980
	WHEN yearid BETWEEN 1990 AND 1999 THEN 1990
	WHEN yearid BETWEEN 2000 AND 2009 THEN 2000
	ELSE 2010
	END AS decade
FROM teams
WHERE yearid > 1919)

/*Add all strikeouts per decade, homeruns per decade, games per decade to create tidier table. Cast values as floats for accuracy in rounding.
Add as subquery to find average per game by dividing both strikeouts and homeruns per game. Round to 2, and order by decade.*/

/*SELECT decade, CAST(SUM(strikeouts_per_season) AS float) AS strikeouts_per_decade, 
CAST(SUM(homeruns_per_season) AS float) AS homeruns_per_decade, 
CAST(SUM(games_per_season) AS float) AS games_per_decade
FROM ths
GROUP BY decade
ORDER BY decade;*/

SELECT decade, ROUND((strikeouts_per_decade/games_per_decade)::numeric,2) AS avg_game_so, 
ROUND((homeruns_per_decade/games_per_decade)::numeric,2) AS avg_game_hr
FROM (
	SELECT decade, CAST(SUM(strikeouts_per_season) AS float) AS strikeouts_per_decade, 
	CAST(SUM(homeruns_per_season) AS float) AS homeruns_per_decade, 
	CAST(SUM(games_per_season) AS float) AS games_per_decade
	FROM ths
	GROUP BY decade) AS sub
GROUP BY decade, avg_game_so, avg_game_hr
ORDER BY decade;
--Trends show average strikeouts rising over decades. Same for homeruns, but not as quickly.

/* 6. Find the player who had the most success stealing bases in 2016, where success is measured as 
the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a 
stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.*/

/* Select relevant columns from batting and join to people to get names as well. (sb-cs)/sb gives percent success. Filter by year
and at least 20 attempts. Order by percent descending.*/

SELECT b.playerid, p.namefirst, p.namelast, sb AS stolen_bases, cs AS caught_stealing,
ROUND(((sb/CAST((sb+cs) AS float)*100)::numeric),2) AS perc_stolen 
FROM batting AS b
JOIN people AS p
ON b.playerid = p.playerid
WHERE sb >= 20
AND yearid = 2016
ORDER BY perc_stolen DESC;
--Christ Owings: 91.30

/* 7ab. From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? 
What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually 
small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year.*/

/*Following two queries select relevant columns in team table, filtering years between 1970 and 2016, and if team won World Series*/
SELECT yearid, teamid, name, w, wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
AND wswin = 'N'
ORDER BY w DESC;
--Seattle Mariners: 116 in 2001

SELECT yearid, teamid, name, w, wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
AND wswin = 'Y'
ORDER BY w;
--Los Angeles Dodgers: 63 in 1981

--This looks at the appx amount of games played per season every season.
SELECT ROUND(AVG(g),2), yearid
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
GROUP BY yearid
ORDER BY yearid;
/*Regular amount of games (first 154, then 162) dipped to 107 (110 for Dodgers) in 1981, 
due to a strike (according to the internet)*/

SELECT yearid, teamid, name, w, wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
AND wswin = 'Y'
AND yearid <> 1981
ORDER BY w;
--(without 1981 included) St. Louis Cardinals: 83 in 2006

/* 7c. How often from 1970 – 2016 was it the case that a team with the most wins 
also won the world series? What percentage of the time?*/

/*Select same columns as above. Add a column with a window function to report highest wins
per year. Turn this into a subquery, and count the columns where both max_wins_per_year matches wins
column and team won world series. Move wswin filter to outer query.*/
SELECT COUNT(*)
FROM (
	SELECT yearid, teamid, name, w, wswin,
		MAX(w) OVER(PARTITION BY yearid) AS max_wins_per_year
	FROM teams
	WHERE yearid BETWEEN 1970 AND 2016
		AND yearid <> 1981) AS sub
WHERE w = max_wins_per_year
	AND wswin = 'Y'
--12 times

SELECT ROUND((CAST(SUM(CASE WHEN wswin = 'Y' THEN 1 ELSE 0 END) AS numeric)*100 / COUNT(*)),2)
FROM(
	SELECT yearid, teamid, name, w, wswin,
		MAX(w) OVER(PARTITION BY yearid) AS max_wins_per_year
	FROM teams
	WHERE yearid BETWEEN 1970 AND 2016
		AND yearid NOT IN (1981, 1994)) AS sub
WHERE w = max_wins_per_year
--23.53%

/* 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average 
attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). 
Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. 
Repeat for the lowest 5 average attendance.*/
SELECT *
FROM homegames
WHERE year = 2016
AND games >= 10

/* Select relevant columns, and divide attendance by total games for average attendance. Limit to top 5. Join homegames with teams and parks.
Join on multiple columns since teams show up each year (causing duplicates). Filter by year and minimum games played. */
SELECT year, team, park, attendance, games, (attendance/games) AS avg_attendance_per_game
FROM homegames
WHERE year = 2016
AND games >= 10
ORDER BY avg_attendance_per_game DESC
LIMIT 5;

SELECT h.year, h.team, h.park, p.park_name, h.attendance, h.games, (h.attendance/h.games) AS avg_attendance_per_game, t.name
FROM homegames AS h
JOIN teams AS t
on t.teamid = h.team
AND t.yearid = h.year
JOIN parks AS p
on h.park = p.park
WHERE year = 2016
AND games >= 10
ORDER BY avg_attendance_per_game DESC
LIMIT 5;
--Top 5 park and team attendance

SELECT h.year, h.team, h.park, p.park_name, h.attendance, h.games, (h.attendance/h.games) AS avg_attendance_per_game, t.name
FROM homegames AS h
JOIN teams AS t
on t.teamid = h.team
AND t.yearid = h.year
JOIN parks AS p
on h.park = p.park
WHERE year = 2016
AND games >= 10
ORDER BY avg_attendance_per_game
LIMIT 5;
--Bottom 5 park and team attendance

/* 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? 
Give their full name and the teams that they were managing when they won the award.*/

--Create two CTEs to find TSN awards among managers for the NL and for the AL
;WITH nl AS (SELECT playerid, awardid, yearid, lgid
FROM awardsmanagers
WHERE awardid ILIKE '%TSN%'
AND lgid = 'NL'
ORDER BY playerid),

al AS (SELECT playerid, awardid, yearid, lgid
FROM awardsmanagers
WHERE awardid ILIKE '%TSN%'
AND lgid = 'AL'
ORDER BY playerid)

--Intersect to get the ID's of managers in both tables.
SELECT playerid
FROM nl
INTERSECT
SELECT playerid
FROM al;

/*Turn above into a subquery that filters awardsmanagers table to managers who have won awards in both the NL and AL.
Filter to their TSN awards only. Get all the years they've won it.*/

SELECT playerid, awardid, yearid, lgid
FROM awardsmanagers
WHERE awardid ILIKE '%TSN%'
AND playerid IN(
	SELECT playerid
	FROM nl
	INTERSECT
	SELECT playerid
	FROM al);

/*Finally, nest into another query on a JOIN. Grab full names from people table, join on playerid. 
Team name is in teams, but teamid is needed to join teams table, so join managers table on both year
and playerid to avoid duplicates. Finally join teams table to managers table on both year and teamid,
also to avoid duplicates*/

;WITH nl AS (SELECT playerid, awardid, yearid, lgid
FROM awardsmanagers
WHERE awardid ILIKE '%TSN%'
AND lgid = 'NL'
ORDER BY playerid),

al AS (SELECT playerid, awardid, yearid, lgid
FROM awardsmanagers
WHERE awardid ILIKE '%TSN%'
AND lgid = 'AL'
ORDER BY playerid)

SELECT sub.playerid, sub.yearid, sub.lgid, p.namefirst, p.namelast, m.teamid, t.name
FROM (
	SELECT playerid, awardid, yearid, lgid
	FROM awardsmanagers
	WHERE awardid ILIKE '%TSN%'
	AND playerid IN(
		SELECT playerid
		FROM nl
		INTERSECT
		SELECT playerid
		FROM al)) AS sub
JOIN people AS p
ON sub.playerid = p.playerid
JOIN managers AS m
ON sub.yearid = m.yearid AND sub.playerid = m.playerid
JOIN teams AS t
ON m.yearid = t.yearid AND m.teamid = t.teamid;
--Jim Leyland/Davey Johnson

