-- =====================================================================
-- CPEN 208 Project 1 — Sample Data
-- File: 02_seed_data.sql
-- Sample data models a Computer Engineering Level 200 class at the
-- University of Ghana taking courses from the 2025/2026 First Semester
-- course list (CPEN 204, CPEN 206, CPEN 208, CPEN 212), consistent with
-- the department's own curriculum.
-- =====================================================================

SET search_path TO academics, public;

-- ---------------------------------------------------------------------
-- STUDENTS  (Level 200, BSc. Computer Engineering, admitted 2024)
-- 70 students from the list
-- ---------------------------------------------------------------------
INSERT INTO students (index_number, first_name, last_name, email, phone, date_of_birth, gender, program, level, year_of_admission, hall_of_residence) VALUES
('22384451', 'Abu Neaquittae', 'Golda', 'abu.golda@st.ug.edu.gh', '0244000101', '2004-01-01', 'Female', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22357814', 'Adzasa Stephen', 'Yaw', 'adzasa.stephen@st.ug.edu.gh', '0244000102', '2004-01-02', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22375367', 'Afia Beaa', 'Osei-Safo', 'afia.osei-safo@st.ug.edu.gh', '0244000103', '2004-01-03', 'Female', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22397756', 'Agbemavi', 'Ryan', 'agbemavi.ryan@st.ug.edu.gh', '0244000104', '2004-01-04', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22369321', 'Agormeda Nathaniel', 'Tetteh', 'agormeda.nathaniel@st.ug.edu.gh', '0244000105', '2004-01-05', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22301848', 'Ahmad Mohammed Sahih', 'Kayelgu', 'ahmad.kayelgu@st.ug.edu.gh', '0244000106', '2004-01-06', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22339520', 'Amprofi Yaa', 'Obeng', 'amprofi.yaa@st.ug.edu.gh', '0244000107', '2004-01-07', 'Female', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22333597', 'Asante Esme', 'Lilian', 'asante.esme@st.ug.edu.gh', '0244000108', '2004-01-08', 'Female', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22268986', 'Asante Gabriel', 'Kwaku', 'asante.gabriel@st.ug.edu.gh', '0244000109', '2004-01-09', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22381577', 'Botchway', 'Daniel', 'botchway.daniel@st.ug.edu.gh', '0244000110', '2004-01-10', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22315830', 'Brian', 'Assibey-Yeboah', 'brian.assibey@st.ug.edu.gh', '0244000111', '2004-01-11', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22388189', 'Caleb', 'Mensah', 'caleb.mensah@st.ug.edu.gh', '0244000112', '2004-01-12', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22393520', 'Cyril Desmond', 'Ofori', 'cyril.ofori@st.ug.edu.gh', '0244000113', '2004-01-13', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22312110', 'David Kwame', 'Odoi-Anim', 'david.odoi-anim@st.ug.edu.gh', '0244000114', '2004-01-14', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22300896', 'Doe Collins', 'Kweku', 'doe.collins@st.ug.edu.gh', '0244000115', '2004-01-15', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22397491', 'Douglas Kwaw', 'Adjei', 'douglas.adjei@st.ug.edu.gh', '0244000116', '2004-01-16', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22387715', 'Dzidzor Apu', 'Apawudza', 'dzidzor.apawudza@st.ug.edu.gh', '0244000117', '2004-01-17', 'Female', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22382302', 'Edward Kakra', 'Ankrah', 'edward.ankrah@st.ug.edu.gh', '0244000118', '2004-01-18', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22379061', 'Emmanuel Akotuah', 'Osae', 'emmanuel.osae@st.ug.edu.gh', '0244000119', '2004-01-19', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22368809', 'Emmanuel', 'Dery', 'emmanuel.dery@st.ug.edu.gh', '0244000120', '2004-01-20', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22370498', 'Ethan Edric Kweku', 'Nartey', 'ethan.nartey@st.ug.edu.gh', '0244000121', '2004-01-21', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22382425', 'Gilbert Akwasi Sarkodie', 'Yeboah', 'gilbert.yeboah@st.ug.edu.gh', '0244000122', '2004-01-22', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22396551', 'Jerrold Xornam', 'Kyekye', 'jerrold.kyekye@st.ug.edu.gh', '0244000123', '2004-01-23', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22398562', 'Joseph', 'Amankwah', 'joseph.amankwah@st.ug.edu.gh', '0244000124', '2004-01-24', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22398596', 'Joshua', 'Appiah', 'joshua.appiah@st.ug.edu.gh', '0244000125', '2004-01-25', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22385323', 'Jude Gyampoh', 'Addo', 'jude.addo@st.ug.edu.gh', '0244000126', '2004-01-26', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22303421', 'Kemausuor Winambe', 'Tetteh-Kumah', 'kemausuor.tetteh@st.ug.edu.gh', '0244000127', '2004-01-27', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22407033', 'Kenzi', 'Segbefia', 'kenzi.segbefia@st.ug.edu.gh', '0244000128', '2004-01-28', 'Female', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22299189', 'Kessey Ntiako', 'David', 'kessey.david@st.ug.edu.gh', '0244000129', '2004-01-29', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22407837', 'Kingsley Caldicock', 'Quartey', 'kingsley.quartey@st.ug.edu.gh', '0244000130', '2004-01-30', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22412615', 'Kofi Boateng', 'Oware-Tano', 'kofi.oware-tano@st.ug.edu.gh', '0244000131', '2004-02-01', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22411009', 'Kwaku Aninkorah', 'Barimah', 'kwaku.barimah@st.ug.edu.gh', '0244000132', '2004-02-02', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22382547', 'Kwame Ayeh', 'Obeng', 'kwame.obeng@st.ug.edu.gh', '0244000133', '2004-02-03', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22373317', 'Kwamena Kesse', 'Quaicoe', 'kwamena.quaicoe@st.ug.edu.gh', '0244000134', '2004-02-04', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22339058', 'Maame Abena Amihere', 'Ahu', 'maame.ahu@st.ug.edu.gh', '0244000135', '2004-02-05', 'Female', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22302628', 'Maame Araba', 'Grant-Aidoo', 'maame.grant-aidoo@st.ug.edu.gh', '0244000136', '2004-02-06', 'Female', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22396566', 'Manford Kelvin', 'Oppong', 'manford.oppong@st.ug.edu.gh', '0244000137', '2004-02-07', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22325819', 'Nana Adwoa Dansowaah', 'Odoom', 'nana.odoom@st.ug.edu.gh', '0244000138', '2004-02-08', 'Female', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22344703', 'Nana', 'Anokye', 'nana.anokye@st.ug.edu.gh', '0244000139', '2004-02-09', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22306910', 'Newlove Yeboaah', 'Kwarfo', 'newlove.kwarfo@st.ug.edu.gh', '0244000140', '2004-02-10', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22385472', 'Obeng Ernest', 'Antwi', 'obeng.ernest@st.ug.edu.gh', '0244000141', '2004-02-11', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22399214', 'Obeng', 'Ruth', 'obeng.ruth@st.ug.edu.gh', '0244000142', '2004-02-12', 'Female', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22263126', 'Owusu Koranteng Yaw', 'Poku', 'owusu.koranteng@st.ug.edu.gh', '0244000143', '2004-02-13', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22373463', 'Owusu Nana', 'Boadiwaa', 'owusu.boadiwaa@st.ug.edu.gh', '0244000144', '2004-02-14', 'Female', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22381702', 'Paula Akosua Asiedua', 'Frimpong', 'paula.frimpong@st.ug.edu.gh', '0244000145', '2004-02-15', 'Female', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22387846', 'Quaicoo', 'Emile', 'quaicoo.emile@st.ug.edu.gh', '0244000146', '2004-02-16', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22263922', 'Romel Alvin Nii Lartey', 'Lartey', 'romel.lartey@st.ug.edu.gh', '0244000147', '2004-02-17', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22401641', 'Sandra Naa Adaku', 'Mettle', 'sandra.mettle@st.ug.edu.gh', '0244000148', '2004-02-18', 'Female', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22403781', 'Sekyere Kofi', 'Bempong', 'sekyere.bempong@st.ug.edu.gh', '0244000149', '2004-02-19', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22304260', 'Tetteh Christian Edward Nii', 'Mantey', 'tetteh.christian@st.ug.edu.gh', '0244000150', '2004-02-20', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22304013', 'Tietaah', 'Sonnu', 'tietaah.sonnu@st.ug.edu.gh', '0244000151', '2004-02-21', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22302188', 'Van Jerry', 'Quansah', 'van.quansah@st.ug.edu.gh', '0244000152', '2004-02-22', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22299949', 'William', 'Enchill', 'william.enchill@st.ug.edu.gh', '0244000153', '2004-02-23', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22415339', 'Kelvin Kwesi', 'Saah', 'kelvin.saah@st.ug.edu.gh', '0244000154', '2004-02-24', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22328334', 'Etsey Hannah', 'Seyram', 'etsey.hannah@st.ug.edu.gh', '0244000155', '2004-02-25', 'Female', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22412982', 'Adu', 'Mini', 'adu.mini@st.ug.edu.gh', '0244000156', '2004-02-26', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22321110', 'Gideon Nana Osei', 'Amofa', 'gideon.amofa@st.ug.edu.gh', '0244000157', '2004-02-27', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22306021', 'Paul Badu', 'Amponsah', 'paul.amponsah@st.ug.edu.gh', '0244000158', '2004-02-28', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22385391', 'Najiib Abdul-Majeed', 'Stephen', 'najiib.stephen@st.ug.edu.gh', '0244000159', '2004-02-29', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22394866', 'Joshua Kwame', 'Asirifi', 'joshua.asirifi@st.ug.edu.gh', '0244000160', '2004-03-01', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22382601', 'Eklou', 'Juliet', 'eklou.juliet@st.ug.edu.gh', '0244000161', '2004-03-02', 'Female', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22271867', 'De-Andra Rebecca', 'Ayebo', 'de-andra.ayebo@st.ug.edu.gh', '0244000162', '2004-03-03', 'Female', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('224018189', 'Mas''ud', 'Nasir', 'masud.nasir@st.ug.edu.gh', '0244000163', '2004-03-04', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22407018', 'Daniel Dwomoh', 'Frimpong', 'daniel.frimpong@st.ug.edu.gh', '0244000164', '2004-03-05', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22376708', 'Adjei', 'Priscilla', 'adjei.priscilla@st.ug.edu.gh', '0244000165', '2004-03-06', 'Female', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22377537', 'Reuben', 'Adomako', 'reuben.adomako@st.ug.edu.gh', '0244000166', '2004-03-07', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22400543', 'Ocansey', 'Frederick', 'ocansey.frederick@st.ug.edu.gh', '0244000167', '2004-03-08', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22402666', 'Dogbatse', 'Darlington', 'dogbatse.darlington@st.ug.edu.gh', '0244000168', '2004-03-09', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22416112', 'Troy', 'Thomas', 'troy.thomas@st.ug.edu.gh', '0244000169', '2004-03-10', 'Male', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall'),
('22395074', 'Lydia', 'Tiwaah', 'lydia.tiwaah@st.ug.edu.gh', '0244000170', '2004-03-11', 'Female', 'BSc. Computer Engineering', 200, 2024, 'Legon Hall')
ON CONFLICT (index_number) DO NOTHING;

