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
ORDER BY total_salary DESC, salary DESC;
*/
--A3. David Price's largest salary was $30,000,000; total_income was $81,851,296

--Q4
--verify total putouts from fielding table
/*
SELECT SUM(po)
FROM fielding
WHERE yearid = 2016;
*/
--full query
/*
SELECT	position_label, 
		SUM(po) AS putouts,
		total_putouts_2016
FROM(
	SELECT 	playerid, 
		po, 
		pos,
		CASE WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos IN('P','C') THEN 'Battery'
		WHEN pos IN('SS','1B','2B','3B') THEN 'Infield'
		END AS position_label,
		SUM(po) OVER() AS total_putouts_2016
	FROM fielding
	WHERE yearid = 2016) AS sub
GROUP BY position_label, total_putouts_2016;
*/
--A3 Outfield: 29,560; Infield: 58,934; Battery: 41,424
--129,918 total putouts in 2016

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
--A5 Home runs and strikeouts ave both increased exponentially since the 1920s

--Q6
/*
SELECT 	p.namefirst, 
		p.namelast,
		teamid, 
		sb, 
		cs,
		(sb + cs) AS steal_attempts,
		ROUND(1.00 * sb / (sb + cs),3) AS stolen_bases_perc					
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
--Q7C
/*
---RYAN'S
SELECT yearid, teamid, w
FROM teams
WHERE yearid BETWEEN 1970 AND 2016 AND WSWin = 'Y' 
INTERSECT
SELECT yearid, teamid, MAX(w) OVER(PARTITION BY yearid)
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
ORDER BY yearid;
*/
/*
--MY Function doesn't work with two max winners in 2013
SELECT COUNT(winvalue) AS total_top_wins_year, SUM(winvalue) AS also_ws_win, ROUND(SUM((winvalue)*1.0)/COUNT((winvalue)*1.0),3) AS perc_highwins_ws
FROM (
SELECT yearid, teamid, win_rank, w, wswin, CASE WHEN wswin = 'Y' THEN 1 ELSE 0 END AS winvalue
FROM( --subquery for rank, grouped by year and ordered by highest ranked wins
SELECT yearid, teamid, ROW_NUMBER() OVER(PARTITION BY yearid ORDER BY w DESC) AS win_rank, w, wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
GROUP BY yearid, teamid, w, wswin
ORDER BY wswin DESC, yearid, w DESC) AS sub
WHERE win_rank = 1 AND wswin IS NOT NULL --NOT null will exclude 1994
) AS sub2;
*/
-- A7(A) 116 wins by Seattle in 2001 (did not win World Series)
-- A7(B) 63 wins by LA Dodgers in 1981 (Won the World Series) - 60 less games that season
		-- STRIKE from June 12 - July 31 1981
		-- STRIKE in August of 1994. NO post season.
--A7(C) 46 RECORDS 12 OR .2608

