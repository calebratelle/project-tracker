--SETUP (Create a database to build our tables)

createdb project-tracker
psql project-tracker

--Step 1a (created table with github, first_name, and last_name as columns)

CREATE TABLE students(github VARCHAR(30), first_name VARCHAR(30),
last_name VARCHAR(30));

--Step 1b (inserted student info twice)

INSERT INTO students VALUES ('jhacks', 'Jane', 'Hacker');

--Step 1c (deleted duplicate created in Step 1b)

DROP TABLE students;

--Step 1d (modified previous CREATE TABLE command so that the github column is the primary key.)

CREATE TABLE students(github VARCHAR(30) PRIMARY KEY, first_name VARCHAR(30), last_name VARCHAR(30));

--Step 1e (re-ran the same INSERT statements to add Jane and Sarah to the students table.  Trying to add the same student twice shouldn't work.)

INSERT INTO students VALUES ('jhacks', 'Jane', 'Hacker');
INSERT INTO students VALUES ('sdevelops', 'Sarah', 'Developer');

-- Step 2a Show only the last name of all students

SELECT last_name FROM students;

-- Step 2b Show only the GitHub username and first name of all students

SELECT github, first_name FROM students;

-- Step 2c Show all columns for students whose first name is Sarah

SELECT * FROM students WHERE first_name = 'Sarah';

-- Step 2d Show all columns for students whose GitHub username is sdevelops

SELECT * FROM students WHERE github='sdevelops';

-- Step 2e Show only the first name and last name of students whose GitHub username is jhacks

SELECT first_name, last_name FROM students WHERE github='jhacks';

--Step 3 Create a projects table in the database.  The title column should be the primary key. (We won’t have two projects with the same title!)  The description column should use the TEXT data type (intended for strings that could be very long, like a long description, or even the contents of an entire book!).  The max_grade column should use the INTEGER data type.  Lastly, populate the table with 5 rows of info.

CREATE TABLE projects(title VARCHAR(30) PRIMARY KEY, description TEXT, max_grade INTEGER);

INSERT INTO projects VALUES('Markov', 'Tweets generated from Markov chains', 50);

INSERT INTO projects VALUES('Blockly', 'Programmatic Logic Puzzle Game', 100);

INSERT INTO projects VALUES('Dashly', 'Racing Game', 75);

INSERT INTO projects VALUES('Puzzle', 'Puzzle Game', 30);

INSERT INTO projects VALUES('DB', 'Database', 1000);

--STEP 4a in a separate terminal (or just quit PostgreSQL), create the SQL dump file.

pg_dump project-tracker > project-tracker-dump.sql

--STEP 4b open up the file in VS code

code project-tracker-dump.sql

--Step 4c If you want to restore your database, re-create it on a new machine, or save edits you made to the SQL file in your database you’ll need to re-read that SQL into psql. Follow these steps to do that now:

--If the database exists already, you’ll want to drop that database, like this:

dropdb project-tracker

--This command says, “Remove the existing database called project-tracker.” Dropping the database is unnecessary if you are creating it for the first time on a new machine.  Now, create your database anew:

createdb project-tracker


--This line says, “Create an empty database called project-tracker.” This line is required whether your database previously existed on the machine or not.  Once you’ve created a new empty database, read the SQL you dumped into it like this:

$ psql -U postgres -d project-tracker -f  project-tracker-dump.sql

--In English, this command says, “Run PostgreSQL, and redirect the file project-tracker-dump.sql in to that program.”  The < operator is like the redirect-output shell operator |, but it works in the other direction: the contents of project-tracker-dump.sql are fed into psql. And since project-tracker-dump.sql contains valid SQL statements, PostgreSQL will execute them, to recreate the database.  Try this out a few times to make sure you understand how to do it, and ask for help if you run into any errors. You’ll need to understand how to do this in order to check your database into Git.

--Step 5a Select the title and max_grade for all projects with max_grade > 50.

SELECT title, max_grade FROM projects WHERE max_grade > 50;

--Step 5b Select the title and max_grade for all projects where the max_grade is between 10 and 60.

SELECT title, max_grade FROM projects WHERE max_grade BETWEEN 10 AND 60;

--Step 5c Select the title and max_grade for all projects where the max_grade is less than 25 or greater than 75.

SELECT title, max_grade FROM projects WHERE max_grade < 25 OR max_grade > 75;

--Step 5d Select all projects ordered by max_grade descending.

SELECT * FROM projects ORDER BY max_grade DESC;

--Step 6a Create grades Table referencing the projects table and the students table.

CREATE TABLE grades (
  id SERIAL PRIMARY KEY,
  student_github VARCHAR(30) REFERENCES students,
  project_title VARCHAR(30) REFERENCES projects,
  grade INTEGER
);

--Step 6b Insert Grade Records given.

INSERT INTO grades (student_github, project_title, grade)
VALUES ('jhacks', 'Markov', 10),
('jhacks', 'Blockly', 2),
('sdevelops', 'Markov', 50),
('sdevelops', 'Blockly', 100);


--Step 7a Imagine you want to find the first name, last name, project title, project grade, and maximum grade for that project for a particular student.  Let's use Jane Hacker for example...let’s build a SELECT statement for first_name and last_name from the students table. Think of this as Query 1:

SELECT first_name, last_name FROM students WHERE github = 'jhacks';

--Step 7b Next, let’s select the grade and project_title for a student with a particular student_github value from the grades table. Think of this as Query 2:

SELECT project_title, grade FROM grades WHERE student_github = 'jhacks';

--Step 7c Now we need to select the title and max_grade from the projects table. Think of this as Query 3:

SELECT title, max_grade FROM projects;

--Step 7d To mush all that information together, you’ll use the JOIN feature of SELECT statements. For example, this join will grab information about all students and their grades

SELECT * FROM students JOIN grades ON (students.github = grades.student_github);

--Step 7e simplify with only the columns you want.  In this case, remove the redundant info.

SELECT students.first_name,
       students.last_name,
       grades.project_title,
       grades.grade
FROM students
JOIN grades ON (students.github = grades.student_github);

--Step 7f add the max grades to the previous query.

SELECT students.first_name,
       students.last_name,
       grades.project_title,
       grades.grade,
       projects.max_grade
FROM students
  JOIN grades ON (students.github = grades.student_github)
  JOIN projects ON (grades.project_title = projects.title);

--FINAL STEP previous query for only Jane.

SELECT students.first_name,
       students.last_name,
       grades.project_title,
       grades.grade,
       projects.max_grade
FROM students
  JOIN grades ON (students.github = grades.student_github)
  JOIN projects ON (grades.project_title = projects.title)
WHERE students.first_name = 'Jane';
