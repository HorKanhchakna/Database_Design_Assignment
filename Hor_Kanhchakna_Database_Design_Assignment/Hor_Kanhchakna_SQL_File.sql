CREATE TABLE Departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100) NOT NULL
);

CREATE TABLE Faculty (
    faculty_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES Departments(department_id)
);

CREATE TABLE Courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_code VARCHAR(20) UNIQUE NOT NULL,
    course_name VARCHAR(100) NOT NULL,
    faculty_id INT,
    department_id INT,
    FOREIGN KEY (faculty_id) REFERENCES Faculty(faculty_id),
    FOREIGN KEY (department_id) REFERENCES Departments(department_id)
);

CREATE TABLE Students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE Enrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    course_id INT,
    enrollment_date DATE,
    grade VARCHAR(2),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);


INSERT INTO Departments (department_name) VALUES ('Computer Science'), ('Mathematics');

INSERT INTO Faculty (first_name, last_name, department_id) VALUES ('John', 'Doe', 1), ('Jane', 'Smith', 2);

INSERT INTO Courses (course_code, course_name, faculty_id, department_id) VALUES ('CS101', 'Intro to Programming', 1, 1), ('MATH201', 'Calculus I', 2, 2);

INSERT INTO Students (first_name, last_name, date_of_birth, email) VALUES ('Hor', 'Kanhchakna', '2004-07-01', 'kanhchakna1@gmail.com'), ('Bo', 'Williams', '2002-03-20', 'bob@example.com');

INSERT INTO Enrollments (student_id, course_id, enrollment_date, grade) VALUES (1, 1, '2023-09-01', 'A'), (1, 2, '2023-09-01', 'B'),(2,1,'2023-09-01','C');