-- ---------------------------------------------------------------------
-- LECTURERS
-- ---------------------------------------------------------------------
INSERT INTO lecturers (staff_id, first_name, last_name, email, phone, department, academic_rank, office_location) VALUES
('UG-L001', 'Kwame',   'Anokye',   'kwame.anokye@ug.edu.gh',   '0208000001', 'Computer Engineering', 'Senior Lecturer', 'CBAS Block A, Rm 12'),
('UG-L002', 'Grace',   'Adjei',    'grace.adjei@ug.edu.gh',    '0208000002', 'Computer Engineering', 'Lecturer',        'CBAS Block A, Rm 15'),
('UG-L003', 'Samuel',  'Tetteh',   'samuel.tetteh@ug.edu.gh',  '0208000003', 'Computer Engineering', 'Associate Professor', 'CBAS Block B, Rm 3'),
('UG-L004', 'Comfort', 'Nkrumah',  'comfort.nkrumah@ug.edu.gh','0208000004', 'Computer Engineering', 'Lecturer',        'CBAS Block A, Rm 9');

-- ---------------------------------------------------------------------
-- TEACHING ASSISTANTS (4 distinct TAs with their own names)
-- ---------------------------------------------------------------------
INSERT INTO teaching_assistants (first_name, last_name, email, phone, supervising_lecturer_id, appointment_date, department) VALUES
('Michael', 'Asare', 'michael.asare@ug.edu.gh', '0245000001', 
    (SELECT lecturer_id FROM lecturers WHERE staff_id = 'UG-L001'), 
    '2025-08-15', 'Computer Engineering'),
