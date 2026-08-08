-- =====================================================================
-- CPEN 208 Project 1 — Database Function
-- File: 03_function_outstanding_fees.sql
--
-- get_outstanding_fees()
--   Calculates the outstanding balance for EVERY student by comparing
--   what they were billed (fee_structure, matched on program/level/
--   academic_year/semester) against the sum of what they have actually
--   paid (fee_payments). Returns the result as a single JSON array,
--   one object per student.
-- =====================================================================

SET search_path TO academics, public;

CREATE OR REPLACE FUNCTION get_outstanding_fees()
RETURNS JSON AS $$
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
$$ LANGUAGE plpgsql STABLE
   SET search_path = academics, public;

-- Optional overload: outstanding fees for a single student by student_id.
CREATE OR REPLACE FUNCTION get_outstanding_fees(p_student_id INTEGER)
RETURNS JSON AS $$
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
$$ LANGUAGE plpgsql STABLE
   SET search_path = academics, public;

-- Example usage:
--   SELECT get_outstanding_fees();
--   SELECT get_outstanding_fees(1);
