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
SELECT yearid, franchid, g, w, l, wswin
FROM teams
WHERE yearid BETWEEN 1970 and 2016 AND yearid <> 1994 AND yearid <> 1981
ORDER BY w DESC;
-- A7(A) 116 wins by Seattle in 2001 (did not win World Series)
-- A7(B) 63 wins by LA Dodgers in 1981 (Won the World Series) - 60 less games that season
		-- STRIKE from June 12 - July 31 1981
		-- Stirike in August of 1994. NO post season.
--A7(C)


