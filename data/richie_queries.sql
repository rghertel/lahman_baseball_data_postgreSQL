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
---Q3. David Price's largest salary was $30,000,000; total_income was $81,851,296



