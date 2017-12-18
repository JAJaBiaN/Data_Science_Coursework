/* Run as sqlite3 mydatabase.db < mydatabase.sql */

/* Create units table */
DROP TABLE units;
CREATE TABLE units (
	unitid INTEGER PRIMARY KEY,
	name TEXT,
	level INTEGER,
	semester INTEGER
	);
INSERT INTO units VALUES(100,'CM60100', 6, 1), (101,'CM60101', 6, 1),
	(102,'XX60200', 6, 1);
SELECT * FROM units;

.print

/* Create student table */
DROP TABLE students;
CREATE TABLE students(
	studentid INTEGER PRIMARY KEY,
	name TEXT
	);
INSERT INTO students VALUES (1001,'Rod'), (1002,'Jane'),
(1003,'Freddy');
SELECT * FROM students;

.print

/* Create enrolled table */
DROP TABLE enrolled;
CREATE TABLE enrolled(
	studentid INTEGER,
	unitid INTEGER,
	year INTEGER,
	FOREIGN KEY (studentid) REFERENCES students(studentid),
	FOREIGN KEY (unitid) REFERENCES units(unitid)
	);
INSERT INTO enrolled VALUES (1001,100,2016), (1001,101,2016),
	(1001,102,2016), (1002,100,2016), (1002,101,2016), (1002,102,2016),
	(1003,102, 2016); /*, (1003,100, 2015);*/
SELECT * FROM enrolled;	

.print

/* Find the units Rod is enrolled in */
SELECT units.name FROM (students JOIN enrolled ON students.studentid=enrolled.studentid) JOIN units
	ON enrolled.unitid = units.unitid WHERE students.name='Rod';

.print
	
/* Find the students enrolled in CM60100 */
SELECT students.name FROM (students JOIN enrolled ON students.studentid=enrolled.studentid) JOIN units
	ON enrolled.unitid = units.unitid WHERE units.name='CM60100';
.print
/* Count the number of students taking CM60100 by year */
SELECT enrolled.year, COUNT(*) FROM (students JOIN enrolled ON students.studentid=enrolled.studentid) JOIN units 
	ON enrolled.unitid = units.unitid WHERE units.name='CM60100' GROUP BY enrolled.year;
.print

/***********************/
/* Include Assessments */
/***********************/

/* Create assessments table */
DROP TABLE assessments;
CREATE TABLE assessments(
	assessmentid INTEGER PRIMARY KEY,
	unitid INTEGER,
	name TEXT,
	type TEXT,
	max_mark INTEGER,
	weighting INTEGER,
	initial_deadline TEXT,
	FOREIGN KEY (unitid) REFERENCES units(unitid)
	);

/* Create submissions table */
DROP TABLE submissions;
CREATE TABLE submissions(
	studentid INTEGER,
	unitid INTEGER,
	assessment_name TEXT,
	submitted TEXT,
	deadline TEXT,
	mark INTEGER,
	FOREIGN KEY (studentid) REFERENCES students(studentid),
	FOREIGN KEY (unitid) REFERENCES units(unitid)
	); /* mark is null until the assessment is marked by the tutor */

/* Add assessments */
INSERT INTO assessments (unitid, name, type, max_mark, weighting) VALUES (102, 'EX1', 'exam', 60, 100),
	(100, 'CW1', 'coursework', 100, 50), (100, 'CW2', 'coursework', 100, 50),
	(101, 'CW1', 'coursework', 25, 25), (101, 'EX1', 'exam', 60, 75);

SELECT * FROM assessments;

/* Add deadlines to the assessments */
UPDATE assessments SET initial_deadline='15 January 2018' WHERE unitid=102 AND name='EX1';
UPDATE assessments SET initial_deadline='24 November 2017' WHERE unitid=100 AND name='CW1';
UPDATE assessments SET initial_deadline='15 December 2017' WHERE unitid=100 AND name='CW2';
UPDATE assessments SET initial_deadline='31 November 2017' WHERE unitid=101 AND name='CW1';
UPDATE assessments SET initial_deadline='18 January 2018' WHERE unitid=101 AND name='EX1';

SELECT * FROM assessments;

/* Initialise submissions for students */
INSERT INTO submissions (studentid, unitid, assessment_name, deadline) SELECT 
	enrolled.studentid,
	enrolled.unitid,
	assessments.name,
	assessments.initial_deadline
FROM
	(assessments JOIN enrolled ON assessments.unitid=enrolled.unitid);

SELECT * FROM submissions;

/* Update student submissions when they have submitted*/
UPDATE submissions SET submitted='15 January 2018', mark=43
	WHERE unitid=102 AND assessment_name='EX1' AND studentid=1001;
UPDATE submissions SET submitted='15 January 2018', mark=38
	WHERE unitid=102 AND assessment_name='EX1' AND studentid=1002;
UPDATE submissions SET submitted='18 January 2018', mark=48 /* Should this be 15/1/2018 like everyone else? */
	WHERE unitid=102 AND assessment_name='EX1' AND studentid=1003;
	
UPDATE submissions SET submitted='24 November 2017', mark=58
	WHERE unitid=100 AND assessment_name='CW1' AND studentid=1001;
UPDATE submissions SET submitted='23 November 2017', mark=48
	WHERE unitid=100 AND assessment_name='CW1' AND studentid=1002;
	
UPDATE submissions SET submitted='15 December 2017', mark=62
	WHERE unitid=100 AND assessment_name='CW2' AND studentid=1001;
UPDATE submissions SET submitted='14 December 2017', mark=70
	WHERE unitid=100 AND assessment_name='CW2' AND studentid=1002;
	
UPDATE submissions SET submitted='31 November 2017', mark=20
	WHERE unitid=101 AND assessment_name='CW1' AND studentid=1001;
UPDATE submissions SET submitted='30 November 2017', mark=18
	WHERE unitid=101 AND assessment_name='CW1' AND studentid=1002;

UPDATE submissions SET submitted='18 January 2018', mark=39
	WHERE unitid=101 AND assessment_name='EX1' AND studentid=1001;
UPDATE submissions SET submitted='18 January 2018', mark=53
	WHERE unitid=101 AND assessment_name='EX1' AND studentid=1002;

SELECT * FROM submissions;

/* Leave a space between the full submissions table and the selected */
.print 

/* Total unit marks for CM60101 */
SELECT studentid, SUM((1.0 * submissions.mark * assessments.weighting) / assessments.max_mark) 
	FROM (submissions JOIN assessments 
		ON assessments.unitid=submissions.unitid 
			AND submissions.assessment_name=assessments.name) 
	WHERE submissions.unitid=101 GROUP BY submissions.studentid;

.print 
	
/* Total unit marks for Rod */
SELECT submissions.unitid, SUM((1.0 * submissions.mark * assessments.weighting) / assessments.max_mark) 
	FROM (submissions JOIN assessments 
		ON assessments.unitid=submissions.unitid 
			AND submissions.assessment_name=assessments.name) 
	WHERE submissions.studentid=1001 GROUP BY submissions.unitid;






