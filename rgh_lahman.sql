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
		
SELECT DISTINCT G_all, a.teamid, t.name
FROM appearances AS a
LEFT JOIN teams AS t
ON a.teamid = t.teamid
WHERE playerid IN
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
--David Taylor earned the most money 

/* 4. Using the fielding table, group players into three groups based on their position: label players with 
position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". 
Determine the number of putouts made by each of these three groups in 2016.*/

SELECT *
FROM fielding;

/*Group players into three categories of positions. Turn that table into a CTE. Join it to fielding table on playerid, sum the putouts
per position, and group by position*/

WITH pf AS (
SELECT playerid, pos, po, yearid,
CASE 
	WHEN pos = 'OF' THEN 'Outfield'
	WHEN pos IN ('SS','1B','2B','3B') THEN 'Infield'
	ELSE 'Battery' 
	END AS position
FROM fielding)

SELECT pf.position, SUM(f.po)
FROM fielding AS f
JOIN pf
ON f.playerid = pf.playerid
WHERE f.yearid = 2016
GROUP BY pf.position;
--Battery: 317,472 / Infield: 689,431 / Outfield: 285,322

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

SELECT b.playerid, p.namefirst, p.namelast, sb, cs, sb/cs AS 
FROM batting AS b
JOIN people AS p
ON b.playerid = p.playerid