('Jessica', 'Mensah', 'jessica.mensah@ug.edu.gh', '0245000002', 
    (SELECT lecturer_id FROM lecturers WHERE staff_id = 'UG-L002'), 
    '2025-08-15', 'Computer Engineering'),
('David', 'Owusu', 'david.owusu@ug.edu.gh', '0245000003', 
    (SELECT lecturer_id FROM lecturers WHERE staff_id = 'UG-L003'), 
    '2025-08-15', 'Computer Engineering'),
('Sarah', 'Adjei', 'sarah.adjei@ug.edu.gh', '0245000004', 
    (SELECT lecturer_id FROM lecturers WHERE staff_id = 'UG-L004'), 
    '2025-08-15', 'Computer Engineering');

-- ---------------------------------------------------------------------
-- COURSES  (matches the CPEN 200-level curriculum)
-- ---------------------------------------------------------------------
INSERT INTO courses (course_code, course_title, credit_hours, department, level) VALUES
('CPEN 204', 'Algorithms and Computation',        3, 'Computer Engineering', 200),
('CPEN 206', 'Linear Circuits',                    3, 'Computer Engineering', 200),
('CPEN 208', 'Introduction to Software Engineering', 3, 'Computer Engineering', 200),
('CPEN 212', 'Data Communications',                 3, 'Computer Engineering', 200);

