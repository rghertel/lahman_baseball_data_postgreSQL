--LAHMAN BASEBALL DB
--Q1:
/*SELECT MIN(yearid), MAX(yearid)
FROM batting;*/
-- A1: 1871-2016 seasons; 2017 as last game

/*SELECT namelast, finalgame
FROM people
WHERE finalgame IS NOT NULL
GROUP BY namelast, finalgame
ORDER BY finalgame DESC;
*/
--Q2:
/*
SELECT namefirst, namelast, namegiven, height, a.g_all, a.teamid, t.name
FROM people AS p
JOIN appearances AS a
ON p.playerid = a.playerid
JOIN teams AS t
ON a.teamid = t.teamid
GROUP BY namefirst, namelast, namegiven, height, a.g_all, a.teamid, t.name
ORDER BY height;
*/
-- A2: Edward "Eddie" Carl Gaedel 43 inches, he played one game, St. Louis Browns

--Q3
/*
SELECT p.playerid, namefirst, namelast, s.schoolname, s1.salary, SUM(s1.salary) OVER(PARTITION BY p.playerid) AS total_salary
FROM people AS p
JOIN collegeplaying AS c
ON p.playerid = c.playerid
JOIN schools AS s
ON s.schoolid = c.schoolid
JOIN salaries AS s1
ON s1.playerid = p.playerid
WHERE s.schoolname LIKE '%Vander%'
GROUP BY p.playerid, namefirst, namelast, s.schoolname, s1.salary
ORDER BY total_salary DESC, salary DESC;*/
--A3. David Price's largest salary was $30,000,000; total_income was $81,851,296

--Q4
/*
WITH p AS(
SELECT playerid,
CASE 
	WHEN pos = 'OF' THEN 'Outfield'
	WHEN pos IN('P','C') THEN 'Battery'
	WHEN pos IN('SS','1B','2B','3B') THEN 'Infield'
	ELSE 'Other' END AS position
FROM fielding
WHERE yearid = 2016
GROUP BY playerid, position, fielding.pos)
SELECT p.position, SUM(f.po)
FROM fielding AS f
JOIN p
ON f.playerid = p.playerid
WHERE yearid = 2016
GROUP BY p.position;
*/
--A3 Outfield: 45,231; Infield: 116,636; Battery: 45,202

--Q5
/*
SELECT 	
		decade, 
		strikeouts_per_game,
		hr_per_game
FROM
(SELECT
CASE
	WHEN yearid BETWEEN 1920 AND 1929 THEN '1920s'
	WHEN yearid BETWEEN 1930 AND 1939 THEN '1930s'
	WHEN yearid BETWEEN 1940 AND 1949 THEN '1940s'
	WHEN yearid BETWEEN 1950 AND 1959 THEN '1950s'
	WHEN yearid BETWEEN 1960 AND 1969 THEN '1960s'
	WHEN yearid BETWEEN 1970 AND 1979 THEN '1970s'
	WHEN yearid BETWEEN 1980 AND 1989 THEN '1980s'
	WHEN yearid BETWEEN 1990 AND 1999 THEN '1990s'
	WHEN yearid BETWEEN 2000 AND 2009 THEN '2000s'
	WHEN yearid BETWEEN 2010 AND 2019 THEN '2010s'
	END AS decade, SUM(g) AS total_games, 
		SUM(soa) AS total_strikeouts, 
		ROUND(SUM(soa * 1.0)/SUM(g * 1.0),2) AS strikeouts_per_game, 
		SUM(hr) AS homeruns, 
		ROUND(SUM(hr * 1.0)/SUM(g * 1.0),2) AS hr_per_game
FROM teams
GROUP BY decade) AS sub
WHERE decade IS NOT NULL
GROUP BY decade, total_games, total_strikeouts, strikeouts_per_game, homeruns, hr_per_game
ORDER BY decade;
*/
--A5
--Q6
/*
SELECT 	p.namefirst, 
		p.namelast,
		teamid, 
		sb, 
		cs,
		(sb + cs) AS steal_attempts,
		ROUND(1.00 * sb / (sb + cs),2) AS stolen_bases_perc					
FROM batting AS b
JOIN people AS p
ON b.playerid = p.playerid
WHERE yearid = 2016 AND sb > 20
ORDER BY stolen_bases_perc DESC;
*/
--A6 Chris Owings with 91% stolen_bases_perc

--Q7
/*
SELECT yearid, franchid, g, w, l, wswin
FROM teams
WHERE yearid BETWEEN 1970 and 2016 AND yearid <> 1994
ORDER BY yearid, w DESC;
*/
-- A7(A) 116 wins by Seattle in 2001 (did not win World Series)
-- A7(B) 63 wins by LA Dodgers in 1981 (Won the World Series) - 60 less games that season
		-- STRIKE from June 12 - July 31 1981
		-- STRIKE in August of 1994. NO post season.
--A7(C) 45/46 RECORDS 11/11 OR .24444/.23913. Less than a quarter of the time
--1970, Y
--1971, N
--1972, N
--1973, N
--1974, N
--1975, Y
--1976, Y
--1977, N
--1978, Y
--1979, N
--1980, N
--1982, N
--1983, N
--1984, Y
--1985, N
--1986, Y
--1987, N
--1988, N
--1989, Y
--1990, N
--1991, N
--1992, N
--1993, N
--1995, N
--1996, N
--1997, N
--1998, Y
--1999, N
--2000, N
--2001, N
--2002, N
--2003, N
--2004, N
--2005, N
--2006, N
--2007, Y
--2008, N
--2009, Y
--2010, N
--2011, N
--2012, N
--2013, N
--2014, N
--2015, N
--2016, Y

--Q8
/*
SELECT h.year, tf.franchname, p.park_name, games, h.attendance, ROUND((h.attendance*1.0)/(games*1.0),2) AS avg_attendance_game
FROM homegames AS h
JOIN parks AS p
ON h.park = p.park
LEFT JOIN teams AS t
ON h.team = t.teamid
LEFT JOIN teamsfranchises AS tf
ON t.franchid = tf.franchid
WHERE year = 2016 AND games > 10
GROUP BY h.team, tf.franchname, p.park_name, games, h.attendance, avg_attendance_game, h.year
ORDER BY avg_attendance_game
LIMIT 5;
*/
--A8 Dodger Stadium, LA Dodgers AVG of 45,719.9 per game.
--Lowest attendance Tampa Bay Rays; Tropicana Field 15,878.56/game
--Oakland As; Oakland-Alameda County Coliseum 18,784.02/game
--Cleveland Indians; Progressive Field 19,650.21/game
--Florida Marlins; Marlins Park 21,405.21/game
--Chicago White Sox; U.S. Cellular Field 21,559.17

--Q9
SELECT sub.namefirst, sub.namefirst, sub.namelast, sub.n_awards, am.lgid
FROM
(SELECT am.playerid, p.namefirst, p.namelast, am.lgid, COUNT(awardid), COUNT(awardid) OVER(PARTITION BY am.playerid ORDER BY am.playerid) AS n_awards
FROM awardsmanagers AS am
JOIN people AS p
ON am.playerid = p.playerid
GROUP BY am.playerid, p.namefirst, p.namelast, am.lgid, awardid
ORDER BY playerid) AS sub
JOIN awardsmanagers AS am
ON am.playerid = sub.playerid
GROUP BY sub.n_awards, sub.namefirst, sub.namefirst, sub.namelast, am.lgid
ORDER BY sub.n_awards DESC;
--A9

