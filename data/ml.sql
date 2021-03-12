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
-- Ans: David Price 81,851,296	 
SELECT p.playerid, p.namefirst, p.namelast, v.schoolname, salary.total_earnings
FROM people AS p
INNER JOIN (
		select DISTINCT playerid, schoolname
		from collegeplaying AS cp
		inner join schools AS s
		ON cp.schoolid = s.schoolid
		where schoolname = 'Vanderbilt University') as v
ON p.playerid = v.playerid
INNER JOIN (
		  Select playerid, SUM(salary) as total_earnings
		  fROM salaries
		  GROUP BY playerid) as salary ON p.playerid = salary.playerid
ORDER BY total_earnings DESC
		
	
/* 4)Using the fielding table, group players into three groups based on their position: 
     label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". 
	 Determine the number of putouts made by each of these three groups in 2016.*/
-- ANS: Battery 41424, Infield 58934, Outfield 29560	 
SELECT SUM(po) AS num_putout,
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


--Rachel's Query
WITH pf AS (
SELECT playerid, pos, po, yearid,
CASE 
	WHEN pos = 'OF' THEN 'Outfield'
	WHEN pos IN ('SS','1B','2B','3B') THEN 'Infield'
	ELSE 'Battery' 
	END AS position
FROM fielding)

SELECT pf.position, SUM(pf.po)
FROM pf
JOIN fielding AS f
ON f.playerid = pf.playerid
WHERE f.yearid = 2016
GROUP BY pf.position;


/* 5)Find the average number of strikeouts per game by decade since 1920. 
     Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?*/
-- Trend: 1950's saw on average an increase in both homeruns and strikeouts 
-- FIX
SELECT FLOOR(yearid/10)*10 AS decade, ROUND(AVG(hr),2) AS avg_homeruns, ROUND(AVG(so),2) as avg_strikes
FROM batting
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade


/* 6)Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. 
    (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.*/
-- ANS: Chris Owings
SELECT b.playerid, p.namefirst, p.namelast, ROUND(100.0*b.sb/(b.sb+b.cs),2) AS stealing_perc
FROM batting AS b
INNER JOIN people AS p
ON b.playerid = p.playerid
WHERE yearid = 2016 AND b.sb + b.cs > 20
GROUP BY b.playerid, p.namefirst, p.namelast, stealing_perc
ORDER BY stealing_perc DESC


/* 7)From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? 
     What is the smallest number of wins for a team that did win the world series? 
	 Doing this will probably result in an unusually small number of wins for a world series champion 
	 – determine why this is the case. Then redo your query, excluding the problem year. 
	 How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? 
	 What percentage of the time?*/

--Part 1) Seattle Mariners 
SELECT yearid, name, SUM(w) AS wins, SUM(l) AS losses, wswin AS world_series_wins
FROM teams
WHERE wswin = 'N' AND yearid BETWEEN 1970 AND 2016
GROUP BY yearid, name, wswin
ORDER BY wins DESC

--Part 2) Los Angeles Dodgers
SELECT yearid, name, SUM(w) AS wins, SUM(l) AS losses, wswin AS world_series_wins
FROM teams
WHERE wswin = 'Y' AND yearid <> '1994'
GROUP BY yearid, name, wswin
ORDER BY wins 

--Part 3) 12 Teams
with ws_list (yearid, name, wins)
as (select yearid, name, sum(w) as wins
   	from teams
   where wswin = 'Y'
   and yearid <> '1994'
   group by yearid, name) ,/* this is table with team that won WS by year & win ct */
   win_list (yearid, name, wins)
 as (select yearid, name, sum(w) as wins
	from teams
	where yearid <> '1994'
	group by yearid, name) /* this is table with wins per team per year */
	
select a.yearid,b.name, b.wins
from (select yearid, max(wins) as mx_wins
	from win_list
	group by yearid) a /* Get the max number of wins per year */
inner join ws_list b
on a.yearid = b.yearid
and b.wins = a.mx_wins
where a.yearid between 1970 and 2016

--Ryan's Query for part 3
SELECT yearid, teamid, w
FROM teams
WHERE yearid BETWEEN 1970 AND 2016 AND WSWin = 'Y' 
INTERSECT
SELECT yearid, teamid, MAX(w) OVER(PARTITION BY yearid)
FROM teams
WHERE yearid BETWEEN 1970 AND 2016



/* 8)Using the attendance figures from the homegames table, 
     find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). 
	 Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.*/

--top 5 Dodgers, Cardinals, Blue Jays, Giants, Cubs
SELECT DISTINCT t.name, t.park, SUM(h.attendance)/SUM(h.games) as avg_att
FROM teams AS t
INNER JOIN homegames AS h
ON t.teamid = h.team AND t.yearid = h.year
WHERE year = 2016 AND games >= 10
GROUP BY t.name, t.park
ORDER BY avg_att DESC
LIMIT 5


--bottom 5 Rays, Athletics, Indians, Marlins, White Sox
SELECT DISTINCT t.name, t.park, SUM(h.attendance)/SUM(h.games) as avg_att
FROM teams AS t
INNER JOIN homegames AS h
ON t.teamid = h.team AND t.yearid = h.year
WHERE year = 2016 AND games >= 10
GROUP BY t.name, t.park
ORDER BY avg_att 
LIMIT 5


/* 9)Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? 
     Give their full name and the teams that they were managing when they won the award.*/
	 
SELECT p.namegiven, t.teamid, a.lgid, a.awardid
FROM awardsmanagers AS a
INNER JOIN people AS p
ON a.playerid = p.playerid
INNER JOIN teams
ON a.playerid = t.playerid
WHERE awardid = 'TSN Manager of the Year' AND lgid IN ('AL','NL')
GROUP BY p.namegiven, a.lgid, a.awardid