-- ---------------------------------------------------------------------
-- LECTURER TO COURSE ASSIGNMENT (2025/2026, First Semester)
-- ---------------------------------------------------------------------
INSERT INTO lecturer_course_assignments (lecturer_id, course_id, academic_year, semester)
SELECT l.lecturer_id, c.course_id, '2025/2026', 'First Semester'
FROM lecturers l, courses c
WHERE (l.staff_id = 'UG-L003' AND c.course_code = 'CPEN 204')
   OR (l.staff_id = 'UG-L001' AND c.course_code = 'CPEN 206')
   OR (l.staff_id = 'UG-L004' AND c.course_code = 'CPEN 208')
   OR (l.staff_id = 'UG-L002' AND c.course_code = 'CPEN 212');

-- ---------------------------------------------------------------------
-- LECTURER TO TA ASSIGNMENT (TAs paired to a lecturer for a course)
-- ---------------------------------------------------------------------
INSERT INTO ta_course_assignments (ta_id, lecturer_id, course_id, academic_year, semester)
SELECT ta.ta_id, l.lecturer_id, c.course_id, '2025/2026', 'First Semester'
FROM teaching_assistants ta
JOIN lecturers l ON l.staff_id = 'UG-L001'
JOIN courses c ON c.course_code = 'CPEN 206'
WHERE ta.email = 'michael.asare@ug.edu.gh';

INSERT INTO ta_course_assignments (ta_id, lecturer_id, course_id, academic_year, semester)
SELECT ta.ta_id, l.lecturer_id, c.course_id, '2025/2026', 'First Semester'
FROM teaching_assistants ta
JOIN lecturers l ON l.staff_id = 'UG-L002'
JOIN courses c ON c.course_code = 'CPEN 212'
WHERE ta.email = 'jessica.mensah@ug.edu.gh';

