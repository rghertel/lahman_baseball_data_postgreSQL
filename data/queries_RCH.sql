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