--Q8
--highest
/*
SELECT h.year, tf.franchname, p.park_name, games, h.attendance, ROUND((h.attendance*1.0)/(games*1.0),2) AS avg_attendance_game
FROM homegames AS h
JOIN parks AS p
ON h.park = p.park
LEFT JOIN teams AS t
ON h.team = t.teamid
LEFT JOIN teamsfranchises AS tf
ON t.franchid = tf.franchid
WHERE year = 2016 AND games >= 10
GROUP BY h.team, tf.franchname, p.park_name, games, h.attendance, avg_attendance_game, h.year
ORDER BY avg_attendance_game DESC
LIMIT 1;
*/
--lowest
/*
SELECT h.year, tf.franchname, p.park_name, games, h.attendance, ROUND((h.attendance*1.0)/(games*1.0),2) AS avg_attendance_game
FROM homegames AS h
JOIN parks AS p
ON h.park = p.park
LEFT JOIN teams AS t
ON h.team = t.teamid
LEFT JOIN teamsfranchises AS tf
ON t.franchid = tf.franchid
WHERE year = 2016 AND games >= 10
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
--RYAN'S FUNCTION
/*
SELECT a.playerid, a.yearid, a.lgid, p.namefirst, p.namelast, m.teamid
FROM awardsmanagers AS a
LEFT JOIN people AS p
ON a.playerid = p.playerid
LEFT JOIN managers as m
ON a.playerid = m.playerid AND a.yearid = m.yearid
WHERE awardid = 'TSN Manager of the Year' AND a.playerid IN (
SELECT playerid
FROM awardsmanagers
WHERE awardid = 'TSN Manager of the Year' AND lgid = 'NL'
INTERSECT
SELECT playerid
FROM awardsmanagers
WHERE awardid = 'TSN Manager of the Year' AND lgid = 'AL')
ORDER BY playerid;
*/
/*
--Richie's Formula no good
SELECT sub.namefirst, sub.namelast, sub.awardid, t.franchid, sub.lgid, sub.total_n_awards
FROM (SELECT am.playerid, am.awardid, am.lgid, p.namefirst, p.namelast, COUNT(awardid) AS count_awards, 
 	SUM(COUNT(awardid)) OVER(PARTITION BY am.playerid ORDER BY am.playerid) AS total_n_awards
FROM awardsmanagers AS am
JOIN people AS p
ON am.playerid = p.playerid
WHERE awardid = 'TSN Manager of the Year'
GROUP BY am.playerid, am.lgid, am.awardid, p.namefirst, p.namelast
ORDER BY playerid) AS sub
LEFT JOIN people AS p
ON sub.playerid = p.playerid
LEFT JOIN appearances AS a
ON sub.playerid = a.playerid
LEFT JOIN teams AS t
ON t.teamid = a.teamid
WHERE sub.lgid = 'AL' OR sub.lgid = 'NL'
GROUP BY sub.namefirst, sub.namefirst, sub.namelast, sub.total_n_awards, sub.count_awards, t.franchid, sub.lgid, sub.awardid
HAVING total_n_awards > 1
ORDER BY sub.total_n_awards DESC;
*/
--A9 Davey Johnson and Jim Leyland


--Open-Ended Questions
--Q10
/*
SELECT 
	schoolname, 
	schoolstate, 
	COUNT(DISTINCT p.playerid) AS n_players, 
	SUM(COALESCE(salary,0)) AS total_salaries
FROM schools AS s
LEFT JOIN collegeplaying AS cp
ON s.schoolid = cp.schoolid
LEFT JOIN people AS p
ON cp.playerid = p.playerid
LEFT JOIN salaries AS sl
ON p.playerid = sl.playerid
WHERE schoolstate = 'TN'
GROUP BY schoolname, schoolstate
ORDER BY 4 DESC;
*/
--University of TN has had 41 players witn a total salary of $985,207,966.


--Q11


--A11


--Q12
/*
SELECT 
	park, 
	franchid
	yearid, 
	w, 
	l,
	ROUND(((w*1.0)/(g*1.9)),2) AS win_perc,
	wswin,
	attendance,
	RANK() OVER(ORDER BY attendance DESC)AS attendance_rank
FROM teams
WHERE yearid = 2013
ORDER BY win_perc DESC
*/
/*
SELECT 
	park, 
	franchid,
	yearid, 
	w, 
	l,
	ROUND(((w*1.0)/(g*1.9)),2) AS win_perc,
	wswin,
	attendance,
	RANK() OVER(PARTITION BY yearid ORDER BY attendance DESC)AS attendance_rank
FROM teams
WHERE yearid IN (2012, 2013, 2014, 2014)
GROUP BY yearid, 1, 2, 4, 5, 6, 7, 8
ORDER BY yearid;
*/
--A12(A) 2016 proved nothing. Dodger stadium has the largest capacity and is usually ranked #1 for attendance
--A13(B)