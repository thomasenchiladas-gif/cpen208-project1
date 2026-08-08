-- =====================================================================
-- CPEN 208: Introduction to Software Engineering — Project 1
-- University of Ghana, Department of Computer Engineering
-- Database: cpen208_project1
-- File: 01_schema.sql
-- Purpose: Creates the schema and all tables required to support:
--   1. Student personal information
--   2. Student fee payments
--   3. Course enrollment
--   4. Lecturer-to-course assignment
--   5. Lecturer-to-TA assignment
-- =====================================================================

-- Run this after connecting to the cpen208_project1 database, e.g.:
--   psql -U cpen208_admin -d cpen208_project1 -f 01_schema.sql

CREATE SCHEMA IF NOT EXISTS academics;
SET search_path TO academics, public;

-- ---------------------------------------------------------------------
-- ENUM TYPES
-- ---------------------------------------------------------------------
DO $$ BEGIN
    CREATE TYPE gender_type AS ENUM ('Male', 'Female', 'Other');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE semester_type AS ENUM ('First Semester', 'Second Semester');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE payment_method_type AS ENUM ('Mobile Money', 'Bank Transfer', 'Card', 'Cash', 'University Portal');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE grade_type AS ENUM ('A','B+','B','C+','C','D+','D','F','I','IP');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ---------------------------------------------------------------------
-- 1. STUDENT PERSONAL INFORMATION
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS students (
    student_id       SERIAL PRIMARY KEY,
    index_number     VARCHAR(15) NOT NULL UNIQUE,        -- e.g. 10987654
    first_name       VARCHAR(60) NOT NULL,
    last_name        VARCHAR(60) NOT NULL,
    email            VARCHAR(120) NOT NULL UNIQUE,
    phone            VARCHAR(20),
    date_of_birth    DATE,
    gender           gender_type,
    program           VARCHAR(100) NOT NULL DEFAULT 'BSc. Computer Engineering',
    level             SMALLINT NOT NULL CHECK (level IN (100,200,300,400)),
    year_of_admission SMALLINT NOT NULL,
    hall_of_residence VARCHAR(80),
    created_at        TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ---------------------------------------------------------------------
-- LECTURERS  (also doubles as the "person" table teaching assistants
-- link back to via students, since TAs at UG are typically senior/
-- graduate students)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS lecturers (
    lecturer_id      SERIAL PRIMARY KEY,
    staff_id         VARCHAR(15) NOT NULL UNIQUE,
    first_name       VARCHAR(60) NOT NULL,
    last_name        VARCHAR(60) NOT NULL,
    email            VARCHAR(120) NOT NULL UNIQUE,
    phone            VARCHAR(20),
    department       VARCHAR(100) NOT NULL DEFAULT 'Computer Engineering',
    academic_rank    VARCHAR(60) NOT NULL DEFAULT 'Lecturer',
    office_location  VARCHAR(60)
);

-- ---------------------------------------------------------------------
-- TEACHING ASSISTANTS (independent TA records with their own details)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS teaching_assistants (
    ta_id            SERIAL PRIMARY KEY,
    first_name       VARCHAR(60) NOT NULL,
    last_name        VARCHAR(60) NOT NULL,
    email            VARCHAR(120) NOT NULL UNIQUE,
    phone            VARCHAR(20),
    supervising_lecturer_id INTEGER REFERENCES lecturers(lecturer_id) ON DELETE SET NULL,
    appointment_date DATE NOT NULL DEFAULT CURRENT_DATE,
    department       VARCHAR(100) NOT NULL DEFAULT 'Computer Engineering'
);

-- ---------------------------------------------------------------------
-- COURSES
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS courses (
    course_id        SERIAL PRIMARY KEY,
    course_code      VARCHAR(15) NOT NULL UNIQUE,     -- e.g. CPEN 206
    course_title     VARCHAR(150) NOT NULL,
    credit_hours     SMALLINT NOT NULL DEFAULT 3,
    department       VARCHAR(100) NOT NULL DEFAULT 'Computer Engineering',
    level             SMALLINT NOT NULL CHECK (level IN (100,200,300,400))
);

-- ---------------------------------------------------------------------
-- 3. COURSE ENROLLMENT
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS enrollments (
    enrollment_id    SERIAL PRIMARY KEY,
    student_id       INTEGER NOT NULL REFERENCES students(student_id) ON DELETE CASCADE,
    course_id        INTEGER NOT NULL REFERENCES courses(course_id) ON DELETE CASCADE,
    academic_year    VARCHAR(9) NOT NULL,               -- e.g. 2025/2026
    semester         semester_type NOT NULL,
    grade            grade_type,
    enrolled_on      TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (student_id, course_id, academic_year, semester)
);

-- ---------------------------------------------------------------------
-- 4. LECTURER TO COURSE ASSIGNMENT
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS lecturer_course_assignments (
    assignment_id    SERIAL PRIMARY KEY,
    lecturer_id      INTEGER NOT NULL REFERENCES lecturers(lecturer_id) ON DELETE CASCADE,
    course_id        INTEGER NOT NULL REFERENCES courses(course_id) ON DELETE CASCADE,
    academic_year    VARCHAR(9) NOT NULL,
    semester         semester_type NOT NULL,
    UNIQUE (course_id, academic_year, semester, lecturer_id)
);

-- ---------------------------------------------------------------------
-- 5. LECTURER TO TA ASSIGNMENT
-- (a TA is assigned to help a specific lecturer with a specific course)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ta_course_assignments (
    assignment_id    SERIAL PRIMARY KEY,
    ta_id            INTEGER NOT NULL REFERENCES teaching_assistants(ta_id) ON DELETE CASCADE,
    lecturer_id      INTEGER NOT NULL REFERENCES lecturers(lecturer_id) ON DELETE CASCADE,
    course_id        INTEGER NOT NULL REFERENCES courses(course_id) ON DELETE CASCADE,
    academic_year    VARCHAR(9) NOT NULL,
    semester         semester_type NOT NULL,
    UNIQUE (ta_id, course_id, academic_year, semester)
);

-- ---------------------------------------------------------------------
-- 2. STUDENT FEE PAYMENTS
-- ---------------------------------------------------------------------

-- Defines how much is billed to a student per level/semester/academic year
CREATE TABLE IF NOT EXISTS fee_structure (
    fee_structure_id SERIAL PRIMARY KEY,
    program           VARCHAR(100) NOT NULL DEFAULT 'BSc. Computer Engineering',
    level             SMALLINT NOT NULL CHECK (level IN (100,200,300,400)),
    academic_year     VARCHAR(9) NOT NULL,
    semester          semester_type NOT NULL,
    amount_billed     NUMERIC(10,2) NOT NULL CHECK (amount_billed >= 0),
    UNIQUE (program, level, academic_year, semester)
);

-- Records of what each student has actually paid
CREATE TABLE IF NOT EXISTS fee_payments (
    payment_id        SERIAL PRIMARY KEY,
    student_id        INTEGER NOT NULL REFERENCES students(student_id) ON DELETE CASCADE,
    academic_year     VARCHAR(9) NOT NULL,
    semester          semester_type NOT NULL,
    amount_paid       NUMERIC(10,2) NOT NULL CHECK (amount_paid >= 0),
    payment_date      DATE NOT NULL DEFAULT CURRENT_DATE,
    payment_method    payment_method_type NOT NULL DEFAULT 'Mobile Money',
    reference_number  VARCHAR(40) NOT NULL UNIQUE
);

-- ---------------------------------------------------------------------
-- AUTH TABLES for the Next.js application (login / register / dashboard)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS app_users (
    user_id          SERIAL PRIMARY KEY,
    student_id        INTEGER UNIQUE REFERENCES students(student_id) ON DELETE CASCADE,
    email             VARCHAR(120) NOT NULL UNIQUE,
    password_hash     VARCHAR(255) NOT NULL,
    role              VARCHAR(20) NOT NULL DEFAULT 'student',
    created_at        TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ---------------------------------------------------------------------
-- INDEXES
-- ---------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_enrollments_student ON enrollments(student_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_course ON enrollments(course_id);
CREATE INDEX IF NOT EXISTS idx_fee_payments_student ON fee_payments(student_id);
CREATE INDEX IF NOT EXISTS idx_lecturer_course_lecturer ON lecturer_course_assignments(lecturer_id);
CREATE INDEX IF NOT EXISTS idx_ta_course_ta ON ta_course_assignments(ta_id);