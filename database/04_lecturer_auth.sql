-- =====================================================================
-- CPEN 208 Project 1 — Lecturer Login
-- File: database/04_lecturer_auth.sql
--
-- Extends app_users so lecturers can log in alongside students:
--   - adds a nullable lecturer_id column (mirrors the existing
--     nullable student_id column)
--   - adds a CHECK constraint so every account is linked to exactly
--     ONE of a student or a lecturer, never both/neither
--   - seeds one app_users login per lecturer
--
-- Run this AFTER 01_schema.sql, 02_seed_data.sql, and
-- 03_function_outstanding_fees.sql have already been applied, e.g.:
--   psql -U postgres -d cpen_db -f 04_lecturer_auth.sql
-- =====================================================================

SET search_path TO academics, public;

-- ---------------------------------------------------------------------
-- 1. Add lecturer_id to app_users
-- ---------------------------------------------------------------------
ALTER TABLE app_users
  ADD COLUMN IF NOT EXISTS lecturer_id INTEGER UNIQUE
    REFERENCES lecturers(lecturer_id) ON DELETE CASCADE;

-- Every account must belong to exactly one person: a student OR a lecturer.
ALTER TABLE app_users
  DROP CONSTRAINT IF EXISTS app_users_exactly_one_owner;

ALTER TABLE app_users
  ADD CONSTRAINT app_users_exactly_one_owner
  CHECK (
    (student_id IS NOT NULL AND lecturer_id IS NULL) OR
    (student_id IS NULL AND lecturer_id IS NOT NULL)
  );

-- ---------------------------------------------------------------------
-- 2. Seed one login per lecturer
-- Demo password for ALL seeded lecturer accounts: "password123"
-- (same bcrypt hash already used for the seeded student accounts)
-- ---------------------------------------------------------------------
INSERT INTO app_users (lecturer_id, email, password_hash, role)
SELECT lecturer_id, email, '$2b$10$2UqR4Wr.oI.izf.J2iZrIOR3c76WhXXjgi62/0eHM2sNnnRrIKU6u', 'lecturer'
FROM lecturers
ON CONFLICT (email) DO NOTHING;
