-- Question 1
SELECT MIN(debut), MAX(finalgame)
FROM people
-- ANS: 1871-2017

-- Question 2
SELECT people.playerid, namefirst, namelast, height, G_all, teams.name
FROM people
INNER JOIN appearances
ON people.playerid = appearances.playerid
INNER JOIN teams
ON appearances.teamid = teams.teamid
ORDER BY height
-- ANS:  Eddie Gaedel, 43 inches, 1 game played, St. Louis Browns

-- Question 3
SELECT schoolid
FROM schools
WHERE schoolname = 'Vanderbilt University' /* subquery? */

SELECT playerid
FROM collegeplaying
WHERE schoolid IN (
	SELECT schoolid
	FROM schools
	WHERE schoolname = 'Vanderbilt University') /* subquery 2 */

SELECT people.playerid, namefirst, namelast, salary, SUM(salary) OVER(PARTITION BY people.playerid) AS total_salary
FROM people
INNER JOIN salaries
ON people.playerid = salaries.playerid
WHERE people.playerid IN(
	SELECT playerid
	FROM collegeplaying
	WHERE schoolid IN (
		SELECT schoolid
		FROM schools
		WHERE schoolname = 'Vanderbilt University'))
GROUP BY namefirst, namelast, salary, people.playerid
ORDER BY salary DESC;
-- ANS: David Price

-- Question 4:
SELECT playerid, po,
CASE WHEN pos = 'OF' THEN 'Outfield'
WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
WHEN pos IN ('P', 'C') THEN 'Battery' END AS position_label
FROM fielding
WHERE yearID = 2016

SELECT position_label, SUM(po) AS total_putouts
FROM(
	SELECT playerid, po, pos,
	CASE WHEN pos = 'OF' THEN 'Outfield'
	WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
	WHEN pos IN ('P', 'C') THEN 'Battery' END AS position_label
	FROM fielding
	WHERE yearID = 2016) AS sub
GROUP BY position_label

-- Question 5:
SELECT *,
CASE WHEN yearid BETWEEN 1920 AND 1929 THEN '1920s'
WHEN yearid BETWEEN 1930 AND 1939 THEN '1930s'
WHEN yearid BETWEEN 1940 AND 1949 THEN '1940s'
WHEN yearid BETWEEN 1950 AND 1959 THEN '1950s'
WHEN yearid BETWEEN 1960 AND 1969 THEN '1960s'
WHEN yearid BETWEEN 1970 AND 1979 THEN '1970s'
WHEN yearid BETWEEN 1980 AND 1989 THEN '1980s'
WHEN yearid BETWEEN 1990 AND 1999 THEN '1990s'
WHEN yearid BETWEEN 2000 AND 2009 THEN '2000s'
WHEN yearid BETWEEN 2010 AND 2019 THEN '2010s' END AS decade
FROM teams /* subquery */

SELECT decade, ROUND(1.0*SUM(so) / SUM(g), 2) AS so_per_game, ROUND(1.0*SUM(HR) / SUM(g), 2) AS hr_per_game
FROM(SELECT *,
	CASE WHEN yearid BETWEEN 1920 AND 1929 THEN '1920s'
	WHEN yearid BETWEEN 1930 AND 1939 THEN '1930s'
	WHEN yearid BETWEEN 1940 AND 1949 THEN '1940s'
	WHEN yearid BETWEEN 1950 AND 1959 THEN '1950s'
	WHEN yearid BETWEEN 1960 AND 1969 THEN '1960s'
	WHEN yearid BETWEEN 1970 AND 1979 THEN '1970s'
	WHEN yearid BETWEEN 1980 AND 1989 THEN '1980s'
	WHEN yearid BETWEEN 1990 AND 1999 THEN '1990s'
	WHEN yearid BETWEEN 2000 AND 2009 THEN '2000s'
	WHEN yearid BETWEEN 2010 AND 2019 THEN '2010s' END AS decade
	FROM teams) AS sub
WHERE decade IS NOT null
GROUP BY decade
ORDER BY so_per_game
-- ANS: Both strikeouts and home runs seem to be increasing across the decades

-- using batting table?

SELECT decade, ROUND(1.0*SUM(so) / SUM(g), 2) AS so_per_game, ROUND(1.0*SUM(HR) / SUM(g), 2) AS hr_per_game
FROM(SELECT *,
	CASE WHEN yearid BETWEEN 1920 AND 1929 THEN '1920s'
	WHEN yearid BETWEEN 1930 AND 1939 THEN '1930s'
	WHEN yearid BETWEEN 1940 AND 1949 THEN '1940s'
	WHEN yearid BETWEEN 1950 AND 1959 THEN '1950s'
	WHEN yearid BETWEEN 1960 AND 1969 THEN '1960s'
	WHEN yearid BETWEEN 1970 AND 1979 THEN '1970s'
	WHEN yearid BETWEEN 1980 AND 1989 THEN '1980s'
	WHEN yearid BETWEEN 1990 AND 1999 THEN '1990s'
	WHEN yearid BETWEEN 2000 AND 2009 THEN '2000s'
	WHEN yearid BETWEEN 2010 AND 2019 THEN '2010s' END AS decade
	FROM batting) AS sub
WHERE decade IS NOT null
GROUP BY decade
ORDER BY so_per_game

--Question 6:
SELECT b.playerid, p.namefirst, p.namelast, 100.0 * b.sb / (b.sb + b.cs) AS stealing_perc
FROM batting AS b
INNER JOIN people as p
ON b.playerid = p.playerid
WHERE yearid = 2016 AND b.sb + b.cs > 20
GROUP BY b.playerid, p.namefirst, p.namelast, stealing_perc
ORDER BY stealing_perc DESC
-- ANS: Chris Owings

--Question 7:
-- Lowest number of wins by WS winner
SELECT yearid, teamid, w
FROM teams
WHERE yearid BETWEEN 1970 AND 2016 AND WSWin = 'Y' 
ORDER BY w 
-- 63 wins in 1981 but this year had less games because of a player's strike
-- ignoring 1981:
SELECT yearid, teamid, w
FROM teams
WHERE yearid BETWEEN 1970 AND 2016 AND WSWin = 'Y' AND yearid <> 1981
ORDER BY w 
--ANS: 86 wins in 2006
-- Highest number of wins by non WS winner
SELECT yearid, teamid, w
FROM teams
WHERE yearid BETWEEN 1970 AND 2016 AND WSWin = 'N' 
ORDER BY w DESC
-- ANS: 116 wins in 2001

-- Question 8: 
SELECT DISTINCT p.park_name,  h.attendance / h.games AS avg_attendance
FROM homegames AS h
INNER JOIN teams AS t
ON t.teamid = h.team
INNER JOIN parks AS p
ON p.park = h.park
WHERE year = 2016 AND games >=10
ORDER BY avg_attendance DESC
LIMIT 5

SELECT *
FROM homegames
