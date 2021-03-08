--1) What range of years for baseball games played does the provided database cover?
-- Ans: 1871 - 2017
SELECT namegiven, MIN(debut), MAX(finalgame) AS year
FROM people
group by namegiven
order by year DESC

--2) Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
-- Ans: Edward Carl, 1 game played, St. Louis Browns
SELECT DISTINCT p.namegiven, p.height, a.g_all, t.name
FROM people AS p
LEFT JOIN appearances AS a
ON p.playerid = a.playerid
LEFT JOIN teams AS t
ON a.teamid = t.teamid
ORDER BY height

/*3) Find all players in the database who played at Vanderbilt University. 
     Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. 
	 Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
	 PLAYED @ VANDERBILT UNIVERSITY, FIRST/LAST NAME, total earned SALARY IN MAJOR LEAGUE*/
	 
-- subquery
/*SELECT schoolname
FROM schools 
WHERE schoolname = 'Vanderbilt University'*/

SELECT p.namelast AS last_name, p.namefirst AS first_name,  s.salary,
		(SELECT schoolname
		FROM schools 
		WHERE schoolname = 'Vanderbilt University') sub
FROM people AS p
JOIN salaries as s
ON p.playerid = s.playerid
ORDER BY s.salary DESC

	
/* 4)Using the fielding table, group players into three groups based on their position: 
     label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". 
	 Determine the number of putouts made by each of these three groups in 2016.*/
	 
SELECT COUNT(po) AS num_putout,
	CASE pos WHEN 'OF' THEN 'Outfield'
		     WHEN 'SS' THEN 'Infield'
			 WHEN '1B' THEN 'Infield'
			 WHEN '2B' THEN 'Infield'
			 WHEN '3B' THEN 'Infield'
			 WHEN 'P' THEN 'Battery'
			 WHEN 'C' THEN 'Battery'
			 END field_position
FROM fielding
WHERE yearid = 2016
GROUP BY field_position


/* 5)Find the average number of strikeouts per game by decade since 1920. 
     Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?*/
-- Trend: 1950's saw on average an increase in both homeruns and strikeouts 

SELECT 
	   CASE WHEN yearid BETWEEN 1920 AND 1929 THEN '1920'
	    WHEN yearid BETWEEN 1930 AND 1939 THEN '1930'
	    WHEN yearid BETWEEN 1940 AND 1949 THEN '1940'
	    WHEN yearid BETWEEN 1950 AND 1959 THEN '1950'
	    WHEN yearid BETWEEN 1960 AND 1969 THEN '1960'
	    WHEN yearid BETWEEN 1970 AND 1979 THEN '1970'
	    WHEN yearid BETWEEN 1980 AND 1989 THEN '1980'
	    WHEN yearid BETWEEN 1990 AND 1999 THEN '1990'
	    WHEN yearid BETWEEN 2000 AND 2009 THEN '2000'
	   ELSE '2010' END decade,
	   ROUND(AVG(hr),2) AS avg_homeruns, ROUND(AVG(so),2) as avg_strikes
from battingpost
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade

