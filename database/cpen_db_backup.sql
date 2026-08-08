--
-- PostgreSQL database dump
--

\restrict ZTVmxEn2038xPcyFApO2mVZCuwHHCkVOT055uRfgk87aaYNerfchcHyYgcCCH4I

-- Dumped from database version 16.14 (Ubuntu 16.14-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.14 (Ubuntu 16.14-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: academics; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA academics;


ALTER SCHEMA academics OWNER TO postgres;

--
-- Name: gender_type; Type: TYPE; Schema: academics; Owner: postgres
--

CREATE TYPE academics.gender_type AS ENUM (
    'Male',
    'Female',
    'Other'
);


ALTER TYPE academics.gender_type OWNER TO postgres;

--
-- Name: grade_type; Type: TYPE; Schema: academics; Owner: postgres
--

CREATE TYPE academics.grade_type AS ENUM (
    'A',
    'B+',
    'B',
    'C+',
    'C',
    'D+',
    'D',
    'F',
    'I',
    'IP'
);


ALTER TYPE academics.grade_type OWNER TO postgres;

--
-- Name: payment_method_type; Type: TYPE; Schema: academics; Owner: postgres
--

CREATE TYPE academics.payment_method_type AS ENUM (
    'Mobile Money',
    'Bank Transfer',
    'Card',
    'Cash',
    'University Portal'
);


ALTER TYPE academics.payment_method_type OWNER TO postgres;

--
-- Name: semester_type; Type: TYPE; Schema: academics; Owner: postgres
--

CREATE TYPE academics.semester_type AS ENUM (
    'First Semester',
    'Second Semester'
);


ALTER TYPE academics.semester_type OWNER TO postgres;

--
-- Name: get_outstanding_fees(); Type: FUNCTION; Schema: academics; Owner: postgres
--

CREATE FUNCTION academics.get_outstanding_fees() RETURNS json
    LANGUAGE plpgsql STABLE
    SET search_path TO 'academics', 'public'
    AS $$
DECLARE
    result JSON;
BEGIN
    SELECT COALESCE(json_agg(t), '[]'::json) INTO result
    FROM (
        SELECT
            s.student_id,
            s.index_number,
            s.first_name || ' ' || s.last_name          AS full_name,
            s.level,
            fs.academic_year,
            fs.semester,
            fs.amount_billed                             AS amount_billed,
            COALESCE(SUM(fp.amount_paid), 0)::numeric(10,2) AS amount_paid,
            (fs.amount_billed - COALESCE(SUM(fp.amount_paid), 0))::numeric(10,2) AS outstanding_balance
        FROM students s
        JOIN fee_structure fs
          ON fs.program = s.program AND fs.level = s.level
        LEFT JOIN fee_payments fp
          ON fp.student_id = s.student_id
         AND fp.academic_year = fs.academic_year
         AND fp.semester = fs.semester
        GROUP BY s.student_id, s.index_number, s.first_name, s.last_name,
                 s.level, fs.academic_year, fs.semester, fs.amount_billed
        ORDER BY outstanding_balance DESC, s.last_name
    ) t;

    RETURN result;
END;
$$;


ALTER FUNCTION academics.get_outstanding_fees() OWNER TO postgres;

--
-- Name: get_outstanding_fees(integer); Type: FUNCTION; Schema: academics; Owner: postgres
--

CREATE FUNCTION academics.get_outstanding_fees(p_student_id integer) RETURNS json
    LANGUAGE plpgsql STABLE
    SET search_path TO 'academics', 'public'
    AS $$
DECLARE
    result JSON;
BEGIN
    SELECT COALESCE(json_agg(t), '[]'::json) INTO result
    FROM (
        SELECT
            s.student_id,
            s.index_number,
            s.first_name || ' ' || s.last_name          AS full_name,
            s.level,
            fs.academic_year,
            fs.semester,
            fs.amount_billed,
            COALESCE(SUM(fp.amount_paid), 0)::numeric(10,2) AS amount_paid,
            (fs.amount_billed - COALESCE(SUM(fp.amount_paid), 0))::numeric(10,2) AS outstanding_balance
        FROM students s
        JOIN fee_structure fs
          ON fs.program = s.program AND fs.level = s.level
        LEFT JOIN fee_payments fp
          ON fp.student_id = s.student_id
         AND fp.academic_year = fs.academic_year
         AND fp.semester = fs.semester
        WHERE s.student_id = p_student_id
        GROUP BY s.student_id, s.index_number, s.first_name, s.last_name,
                 s.level, fs.academic_year, fs.semester, fs.amount_billed
    ) t;

    RETURN result;
END;
$$;


ALTER FUNCTION academics.get_outstanding_fees(p_student_id integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: app_users; Type: TABLE; Schema: academics; Owner: postgres
--

CREATE TABLE academics.app_users (
    user_id integer NOT NULL,
    student_id integer,
    email character varying(120) NOT NULL,
    password_hash character varying(255) NOT NULL,
    role character varying(20) DEFAULT 'student'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    lecturer_id integer,
    CONSTRAINT app_users_exactly_one_owner CHECK ((((student_id IS NOT NULL) AND (lecturer_id IS NULL)) OR ((student_id IS NULL) AND (lecturer_id IS NOT NULL))))
);


ALTER TABLE academics.app_users OWNER TO postgres;

--
-- Name: app_users_user_id_seq; Type: SEQUENCE; Schema: academics; Owner: postgres
--

CREATE SEQUENCE academics.app_users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academics.app_users_user_id_seq OWNER TO postgres;

--
-- Name: app_users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: academics; Owner: postgres
--

ALTER SEQUENCE academics.app_users_user_id_seq OWNED BY academics.app_users.user_id;


--
-- Name: courses; Type: TABLE; Schema: academics; Owner: postgres
--

CREATE TABLE academics.courses (
    course_id integer NOT NULL,
    course_code character varying(15) NOT NULL,
    course_title character varying(150) NOT NULL,
    credit_hours smallint DEFAULT 3 NOT NULL,
    department character varying(100) DEFAULT 'Computer Engineering'::character varying NOT NULL,
    level smallint NOT NULL,
    CONSTRAINT courses_level_check CHECK ((level = ANY (ARRAY[100, 200, 300, 400])))
);


ALTER TABLE academics.courses OWNER TO postgres;

--
-- Name: courses_course_id_seq; Type: SEQUENCE; Schema: academics; Owner: postgres
--

CREATE SEQUENCE academics.courses_course_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academics.courses_course_id_seq OWNER TO postgres;

--
-- Name: courses_course_id_seq; Type: SEQUENCE OWNED BY; Schema: academics; Owner: postgres
--

ALTER SEQUENCE academics.courses_course_id_seq OWNED BY academics.courses.course_id;


--
-- Name: enrollments; Type: TABLE; Schema: academics; Owner: postgres
--

CREATE TABLE academics.enrollments (
    enrollment_id integer NOT NULL,
    student_id integer NOT NULL,
    course_id integer NOT NULL,
    academic_year character varying(9) NOT NULL,
    semester academics.semester_type NOT NULL,
    grade academics.grade_type,
    enrolled_on timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE academics.enrollments OWNER TO postgres;

--
-- Name: enrollments_enrollment_id_seq; Type: SEQUENCE; Schema: academics; Owner: postgres
--

CREATE SEQUENCE academics.enrollments_enrollment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academics.enrollments_enrollment_id_seq OWNER TO postgres;

--
-- Name: enrollments_enrollment_id_seq; Type: SEQUENCE OWNED BY; Schema: academics; Owner: postgres
--

ALTER SEQUENCE academics.enrollments_enrollment_id_seq OWNED BY academics.enrollments.enrollment_id;


--
-- Name: fee_payments; Type: TABLE; Schema: academics; Owner: postgres
--

CREATE TABLE academics.fee_payments (
    payment_id integer NOT NULL,
    student_id integer NOT NULL,
    academic_year character varying(9) NOT NULL,
    semester academics.semester_type NOT NULL,
    amount_paid numeric(10,2) NOT NULL,
    payment_date date DEFAULT CURRENT_DATE NOT NULL,
    payment_method academics.payment_method_type DEFAULT 'Mobile Money'::academics.payment_method_type NOT NULL,
    reference_number character varying(40) NOT NULL,
    CONSTRAINT fee_payments_amount_paid_check CHECK ((amount_paid >= (0)::numeric))
);


ALTER TABLE academics.fee_payments OWNER TO postgres;

--
-- Name: fee_payments_payment_id_seq; Type: SEQUENCE; Schema: academics; Owner: postgres
--

CREATE SEQUENCE academics.fee_payments_payment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academics.fee_payments_payment_id_seq OWNER TO postgres;

--
-- Name: fee_payments_payment_id_seq; Type: SEQUENCE OWNED BY; Schema: academics; Owner: postgres
--

ALTER SEQUENCE academics.fee_payments_payment_id_seq OWNED BY academics.fee_payments.payment_id;


--
-- Name: fee_structure; Type: TABLE; Schema: academics; Owner: postgres
--

CREATE TABLE academics.fee_structure (
    fee_structure_id integer NOT NULL,
    program character varying(100) DEFAULT 'BSc. Computer Engineering'::character varying NOT NULL,
    level smallint NOT NULL,
    academic_year character varying(9) NOT NULL,
    semester academics.semester_type NOT NULL,
    amount_billed numeric(10,2) NOT NULL,
    CONSTRAINT fee_structure_amount_billed_check CHECK ((amount_billed >= (0)::numeric)),
    CONSTRAINT fee_structure_level_check CHECK ((level = ANY (ARRAY[100, 200, 300, 400])))
);


ALTER TABLE academics.fee_structure OWNER TO postgres;

--
-- Name: fee_structure_fee_structure_id_seq; Type: SEQUENCE; Schema: academics; Owner: postgres
--

CREATE SEQUENCE academics.fee_structure_fee_structure_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academics.fee_structure_fee_structure_id_seq OWNER TO postgres;

--
-- Name: fee_structure_fee_structure_id_seq; Type: SEQUENCE OWNED BY; Schema: academics; Owner: postgres
--

ALTER SEQUENCE academics.fee_structure_fee_structure_id_seq OWNED BY academics.fee_structure.fee_structure_id;


--
-- Name: lecturer_course_assignments; Type: TABLE; Schema: academics; Owner: postgres
--

CREATE TABLE academics.lecturer_course_assignments (
    assignment_id integer NOT NULL,
    lecturer_id integer NOT NULL,
    course_id integer NOT NULL,
    academic_year character varying(9) NOT NULL,
    semester academics.semester_type NOT NULL
);


ALTER TABLE academics.lecturer_course_assignments OWNER TO postgres;

--
-- Name: lecturer_course_assignments_assignment_id_seq; Type: SEQUENCE; Schema: academics; Owner: postgres
--

CREATE SEQUENCE academics.lecturer_course_assignments_assignment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academics.lecturer_course_assignments_assignment_id_seq OWNER TO postgres;

--
-- Name: lecturer_course_assignments_assignment_id_seq; Type: SEQUENCE OWNED BY; Schema: academics; Owner: postgres
--

ALTER SEQUENCE academics.lecturer_course_assignments_assignment_id_seq OWNED BY academics.lecturer_course_assignments.assignment_id;


--
-- Name: lecturers; Type: TABLE; Schema: academics; Owner: postgres
--

CREATE TABLE academics.lecturers (
    lecturer_id integer NOT NULL,
    staff_id character varying(15) NOT NULL,
    first_name character varying(60) NOT NULL,
    last_name character varying(60) NOT NULL,
    email character varying(120) NOT NULL,
    phone character varying(20),
    department character varying(100) DEFAULT 'Computer Engineering'::character varying NOT NULL,
    academic_rank character varying(60) DEFAULT 'Lecturer'::character varying NOT NULL,
    office_location character varying(60)
);


ALTER TABLE academics.lecturers OWNER TO postgres;

--
-- Name: lecturers_lecturer_id_seq; Type: SEQUENCE; Schema: academics; Owner: postgres
--

CREATE SEQUENCE academics.lecturers_lecturer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academics.lecturers_lecturer_id_seq OWNER TO postgres;

--
-- Name: lecturers_lecturer_id_seq; Type: SEQUENCE OWNED BY; Schema: academics; Owner: postgres
--

ALTER SEQUENCE academics.lecturers_lecturer_id_seq OWNED BY academics.lecturers.lecturer_id;


--
-- Name: students; Type: TABLE; Schema: academics; Owner: postgres
--

CREATE TABLE academics.students (
    student_id integer NOT NULL,
    index_number character varying(15) NOT NULL,
    first_name character varying(60) NOT NULL,
    last_name character varying(60) NOT NULL,
    email character varying(120) NOT NULL,
    phone character varying(20),
    date_of_birth date,
    gender academics.gender_type,
    program character varying(100) DEFAULT 'BSc. Computer Engineering'::character varying NOT NULL,
    level smallint NOT NULL,
    year_of_admission smallint NOT NULL,
    hall_of_residence character varying(80),
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT students_level_check CHECK ((level = ANY (ARRAY[100, 200, 300, 400])))
);


ALTER TABLE academics.students OWNER TO postgres;

--
-- Name: students_student_id_seq; Type: SEQUENCE; Schema: academics; Owner: postgres
--

CREATE SEQUENCE academics.students_student_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academics.students_student_id_seq OWNER TO postgres;

--
-- Name: students_student_id_seq; Type: SEQUENCE OWNED BY; Schema: academics; Owner: postgres
--

ALTER SEQUENCE academics.students_student_id_seq OWNED BY academics.students.student_id;


--
-- Name: ta_course_assignments; Type: TABLE; Schema: academics; Owner: postgres
--

CREATE TABLE academics.ta_course_assignments (
    assignment_id integer NOT NULL,
    ta_id integer NOT NULL,
    lecturer_id integer NOT NULL,
    course_id integer NOT NULL,
    academic_year character varying(9) NOT NULL,
    semester academics.semester_type NOT NULL
);


ALTER TABLE academics.ta_course_assignments OWNER TO postgres;

--
-- Name: ta_course_assignments_assignment_id_seq; Type: SEQUENCE; Schema: academics; Owner: postgres
--

CREATE SEQUENCE academics.ta_course_assignments_assignment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academics.ta_course_assignments_assignment_id_seq OWNER TO postgres;

--
-- Name: ta_course_assignments_assignment_id_seq; Type: SEQUENCE OWNED BY; Schema: academics; Owner: postgres
--

ALTER SEQUENCE academics.ta_course_assignments_assignment_id_seq OWNED BY academics.ta_course_assignments.assignment_id;


--
-- Name: teaching_assistants; Type: TABLE; Schema: academics; Owner: postgres
--

CREATE TABLE academics.teaching_assistants (
    ta_id integer NOT NULL,
    first_name character varying(60) NOT NULL,
    last_name character varying(60) NOT NULL,
    email character varying(120) NOT NULL,
    phone character varying(20),
    supervising_lecturer_id integer,
    appointment_date date DEFAULT CURRENT_DATE NOT NULL,
    department character varying(100) DEFAULT 'Computer Engineering'::character varying NOT NULL
);


ALTER TABLE academics.teaching_assistants OWNER TO postgres;

--
-- Name: teaching_assistants_ta_id_seq; Type: SEQUENCE; Schema: academics; Owner: postgres
--

CREATE SEQUENCE academics.teaching_assistants_ta_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academics.teaching_assistants_ta_id_seq OWNER TO postgres;

--
-- Name: teaching_assistants_ta_id_seq; Type: SEQUENCE OWNED BY; Schema: academics; Owner: postgres
--

ALTER SEQUENCE academics.teaching_assistants_ta_id_seq OWNED BY academics.teaching_assistants.ta_id;


--
-- Name: app_users user_id; Type: DEFAULT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.app_users ALTER COLUMN user_id SET DEFAULT nextval('academics.app_users_user_id_seq'::regclass);


--
-- Name: courses course_id; Type: DEFAULT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.courses ALTER COLUMN course_id SET DEFAULT nextval('academics.courses_course_id_seq'::regclass);


--
-- Name: enrollments enrollment_id; Type: DEFAULT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.enrollments ALTER COLUMN enrollment_id SET DEFAULT nextval('academics.enrollments_enrollment_id_seq'::regclass);


--
-- Name: fee_payments payment_id; Type: DEFAULT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.fee_payments ALTER COLUMN payment_id SET DEFAULT nextval('academics.fee_payments_payment_id_seq'::regclass);


--
-- Name: fee_structure fee_structure_id; Type: DEFAULT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.fee_structure ALTER COLUMN fee_structure_id SET DEFAULT nextval('academics.fee_structure_fee_structure_id_seq'::regclass);


--
-- Name: lecturer_course_assignments assignment_id; Type: DEFAULT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.lecturer_course_assignments ALTER COLUMN assignment_id SET DEFAULT nextval('academics.lecturer_course_assignments_assignment_id_seq'::regclass);


--
-- Name: lecturers lecturer_id; Type: DEFAULT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.lecturers ALTER COLUMN lecturer_id SET DEFAULT nextval('academics.lecturers_lecturer_id_seq'::regclass);


--
-- Name: students student_id; Type: DEFAULT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.students ALTER COLUMN student_id SET DEFAULT nextval('academics.students_student_id_seq'::regclass);


--
-- Name: ta_course_assignments assignment_id; Type: DEFAULT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.ta_course_assignments ALTER COLUMN assignment_id SET DEFAULT nextval('academics.ta_course_assignments_assignment_id_seq'::regclass);


--
-- Name: teaching_assistants ta_id; Type: DEFAULT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.teaching_assistants ALTER COLUMN ta_id SET DEFAULT nextval('academics.teaching_assistants_ta_id_seq'::regclass);


--
-- Data for Name: app_users; Type: TABLE DATA; Schema: academics; Owner: postgres
--

COPY academics.app_users (user_id, student_id, email, password_hash, role, created_at, lecturer_id) FROM stdin;
1	1	abu.golda@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
2	2	adzasa.stephen@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
3	3	afia.osei-safo@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
4	4	agbemavi.ryan@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
5	5	agormeda.nathaniel@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
6	6	ahmad.kayelgu@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
7	7	amprofi.yaa@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
8	8	asante.esme@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
9	9	asante.gabriel@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
10	10	botchway.daniel@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
11	11	brian.assibey@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
12	12	caleb.mensah@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
13	13	cyril.ofori@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
14	14	david.odoi-anim@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
15	15	doe.collins@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
16	16	douglas.adjei@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
17	17	dzidzor.apawudza@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
18	18	edward.ankrah@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
19	19	emmanuel.osae@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
20	20	emmanuel.dery@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
21	21	ethan.nartey@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
22	22	gilbert.yeboah@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
23	23	jerrold.kyekye@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
24	24	joseph.amankwah@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
25	25	joshua.appiah@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
26	26	jude.addo@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
27	27	kemausuor.tetteh@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
28	28	kenzi.segbefia@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
29	29	kessey.david@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
30	30	kingsley.quartey@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
31	31	kofi.oware-tano@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
32	32	kwaku.barimah@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
33	33	kwame.obeng@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
34	34	kwamena.quaicoe@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
35	35	maame.ahu@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
36	36	maame.grant-aidoo@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
37	37	manford.oppong@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
38	38	nana.odoom@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
39	39	nana.anokye@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
40	40	newlove.kwarfo@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
41	41	obeng.ernest@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
42	42	obeng.ruth@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
43	43	owusu.koranteng@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
44	44	owusu.boadiwaa@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
45	45	paula.frimpong@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
46	46	quaicoo.emile@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
47	47	romel.lartey@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
48	48	sandra.mettle@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
49	49	sekyere.bempong@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
50	50	tetteh.christian@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
51	51	tietaah.sonnu@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
52	52	van.quansah@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
53	53	william.enchill@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
54	54	kelvin.saah@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
55	55	etsey.hannah@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
56	56	adu.mini@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
57	57	gideon.amofa@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
58	58	paul.amponsah@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
59	59	najiib.stephen@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
60	60	joshua.asirifi@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
61	61	eklou.juliet@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
62	62	de-andra.ayebo@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
63	63	masud.nasir@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
64	64	daniel.frimpong@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
65	65	adjei.priscilla@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
66	66	reuben.adomako@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
67	67	ocansey.frederick@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
68	68	dogbatse.darlington@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
69	69	troy.thomas@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
70	70	lydia.tiwaah@st.ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	student	2026-07-25 19:52:09.644977	\N
100	\N	kwame.anokye@ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	lecturer	2026-07-26 00:57:33.110873	1
101	\N	grace.adjei@ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	lecturer	2026-07-26 00:57:33.110873	2
102	\N	samuel.tetteh@ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	lecturer	2026-07-26 00:57:33.110873	3
103	\N	comfort.nkrumah@ug.edu.gh	$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u	lecturer	2026-07-26 00:57:33.110873	4
\.


--
-- Data for Name: courses; Type: TABLE DATA; Schema: academics; Owner: postgres
--

COPY academics.courses (course_id, course_code, course_title, credit_hours, department, level) FROM stdin;
1	CPEN 204	Algorithms and Computation	3	Computer Engineering	200
2	CPEN 206	Linear Circuits	3	Computer Engineering	200
3	CPEN 208	Introduction to Software Engineering	3	Computer Engineering	200
4	CPEN 212	Data Communications	3	Computer Engineering	200
\.


--
-- Data for Name: enrollments; Type: TABLE DATA; Schema: academics; Owner: postgres
--

COPY academics.enrollments (enrollment_id, student_id, course_id, academic_year, semester, grade, enrolled_on) FROM stdin;
1	1	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
2	1	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
3	1	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
4	1	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
5	2	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
6	2	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
7	2	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
8	2	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
9	3	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
10	3	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
11	3	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
12	3	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
13	4	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
14	4	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
15	4	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
16	4	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
17	5	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
18	5	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
19	5	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
20	5	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
21	6	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
22	6	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
23	6	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
24	6	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
25	7	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
26	7	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
27	7	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
28	7	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
29	8	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
30	8	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
31	8	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
32	8	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
33	9	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
34	9	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
35	9	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
36	9	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
37	10	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
38	10	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
39	10	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
40	10	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
41	11	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
42	11	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
43	11	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
44	11	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
45	12	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
46	12	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
47	12	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
48	12	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
49	13	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
50	13	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
51	13	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
52	13	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
53	14	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
54	14	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
55	14	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
56	14	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
57	15	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
58	15	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
59	15	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
60	15	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
61	16	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
62	16	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
63	16	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
64	16	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
65	17	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
66	17	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
67	17	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
68	17	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
69	18	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
70	18	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
71	18	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
72	18	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
73	19	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
74	19	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
75	19	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
76	19	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
77	20	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
78	20	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
79	20	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
80	20	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
81	21	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
82	21	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
83	21	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
84	21	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
85	22	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
86	22	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
87	22	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
88	22	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
89	23	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
90	23	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
91	23	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
92	23	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
93	24	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
94	24	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
95	24	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
96	24	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
97	25	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
98	25	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
99	25	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
100	25	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
101	26	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
102	26	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
103	26	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
104	26	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
105	27	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
106	27	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
107	27	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
108	27	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
109	28	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
110	28	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
111	28	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
112	28	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
113	29	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
114	29	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
115	29	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
116	29	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
117	30	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
118	30	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
119	30	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
120	30	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
121	31	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
122	31	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
123	31	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
124	31	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
125	32	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
126	32	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
127	32	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
128	32	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
129	33	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
130	33	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
131	33	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
132	33	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
133	34	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
134	34	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
135	34	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
136	34	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
137	35	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
138	35	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
139	35	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
140	35	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
141	36	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
142	36	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
143	36	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
144	36	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
145	37	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
146	37	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
147	37	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
148	37	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
149	38	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
150	38	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
151	38	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
152	38	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
153	39	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
154	39	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
155	39	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
156	39	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
157	40	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
158	40	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
159	40	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
160	40	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
161	41	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
162	41	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
163	41	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
164	41	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
165	42	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
166	42	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
167	42	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
168	42	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
169	43	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
170	43	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
171	43	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
172	43	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
173	44	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
174	44	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
175	44	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
176	44	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
177	45	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
178	45	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
179	45	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
180	45	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
181	46	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
182	46	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
183	46	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
184	46	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
185	47	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
186	47	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
187	47	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
188	47	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
189	48	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
190	48	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
191	48	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
192	48	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
193	49	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
194	49	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
195	49	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
196	49	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
197	50	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
198	50	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
199	50	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
200	50	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
201	51	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
202	51	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
203	51	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
204	51	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
205	52	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
206	52	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
207	52	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
208	52	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
209	53	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
210	53	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
211	53	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
212	53	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
213	54	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
214	54	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
215	54	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
216	54	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
217	55	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
218	55	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
219	55	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
220	55	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
221	56	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
222	56	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
223	56	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
224	56	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
225	57	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
226	57	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
227	57	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
228	57	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
229	58	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
230	58	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
231	58	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
232	58	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
233	59	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
234	59	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
235	59	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
236	59	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
237	60	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
238	60	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
239	60	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
240	60	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
241	61	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
242	61	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
243	61	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
244	61	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
245	62	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
246	62	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
247	62	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
248	62	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
249	63	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
250	63	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
251	63	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
252	63	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
253	64	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
254	64	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
255	64	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
256	64	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
257	65	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
258	65	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
259	65	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
260	65	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
261	66	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
262	66	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
263	66	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
264	66	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
265	67	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
266	67	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
267	67	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
268	67	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
269	68	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
270	68	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
271	68	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
272	68	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
273	69	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
274	69	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
275	69	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
276	69	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
277	70	1	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
278	70	2	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
279	70	3	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
280	70	4	2025/2026	First Semester	\N	2026-07-25 19:52:09.61834
\.


--
-- Data for Name: fee_payments; Type: TABLE DATA; Schema: academics; Owner: postgres
--

COPY academics.fee_payments (payment_id, student_id, academic_year, semester, amount_paid, payment_date, payment_method, reference_number) FROM stdin;
1	1	2025/2026	First Semester	3500.00	2025-09-05	Mobile Money	MM-2025-0001
2	2	2025/2026	First Semester	2000.00	2025-09-10	Bank Transfer	BT-2025-0002
3	3	2025/2026	First Semester	1500.00	2025-09-12	Mobile Money	MM-2025-0003
4	4	2025/2026	First Semester	3500.00	2025-09-08	University Portal	UP-2025-0004
5	5	2025/2026	First Semester	1000.00	2025-09-14	Cash	CS-2025-0005
6	6	2025/2026	First Semester	3500.00	2025-09-06	Card	CD-2025-0006
\.


--
-- Data for Name: fee_structure; Type: TABLE DATA; Schema: academics; Owner: postgres
--

COPY academics.fee_structure (fee_structure_id, program, level, academic_year, semester, amount_billed) FROM stdin;
1	BSc. Computer Engineering	200	2025/2026	First Semester	3500.00
\.


--
-- Data for Name: lecturer_course_assignments; Type: TABLE DATA; Schema: academics; Owner: postgres
--

COPY academics.lecturer_course_assignments (assignment_id, lecturer_id, course_id, academic_year, semester) FROM stdin;
1	1	2	2025/2026	First Semester
2	2	4	2025/2026	First Semester
3	3	1	2025/2026	First Semester
4	4	3	2025/2026	First Semester
\.


--
-- Data for Name: lecturers; Type: TABLE DATA; Schema: academics; Owner: postgres
--

COPY academics.lecturers (lecturer_id, staff_id, first_name, last_name, email, phone, department, academic_rank, office_location) FROM stdin;
1	UG-L001	Kwame	Anokye	kwame.anokye@ug.edu.gh	0208000001	Computer Engineering	Senior Lecturer	CBAS Block A, Rm 12
2	UG-L002	Grace	Adjei	grace.adjei@ug.edu.gh	0208000002	Computer Engineering	Lecturer	CBAS Block A, Rm 15
3	UG-L003	Samuel	Tetteh	samuel.tetteh@ug.edu.gh	0208000003	Computer Engineering	Associate Professor	CBAS Block B, Rm 3
4	UG-L004	Comfort	Nkrumah	comfort.nkrumah@ug.edu.gh	0208000004	Computer Engineering	Lecturer	CBAS Block A, Rm 9
\.


--
-- Data for Name: students; Type: TABLE DATA; Schema: academics; Owner: postgres
--

COPY academics.students (student_id, index_number, first_name, last_name, email, phone, date_of_birth, gender, program, level, year_of_admission, hall_of_residence, created_at) FROM stdin;
1	22384451	Abu Neaquittae	Golda	abu.golda@st.ug.edu.gh	0244000101	2004-01-01	Female	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
2	22357814	Adzasa Stephen	Yaw	adzasa.stephen@st.ug.edu.gh	0244000102	2004-01-02	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
3	22375367	Afia Beaa	Osei-Safo	afia.osei-safo@st.ug.edu.gh	0244000103	2004-01-03	Female	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
4	22397756	Agbemavi	Ryan	agbemavi.ryan@st.ug.edu.gh	0244000104	2004-01-04	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
5	22369321	Agormeda Nathaniel	Tetteh	agormeda.nathaniel@st.ug.edu.gh	0244000105	2004-01-05	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
6	22301848	Ahmad Mohammed Sahih	Kayelgu	ahmad.kayelgu@st.ug.edu.gh	0244000106	2004-01-06	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
7	22339520	Amprofi Yaa	Obeng	amprofi.yaa@st.ug.edu.gh	0244000107	2004-01-07	Female	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
8	22333597	Asante Esme	Lilian	asante.esme@st.ug.edu.gh	0244000108	2004-01-08	Female	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
9	22268986	Asante Gabriel	Kwaku	asante.gabriel@st.ug.edu.gh	0244000109	2004-01-09	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
10	22381577	Botchway	Daniel	botchway.daniel@st.ug.edu.gh	0244000110	2004-01-10	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
11	22315830	Brian	Assibey-Yeboah	brian.assibey@st.ug.edu.gh	0244000111	2004-01-11	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
12	22388189	Caleb	Mensah	caleb.mensah@st.ug.edu.gh	0244000112	2004-01-12	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
13	22393520	Cyril Desmond	Ofori	cyril.ofori@st.ug.edu.gh	0244000113	2004-01-13	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
14	22312110	David Kwame	Odoi-Anim	david.odoi-anim@st.ug.edu.gh	0244000114	2004-01-14	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
15	22300896	Doe Collins	Kweku	doe.collins@st.ug.edu.gh	0244000115	2004-01-15	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
16	22397491	Douglas Kwaw	Adjei	douglas.adjei@st.ug.edu.gh	0244000116	2004-01-16	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
17	22387715	Dzidzor Apu	Apawudza	dzidzor.apawudza@st.ug.edu.gh	0244000117	2004-01-17	Female	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
18	22382302	Edward Kakra	Ankrah	edward.ankrah@st.ug.edu.gh	0244000118	2004-01-18	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
19	22379061	Emmanuel Akotuah	Osae	emmanuel.osae@st.ug.edu.gh	0244000119	2004-01-19	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
20	22368809	Emmanuel	Dery	emmanuel.dery@st.ug.edu.gh	0244000120	2004-01-20	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
21	22370498	Ethan Edric Kweku	Nartey	ethan.nartey@st.ug.edu.gh	0244000121	2004-01-21	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
22	22382425	Gilbert Akwasi Sarkodie	Yeboah	gilbert.yeboah@st.ug.edu.gh	0244000122	2004-01-22	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
23	22396551	Jerrold Xornam	Kyekye	jerrold.kyekye@st.ug.edu.gh	0244000123	2004-01-23	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
24	22398562	Joseph	Amankwah	joseph.amankwah@st.ug.edu.gh	0244000124	2004-01-24	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
25	22398596	Joshua	Appiah	joshua.appiah@st.ug.edu.gh	0244000125	2004-01-25	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
26	22385323	Jude Gyampoh	Addo	jude.addo@st.ug.edu.gh	0244000126	2004-01-26	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
27	22303421	Kemausuor Winambe	Tetteh-Kumah	kemausuor.tetteh@st.ug.edu.gh	0244000127	2004-01-27	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
28	22407033	Kenzi	Segbefia	kenzi.segbefia@st.ug.edu.gh	0244000128	2004-01-28	Female	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
29	22299189	Kessey Ntiako	David	kessey.david@st.ug.edu.gh	0244000129	2004-01-29	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
30	22407837	Kingsley Caldicock	Quartey	kingsley.quartey@st.ug.edu.gh	0244000130	2004-01-30	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
31	22412615	Kofi Boateng	Oware-Tano	kofi.oware-tano@st.ug.edu.gh	0244000131	2004-02-01	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
32	22411009	Kwaku Aninkorah	Barimah	kwaku.barimah@st.ug.edu.gh	0244000132	2004-02-02	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
33	22382547	Kwame Ayeh	Obeng	kwame.obeng@st.ug.edu.gh	0244000133	2004-02-03	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
34	22373317	Kwamena Kesse	Quaicoe	kwamena.quaicoe@st.ug.edu.gh	0244000134	2004-02-04	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
35	22339058	Maame Abena Amihere	Ahu	maame.ahu@st.ug.edu.gh	0244000135	2004-02-05	Female	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
36	22302628	Maame Araba	Grant-Aidoo	maame.grant-aidoo@st.ug.edu.gh	0244000136	2004-02-06	Female	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
37	22396566	Manford Kelvin	Oppong	manford.oppong@st.ug.edu.gh	0244000137	2004-02-07	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
38	22325819	Nana Adwoa Dansowaah	Odoom	nana.odoom@st.ug.edu.gh	0244000138	2004-02-08	Female	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
39	22344703	Nana	Anokye	nana.anokye@st.ug.edu.gh	0244000139	2004-02-09	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
40	22306910	Newlove Yeboaah	Kwarfo	newlove.kwarfo@st.ug.edu.gh	0244000140	2004-02-10	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
41	22385472	Obeng Ernest	Antwi	obeng.ernest@st.ug.edu.gh	0244000141	2004-02-11	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
42	22399214	Obeng	Ruth	obeng.ruth@st.ug.edu.gh	0244000142	2004-02-12	Female	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
43	22263126	Owusu Koranteng Yaw	Poku	owusu.koranteng@st.ug.edu.gh	0244000143	2004-02-13	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
44	22373463	Owusu Nana	Boadiwaa	owusu.boadiwaa@st.ug.edu.gh	0244000144	2004-02-14	Female	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
45	22381702	Paula Akosua Asiedua	Frimpong	paula.frimpong@st.ug.edu.gh	0244000145	2004-02-15	Female	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
46	22387846	Quaicoo	Emile	quaicoo.emile@st.ug.edu.gh	0244000146	2004-02-16	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
47	22263922	Romel Alvin Nii Lartey	Lartey	romel.lartey@st.ug.edu.gh	0244000147	2004-02-17	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
48	22401641	Sandra Naa Adaku	Mettle	sandra.mettle@st.ug.edu.gh	0244000148	2004-02-18	Female	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
49	22403781	Sekyere Kofi	Bempong	sekyere.bempong@st.ug.edu.gh	0244000149	2004-02-19	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
50	22304260	Tetteh Christian Edward Nii	Mantey	tetteh.christian@st.ug.edu.gh	0244000150	2004-02-20	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
51	22304013	Tietaah	Sonnu	tietaah.sonnu@st.ug.edu.gh	0244000151	2004-02-21	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
52	22302188	Van Jerry	Quansah	van.quansah@st.ug.edu.gh	0244000152	2004-02-22	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
53	22299949	William	Enchill	william.enchill@st.ug.edu.gh	0244000153	2004-02-23	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
54	22415339	Kelvin Kwesi	Saah	kelvin.saah@st.ug.edu.gh	0244000154	2004-02-24	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
55	22328334	Etsey Hannah	Seyram	etsey.hannah@st.ug.edu.gh	0244000155	2004-02-25	Female	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
56	22412982	Adu	Mini	adu.mini@st.ug.edu.gh	0244000156	2004-02-26	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
57	22321110	Gideon Nana Osei	Amofa	gideon.amofa@st.ug.edu.gh	0244000157	2004-02-27	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
58	22306021	Paul Badu	Amponsah	paul.amponsah@st.ug.edu.gh	0244000158	2004-02-28	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
59	22385391	Najiib Abdul-Majeed	Stephen	najiib.stephen@st.ug.edu.gh	0244000159	2004-02-29	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
60	22394866	Joshua Kwame	Asirifi	joshua.asirifi@st.ug.edu.gh	0244000160	2004-03-01	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
61	22382601	Eklou	Juliet	eklou.juliet@st.ug.edu.gh	0244000161	2004-03-02	Female	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
62	22271867	De-Andra Rebecca	Ayebo	de-andra.ayebo@st.ug.edu.gh	0244000162	2004-03-03	Female	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
63	224018189	Mas'ud	Nasir	masud.nasir@st.ug.edu.gh	0244000163	2004-03-04	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
64	22407018	Daniel Dwomoh	Frimpong	daniel.frimpong@st.ug.edu.gh	0244000164	2004-03-05	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
65	22376708	Adjei	Priscilla	adjei.priscilla@st.ug.edu.gh	0244000165	2004-03-06	Female	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
66	22377537	Reuben	Adomako	reuben.adomako@st.ug.edu.gh	0244000166	2004-03-07	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
67	22400543	Ocansey	Frederick	ocansey.frederick@st.ug.edu.gh	0244000167	2004-03-08	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
68	22402666	Dogbatse	Darlington	dogbatse.darlington@st.ug.edu.gh	0244000168	2004-03-09	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
69	22416112	Troy	Thomas	troy.thomas@st.ug.edu.gh	0244000169	2004-03-10	Male	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
70	22395074	Lydia	Tiwaah	lydia.tiwaah@st.ug.edu.gh	0244000170	2004-03-11	Female	BSc. Computer Engineering	200	2024	Legon Hall	2026-07-25 19:52:09.585363
\.


--
-- Data for Name: ta_course_assignments; Type: TABLE DATA; Schema: academics; Owner: postgres
--

COPY academics.ta_course_assignments (assignment_id, ta_id, lecturer_id, course_id, academic_year, semester) FROM stdin;
1	1	1	2	2025/2026	First Semester
2	2	2	4	2025/2026	First Semester
3	3	3	1	2025/2026	First Semester
4	4	4	3	2025/2026	First Semester
\.


--
-- Data for Name: teaching_assistants; Type: TABLE DATA; Schema: academics; Owner: postgres
--

COPY academics.teaching_assistants (ta_id, first_name, last_name, email, phone, supervising_lecturer_id, appointment_date, department) FROM stdin;
1	Michael	Asare	michael.asare@ug.edu.gh	0245000001	1	2025-08-15	Computer Engineering
2	Jessica	Mensah	jessica.mensah@ug.edu.gh	0245000002	2	2025-08-15	Computer Engineering
3	David	Owusu	david.owusu@ug.edu.gh	0245000003	3	2025-08-15	Computer Engineering
4	Sarah	Adjei	sarah.adjei@ug.edu.gh	0245000004	4	2025-08-15	Computer Engineering
\.


--
-- Name: app_users_user_id_seq; Type: SEQUENCE SET; Schema: academics; Owner: postgres
--

SELECT pg_catalog.setval('academics.app_users_user_id_seq', 103, true);


--
-- Name: courses_course_id_seq; Type: SEQUENCE SET; Schema: academics; Owner: postgres
--

SELECT pg_catalog.setval('academics.courses_course_id_seq', 33, true);


--
-- Name: enrollments_enrollment_id_seq; Type: SEQUENCE SET; Schema: academics; Owner: postgres
--

SELECT pg_catalog.setval('academics.enrollments_enrollment_id_seq', 297, true);


--
-- Name: fee_payments_payment_id_seq; Type: SEQUENCE SET; Schema: academics; Owner: postgres
--

SELECT pg_catalog.setval('academics.fee_payments_payment_id_seq', 33, true);


--
-- Name: fee_structure_fee_structure_id_seq; Type: SEQUENCE SET; Schema: academics; Owner: postgres
--

SELECT pg_catalog.setval('academics.fee_structure_fee_structure_id_seq', 33, true);


--
-- Name: lecturer_course_assignments_assignment_id_seq; Type: SEQUENCE SET; Schema: academics; Owner: postgres
--

SELECT pg_catalog.setval('academics.lecturer_course_assignments_assignment_id_seq', 33, true);


--
-- Name: lecturers_lecturer_id_seq; Type: SEQUENCE SET; Schema: academics; Owner: postgres
--

SELECT pg_catalog.setval('academics.lecturers_lecturer_id_seq', 33, true);


--
-- Name: students_student_id_seq; Type: SEQUENCE SET; Schema: academics; Owner: postgres
--

SELECT pg_catalog.setval('academics.students_student_id_seq', 99, true);


--
-- Name: ta_course_assignments_assignment_id_seq; Type: SEQUENCE SET; Schema: academics; Owner: postgres
--

SELECT pg_catalog.setval('academics.ta_course_assignments_assignment_id_seq', 33, true);


--
-- Name: teaching_assistants_ta_id_seq; Type: SEQUENCE SET; Schema: academics; Owner: postgres
--

SELECT pg_catalog.setval('academics.teaching_assistants_ta_id_seq', 33, true);


--
-- Name: app_users app_users_email_key; Type: CONSTRAINT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.app_users
    ADD CONSTRAINT app_users_email_key UNIQUE (email);


--
-- Name: app_users app_users_lecturer_id_key; Type: CONSTRAINT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.app_users
    ADD CONSTRAINT app_users_lecturer_id_key UNIQUE (lecturer_id);


--
-- Name: app_users app_users_pkey; Type: CONSTRAINT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.app_users
    ADD CONSTRAINT app_users_pkey PRIMARY KEY (user_id);


--
-- Name: app_users app_users_student_id_key; Type: CONSTRAINT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.app_users
    ADD CONSTRAINT app_users_student_id_key UNIQUE (student_id);


--
-- Name: courses courses_course_code_key; Type: CONSTRAINT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.courses
    ADD CONSTRAINT courses_course_code_key UNIQUE (course_code);


--
-- Name: courses courses_pkey; Type: CONSTRAINT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.courses
    ADD CONSTRAINT courses_pkey PRIMARY KEY (course_id);


--
-- Name: enrollments enrollments_pkey; Type: CONSTRAINT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.enrollments
    ADD CONSTRAINT enrollments_pkey PRIMARY KEY (enrollment_id);


--
-- Name: enrollments enrollments_student_id_course_id_academic_year_semester_key; Type: CONSTRAINT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.enrollments
    ADD CONSTRAINT enrollments_student_id_course_id_academic_year_semester_key UNIQUE (student_id, course_id, academic_year, semester);


--
-- Name: fee_payments fee_payments_pkey; Type: CONSTRAINT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.fee_payments
    ADD CONSTRAINT fee_payments_pkey PRIMARY KEY (payment_id);


--
-- Name: fee_payments fee_payments_reference_number_key; Type: CONSTRAINT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.fee_payments
    ADD CONSTRAINT fee_payments_reference_number_key UNIQUE (reference_number);


--
-- Name: fee_structure fee_structure_pkey; Type: CONSTRAINT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.fee_structure
    ADD CONSTRAINT fee_structure_pkey PRIMARY KEY (fee_structure_id);


--
-- Name: fee_structure fee_structure_program_level_academic_year_semester_key; Type: CONSTRAINT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.fee_structure
    ADD CONSTRAINT fee_structure_program_level_academic_year_semester_key UNIQUE (program, level, academic_year, semester);


--
-- Name: lecturer_course_assignments lecturer_course_assignments_course_id_academic_year_semeste_key; Type: CONSTRAINT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.lecturer_course_assignments
    ADD CONSTRAINT lecturer_course_assignments_course_id_academic_year_semeste_key UNIQUE (course_id, academic_year, semester, lecturer_id);


--
-- Name: lecturer_course_assignments lecturer_course_assignments_pkey; Type: CONSTRAINT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.lecturer_course_assignments
    ADD CONSTRAINT lecturer_course_assignments_pkey PRIMARY KEY (assignment_id);


--
-- Name: lecturers lecturers_email_key; Type: CONSTRAINT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.lecturers
    ADD CONSTRAINT lecturers_email_key UNIQUE (email);


--
-- Name: lecturers lecturers_pkey; Type: CONSTRAINT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.lecturers
    ADD CONSTRAINT lecturers_pkey PRIMARY KEY (lecturer_id);


--
-- Name: lecturers lecturers_staff_id_key; Type: CONSTRAINT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.lecturers
    ADD CONSTRAINT lecturers_staff_id_key UNIQUE (staff_id);


--
-- Name: students students_email_key; Type: CONSTRAINT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.students
    ADD CONSTRAINT students_email_key UNIQUE (email);


--
-- Name: students students_index_number_key; Type: CONSTRAINT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.students
    ADD CONSTRAINT students_index_number_key UNIQUE (index_number);


--
-- Name: students students_pkey; Type: CONSTRAINT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (student_id);


--
-- Name: ta_course_assignments ta_course_assignments_pkey; Type: CONSTRAINT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.ta_course_assignments
    ADD CONSTRAINT ta_course_assignments_pkey PRIMARY KEY (assignment_id);


--
-- Name: ta_course_assignments ta_course_assignments_ta_id_course_id_academic_year_semeste_key; Type: CONSTRAINT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.ta_course_assignments
    ADD CONSTRAINT ta_course_assignments_ta_id_course_id_academic_year_semeste_key UNIQUE (ta_id, course_id, academic_year, semester);


--
-- Name: teaching_assistants teaching_assistants_email_key; Type: CONSTRAINT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.teaching_assistants
    ADD CONSTRAINT teaching_assistants_email_key UNIQUE (email);


--
-- Name: teaching_assistants teaching_assistants_pkey; Type: CONSTRAINT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.teaching_assistants
    ADD CONSTRAINT teaching_assistants_pkey PRIMARY KEY (ta_id);


--
-- Name: idx_enrollments_course; Type: INDEX; Schema: academics; Owner: postgres
--

CREATE INDEX idx_enrollments_course ON academics.enrollments USING btree (course_id);


--
-- Name: idx_enrollments_student; Type: INDEX; Schema: academics; Owner: postgres
--

CREATE INDEX idx_enrollments_student ON academics.enrollments USING btree (student_id);


--
-- Name: idx_fee_payments_student; Type: INDEX; Schema: academics; Owner: postgres
--

CREATE INDEX idx_fee_payments_student ON academics.fee_payments USING btree (student_id);


--
-- Name: idx_lecturer_course_lecturer; Type: INDEX; Schema: academics; Owner: postgres
--

CREATE INDEX idx_lecturer_course_lecturer ON academics.lecturer_course_assignments USING btree (lecturer_id);


--
-- Name: idx_ta_course_ta; Type: INDEX; Schema: academics; Owner: postgres
--

CREATE INDEX idx_ta_course_ta ON academics.ta_course_assignments USING btree (ta_id);


--
-- Name: app_users app_users_lecturer_id_fkey; Type: FK CONSTRAINT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.app_users
    ADD CONSTRAINT app_users_lecturer_id_fkey FOREIGN KEY (lecturer_id) REFERENCES academics.lecturers(lecturer_id) ON DELETE CASCADE;


--
-- Name: app_users app_users_student_id_fkey; Type: FK CONSTRAINT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.app_users
    ADD CONSTRAINT app_users_student_id_fkey FOREIGN KEY (student_id) REFERENCES academics.students(student_id) ON DELETE CASCADE;


--
-- Name: enrollments enrollments_course_id_fkey; Type: FK CONSTRAINT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.enrollments
    ADD CONSTRAINT enrollments_course_id_fkey FOREIGN KEY (course_id) REFERENCES academics.courses(course_id) ON DELETE CASCADE;


--
-- Name: enrollments enrollments_student_id_fkey; Type: FK CONSTRAINT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.enrollments
    ADD CONSTRAINT enrollments_student_id_fkey FOREIGN KEY (student_id) REFERENCES academics.students(student_id) ON DELETE CASCADE;


--
-- Name: fee_payments fee_payments_student_id_fkey; Type: FK CONSTRAINT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.fee_payments
    ADD CONSTRAINT fee_payments_student_id_fkey FOREIGN KEY (student_id) REFERENCES academics.students(student_id) ON DELETE CASCADE;


--
-- Name: lecturer_course_assignments lecturer_course_assignments_course_id_fkey; Type: FK CONSTRAINT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.lecturer_course_assignments
    ADD CONSTRAINT lecturer_course_assignments_course_id_fkey FOREIGN KEY (course_id) REFERENCES academics.courses(course_id) ON DELETE CASCADE;


--
-- Name: lecturer_course_assignments lecturer_course_assignments_lecturer_id_fkey; Type: FK CONSTRAINT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.lecturer_course_assignments
    ADD CONSTRAINT lecturer_course_assignments_lecturer_id_fkey FOREIGN KEY (lecturer_id) REFERENCES academics.lecturers(lecturer_id) ON DELETE CASCADE;


--
-- Name: ta_course_assignments ta_course_assignments_course_id_fkey; Type: FK CONSTRAINT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.ta_course_assignments
    ADD CONSTRAINT ta_course_assignments_course_id_fkey FOREIGN KEY (course_id) REFERENCES academics.courses(course_id) ON DELETE CASCADE;


--
-- Name: ta_course_assignments ta_course_assignments_lecturer_id_fkey; Type: FK CONSTRAINT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.ta_course_assignments
    ADD CONSTRAINT ta_course_assignments_lecturer_id_fkey FOREIGN KEY (lecturer_id) REFERENCES academics.lecturers(lecturer_id) ON DELETE CASCADE;


--
-- Name: ta_course_assignments ta_course_assignments_ta_id_fkey; Type: FK CONSTRAINT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.ta_course_assignments
    ADD CONSTRAINT ta_course_assignments_ta_id_fkey FOREIGN KEY (ta_id) REFERENCES academics.teaching_assistants(ta_id) ON DELETE CASCADE;


--
-- Name: teaching_assistants teaching_assistants_supervising_lecturer_id_fkey; Type: FK CONSTRAINT; Schema: academics; Owner: postgres
--

ALTER TABLE ONLY academics.teaching_assistants
    ADD CONSTRAINT teaching_assistants_supervising_lecturer_id_fkey FOREIGN KEY (supervising_lecturer_id) REFERENCES academics.lecturers(lecturer_id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

\unrestrict ZTVmxEn2038xPcyFApO2mVZCuwHHCkVOT055uRfgk87aaYNerfchcHyYgcCCH4I

