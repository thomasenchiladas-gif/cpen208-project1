import { NextRequest, NextResponse } from "next/server";
import { pool } from "@/lib/db";
import { getAuth } from "@/lib/auth";

export async function GET(req: NextRequest) {
  const user = getAuth(req);
  if (!user) return NextResponse.json({ error: "Unauthorized." }, { status: 401 });

  const studentIdParam = req.nextUrl.searchParams.get("studentId");
  const studentId = user.role === "student" ? user.studentId : studentIdParam;
  if (!studentId) {
    return NextResponse.json({ error: "studentId query param is required for lecturer requests." }, { status: 400 });
  }

  const result = await pool.query(
    `SELECT enrollment_id, course_id, academic_year, semester::text, grade::text
     FROM enrollments WHERE student_id = $1`,
    [studentId]
  );
  return NextResponse.json(result.rows);
}

export async function POST(req: NextRequest) {
  const user = getAuth(req);
  if (!user) return NextResponse.json({ error: "Unauthorized." }, { status: 401 });

  const { courseId, academicYear, semester, studentId: bodyStudentId } = await req.json();

  // Students may only ever enroll themselves; lecturers can enroll anyone.
  const studentId = user.role === "student" ? user.studentId : bodyStudentId;
  if (!studentId || !courseId || !academicYear || !semester) {
    return NextResponse.json({ error: "courseId, academicYear, and semester are required." }, { status: 400 });
  }

  try {
    const result = await pool.query(
      `INSERT INTO enrollments (student_id, course_id, academic_year, semester)
       VALUES ($1,$2,$3,$4::semester_type) RETURNING *`,
      [studentId, courseId, academicYear, semester]
    );
    return NextResponse.json(result.rows[0], { status: 201 });
  } catch (err: any) {
    if (err.code === "23505") {
      return NextResponse.json({ error: "Already enrolled in this course for that semester." }, { status: 409 });
    }
    console.error(err);
    return NextResponse.json({ error: "Internal server error." }, { status: 500 });
  }
}
