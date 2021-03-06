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
	 
SELECT schoolname
FROM schools 
WHERE schoolname = 'Vanderbilt University'

SELECT p.namelast AS last_name, p.namefirst AS first_name,  s.salary
FROM people AS p
JOIN salaries as s
ON p.playerid = s.playerid
	

	 