INSERT INTO ta_course_assignments (ta_id, lecturer_id, course_id, academic_year, semester)
SELECT ta.ta_id, l.lecturer_id, c.course_id, '2025/2026', 'First Semester'
FROM teaching_assistants ta
JOIN lecturers l ON l.staff_id = 'UG-L003'
JOIN courses c ON c.course_code = 'CPEN 204'
WHERE ta.email = 'david.owusu@ug.edu.gh';

INSERT INTO ta_course_assignments (ta_id, lecturer_id, course_id, academic_year, semester)
SELECT ta.ta_id, l.lecturer_id, c.course_id, '2025/2026', 'First Semester'
FROM teaching_assistants ta
JOIN lecturers l ON l.staff_id = 'UG-L004'
JOIN courses c ON c.course_code = 'CPEN 208'
WHERE ta.email = 'sarah.adjei@ug.edu.gh';

-- ---------------------------------------------------------------------
-- COURSE ENROLLMENT — all Level 200 students enroll in all 4 courses
-- ---------------------------------------------------------------------
INSERT INTO enrollments (student_id, course_id, academic_year, semester)
SELECT s.student_id, c.course_id, '2025/2026', 'First Semester'
FROM students s
CROSS JOIN courses c
WHERE s.level = 200;

-- ---------------------------------------------------------------------
-- FEE STRUCTURE (amount billed per level per semester)
-- ---------------------------------------------------------------------
INSERT INTO fee_structure (program, level, academic_year, semester, amount_billed) VALUES
('BSc. Computer Engineering', 200, '2025/2026', 'First Semester', 3500.00);

-- ---------------------------------------------------------------------
-- FEE PAYMENTS — some students have paid, some haven't
-- ---------------------------------------------------------------------
INSERT INTO fee_payments (student_id, academic_year, semester, amount_paid, payment_date, payment_method, reference_number)
SELECT student_id, '2025/2026', 'First Semester', 3500.00, '2025-09-05', 'Mobile Money', 'MM-2025-0001'
FROM students WHERE index_number = '22384451'; -- Golda: fully paid

INSERT INTO fee_payments (student_id, academic_year, semester, amount_paid, payment_date, payment_method, reference_number)
SELECT student_id, '2025/2026', 'First Semester', 2000.00, '2025-09-10', 'Bank Transfer', 'BT-2025-0002'
FROM students WHERE index_number = '22357814'; -- Yaw: partial

INSERT INTO fee_payments (student_id, academic_year, semester, amount_paid, payment_date, payment_method, reference_number)
SELECT student_id, '2025/2026', 'First Semester', 1500.00, '2025-09-12', 'Mobile Money', 'MM-2025-0003'
FROM students WHERE index_number = '22375367'; -- Osei-Safo: partial

-- Some students have no payments (fully outstanding)

INSERT INTO fee_payments (student_id, academic_year, semester, amount_paid, payment_date, payment_method, reference_number)
SELECT student_id, '2025/2026', 'First Semester', 3500.00, '2025-09-08', 'University Portal', 'UP-2025-0004'
FROM students WHERE index_number = '22397756'; -- Ryan: fully paid

INSERT INTO fee_payments (student_id, academic_year, semester, amount_paid, payment_date, payment_method, reference_number)
SELECT student_id, '2025/2026', 'First Semester', 1000.00, '2025-09-14', 'Cash', 'CS-2025-0005'
FROM students WHERE index_number = '22369321'; -- Tetteh: partial

INSERT INTO fee_payments (student_id, academic_year, semester, amount_paid, payment_date, payment_method, reference_number)
SELECT student_id, '2025/2026', 'First Semester', 3500.00, '2025-09-06', 'Card', 'CD-2025-0006'
FROM students WHERE index_number = '22301848'; -- Kayelgu: fully paid

-- ---------------------------------------------------------------------
-- APP USERS (for the Next.js login/register demo)
-- Demo password for ALL seeded accounts: "password123"
-- (bcrypt hash, 10 rounds)
-- ---------------------------------------------------------------------
INSERT INTO app_users (student_id, email, password_hash, role)
SELECT student_id, email, '$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u', 'student'
FROM students;