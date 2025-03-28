-- Create departments table
CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(100) NOT NULL
);

-- Create faculty table
CREATE TABLE faculty (
    faculty_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    department_id INT NOT NULL,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- Create students table
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    gpa DECIMAL(3,2) DEFAULT NULL
);

-- Create courses table
CREATE TABLE courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(20) UNIQUE NOT NULL,
    title VARCHAR(100) NOT NULL,
    credits INT NOT NULL,
    faculty_id INT NOT NULL,
    department_id INT NOT NULL,
    FOREIGN KEY (faculty_id) REFERENCES faculty(faculty_id),
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- Create enrollments table
CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enrollment_date DATE NOT NULL,
    grade VARCHAR(2) DEFAULT NULL,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    UNIQUE (student_id, course_id)
);

-- Insert sample departments
INSERT INTO departments (name, location) VALUES 
('Computer Science', 'Building A, Room 101'),
('Mathematics', 'Building B, Room 205'),
('Physics', 'Building C, Room 310');

-- Insert sample faculty
INSERT INTO faculty (first_name, last_name, email, department_id) VALUES 
('John', 'Smith', 'john.smith@university.edu', 1),
('Sarah', 'Johnson', 'sarah.johnson@university.edu', 1),
('Michael', 'Brown', 'michael.brown@university.edu', 2),
('Emily', 'Davis', 'emily.davis@university.edu', 3);

-- Insert sample students
INSERT INTO students (first_name, last_name, date_of_birth, email) VALUES 
('Alice', 'Johnson', '2001-06-15', 'alice@university.edu'),
('Bob', 'Williams', '2000-11-22', 'bob@university.edu'),
('Charlie', 'Miller', '2002-03-08', 'charlie@university.edu'),
('Diana', 'Garcia', '2001-09-30', 'diana@university.edu');

-- Insert sample courses
INSERT INTO courses (code, title, credits, faculty_id, department_id) VALUES 
('CS101', 'Introduction to Programming', 3, 1, 1),
('CS201', 'Data Structures', 4, 1, 1),
('CS301', 'Database Systems', 4, 2, 1),
('MATH202', 'Linear Algebra', 3, 3, 2),
('PHYS101', 'General Physics', 4, 4, 3);

-- Insert sample enrollments
INSERT INTO enrollments (student_id, course_id, enrollment_date, grade) VALUES 
(1, 1, '2023-09-01', 'A'),
(1, 3, '2023-09-01', 'B+'),
(2, 1, '2023-09-01', 'B'),
(2, 2, '2023-09-01', 'A-'),
(3, 4, '2023-09-01', 'C+'),
(4, 1, '2023-09-01', 'A'),
(4, 5, '2023-09-01', NULL);


SELECT s.student_id, s.first_name, s.last_name, e.enrollment_date, e.grade
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
WHERE e.course_id = 1;  


SELECT f.faculty_id, f.first_name, f.last_name, f.email
FROM faculty f
WHERE f.department_id = 1;  

SELECT c.course_id, c.code, c.title, e.enrollment_date, e.grade
FROM courses c
JOIN enrollments e ON c.course_id = e.course_id
WHERE e.student_id = 1;  

SELECT s.student_id, s.first_name, s.last_name
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
WHERE e.enrollment_id IS NULL;

SELECT c.code, c.title, 
       AVG(CASE 
           WHEN e.grade = 'A' THEN 4.0
           WHEN e.grade = 'A-' THEN 3.7
           WHEN e.grade = 'B+' THEN 3.3
           WHEN e.grade = 'B' THEN 3.0
           WHEN e.grade = 'B-' THEN 2.7
           WHEN e.grade = 'C+' THEN 2.3
           WHEN e.grade = 'C' THEN 2.0
           WHEN e.grade = 'C-' THEN 1.7
           WHEN e.grade = 'D+' THEN 1.3
           WHEN e.grade = 'D' THEN 1.0
           ELSE 0.0
       END) as average_grade_points
FROM courses c
JOIN enrollments e ON c.course_id = e.course_id
WHERE c.course_id = 1  
GROUP BY c.course_id;

DELIMITER //
CREATE TRIGGER update_student_gpa
AFTER UPDATE ON enrollments
FOR EACH ROW
BEGIN
    DECLARE total_points DECIMAL(10,2);
    DECLARE total_credits INT;
    
    -- Calculate total grade points and credits
    SELECT SUM(
        CASE 
            WHEN e.grade = 'A' THEN 4.0 * c.credits
            WHEN e.grade = 'A-' THEN 3.7 * c.credits
            WHEN e.grade = 'B+' THEN 3.3 * c.credits
            WHEN e.grade = 'B' THEN 3.0 * c.credits
            WHEN e.grade = 'B-' THEN 2.7 * c.credits
            WHEN e.grade = 'C+' THEN 2.3 * c.credits
            WHEN e.grade = 'C' THEN 2.0 * c.credits
            WHEN e.grade = 'C-' THEN 1.7 * c.credits
            WHEN e.grade = 'D+' THEN 1.3 * c.credits
            WHEN e.grade = 'D' THEN 1.0 * c.credits
            ELSE 0.0
        END
    ), SUM(c.credits)
    INTO total_points, total_credits
    FROM enrollments e
    JOIN courses c ON e.course_id = c.course_id
    WHERE e.student_id = NEW.student_id AND e.grade IS NOT NULL;
    
    -- Update student's GPA
    IF total_credits > 0 THEN
        UPDATE students 
        SET gpa = total_points / total_credits
        WHERE student_id = NEW.student_id;
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE enroll_student(
    IN p_student_id INT,
    IN p_course_id INT,
    IN p_enrollment_date DATE
)
BEGIN
    DECLARE student_exists INT;
    DECLARE course_exists INT;
    DECLARE already_enrolled INT;
    
    -- Check if student exists
    SELECT COUNT(*) INTO student_exists FROM students WHERE student_id = p_student_id;
    IF student_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Student does not exist';
    END IF;
    
    -- Check if course exists
    SELECT COUNT(*) INTO course_exists FROM courses WHERE course_id = p_course_id;
    IF course_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Course does not exist';
    END IF;
    
    -- Check if already enrolled
    SELECT COUNT(*) INTO already_enrolled FROM enrollments 
    WHERE student_id = p_student_id AND course_id = p_course_id;
    IF already_enrolled > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Student is already enrolled in this course';
    END IF;
    
    -- Enroll the student
    INSERT INTO enrollments (student_id, course_id, enrollment_date)
    VALUES (p_student_id, p_course_id, p_enrollment_date);
    
    SELECT CONCAT('Student ', p_student_id, ' successfully enrolled in course ', p_course_id) AS message;
END //
DELIMITER ;



