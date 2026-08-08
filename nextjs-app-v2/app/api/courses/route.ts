import { NextRequest, NextResponse } from "next/server";
import { pool } from "@/lib/db";
import { getAuth } from "@/lib/auth";

export async function GET(req: NextRequest) {
  const user = getAuth(req);
  if (!user) return NextResponse.json({ error: "Unauthorized." }, { status: 401 });

  const result = await pool.query(
    `SELECT c.course_id, c.course_code, c.course_title, c.credit_hours, c.level,
            lca.academic_year, lca.semester::text,
            (l.first_name || ' ' || l.last_name) AS lecturer_name,
            (SELECT COUNT(*) FROM enrollments e WHERE e.course_id = c.course_id) AS enrolled_count
     FROM courses c
     LEFT JOIN lecturer_course_assignments lca ON lca.course_id = c.course_id
     LEFT JOIN lecturers l ON l.lecturer_id = lca.lecturer_id
     ORDER BY c.course_code`
  );
  return NextResponse.json(result.rows);
}
