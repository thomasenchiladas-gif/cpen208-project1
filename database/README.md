# CPEN 208 Project 1 — Database

PostgreSQL database supporting: student personal information, student fee
payments, course enrollment, lecturer-to-course assignment, and
lecturer-to-TA assignment for the Computer Engineering Department.

## Files

| File                                | Purpose                                                        |
|--------------------------------------|-----------------------------------------------------------------|
| `01_schema.sql`                     | Creates the `academics` schema and all tables                   |
| `02_seed_data.sql`                  | Inserts sample data — 70 students, 4 lecturers, 4 TAs, courses, enrollments, and fees |
| `03_function_outstanding_fees.sql`  | Creates `get_outstanding_fees()`, returns JSON of fee balances  |
| `04_lecturer_auth.sql`              | Extends `app_users` so lecturers can log in alongside students, and seeds one login per lecturer |
| `cpen_db_backup.dump`               | Full database backup (custom/compressed `pg_dump` format)       |
| `cpen_db_backup.sql`                | Full database backup (plain SQL, human-readable)                 |

## Setup from scratch

Run the scripts **in order** — `04_lecturer_auth.sql` depends on the tables
and data created by the first three:

```bash
createdb cpen_db
psql -d cpen_db -f 01_schema.sql
psql -d cpen_db -f 02_seed_data.sql
psql -d cpen_db -f 03_function_outstanding_fees.sql
psql -d cpen_db -f 04_lecturer_auth.sql
```

## Restoring from the backup instead

The backup already includes everything above (schema, seed data, function,
and lecturer auth), so this is the faster path:

```bash
# Custom format (recommended, faster, compressed)
createdb cpen_db
pg_restore -d cpen_db cpen_db_backup.dump

# OR plain SQL format
createdb cpen_db
psql -d cpen_db -f cpen_db_backup.sql
```

## Design overview

All tables live in a single schema, `academics`, inside the database
`cpen_db`.

- **students** — personal information (name, contact, program, level, hall)
- **lecturers** — teaching staff records
- **teaching_assistants** — TA personal record (name, email, department) with a supervising lecturer
- **courses** — course catalogue (code, title, credit hours, level)
- **enrollments** — student ↔ course, per academic year/semester, with grade
- **lecturer_course_assignments** — lecturer ↔ course, per semester
- **ta_course_assignments** — TA ↔ lecturer ↔ course, per semester
- **fee_structure** — amount billed per program/level/semester
- **fee_payments** — individual payment records per student
- **app_users** — login credentials for the Next.js portal (bcrypt-hashed).
  Each row belongs to **either** a student **or** a lecturer — never both,
  never neither — enforced by a `CHECK` constraint on `student_id` /
  `lecturer_id`.

## Outstanding fees function

```sql
-- All students
SELECT get_outstanding_fees();

-- A single student
SELECT get_outstanding_fees(1);
```

Both return a JSON array of objects with `student_id`, `index_number`,
`full_name`, `amount_billed`, `amount_paid`, and `outstanding_balance`,
computed by joining each student's applicable `fee_structure` row against
the sum of their `fee_payments`.

## Sample data

The sample data models the actual Computer Engineering Level 200 class
(70 students) taking the 2025/2026 First Semester courses (CPEN 204,
CPEN 206, CPEN 208, CPEN 212), taught by 4 lecturers and supported by
4 teaching assistants.

**Fees:** one billing tier is defined — Level 200, BSc. Computer
Engineering, 2025/2026 First Semester, **GHS 3,500.00**. Fee payments
are intentionally mixed to exercise the outstanding-fees function:

| Status | Students | Example |
|---|---|---|
| Fully paid | 3 | Golda, Ryan, Kayelgu |
| Partially paid | 3 | Yaw (GHS 2,000), Osei-Safo (GHS 1,500), Tetteh (GHS 1,000) |
| Fully outstanding (no payment) | 64 | everyone else |

**Logins:** every student and every lecturer has an `app_users` account.
All seeded accounts — student and lecturer alike — share the demo
password `password123` (bcrypt-hashed).
