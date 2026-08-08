import { NextRequest, NextResponse } from "next/server";
import { pool } from "@/lib/db";
import { getAuth } from "@/lib/auth";

export async function GET(req: NextRequest) {
  const user = getAuth(req);
  if (!user) return NextResponse.json({ error: "Unauthorized." }, { status: 401 });

  if (user.role === "lecturer") {
    const result = await pool.query(
      `SELECT lecturer_id, staff_id, first_name, last_name, email, phone, department, academic_rank, office_location
       FROM lecturers WHERE lecturer_id = $1`,
      [user.lecturerId]
    );
    return NextResponse.json({ role: "lecturer", profile: result.rows[0] });
  }

  const result = await pool.query(
    `SELECT student_id, index_number, first_name, last_name, email, phone, program, level, hall_of_residence, year_of_admission
     FROM students WHERE student_id = $1`,
    [user.studentId]
  );
  return NextResponse.json({ role: "student", profile: result.rows[0] });
}
