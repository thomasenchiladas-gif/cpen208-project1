import { NextRequest, NextResponse } from "next/server";
import bcrypt from "bcryptjs";
import { pool } from "@/lib/db";
import { signToken } from "@/lib/auth";

export async function POST(req: NextRequest) {
  const { email, password } = await req.json();

  if (!email || !password) {
    return NextResponse.json({ error: "Email and password are required." }, { status: 400 });
  }

  const result = await pool.query(
    `SELECT u.user_id, u.student_id, u.lecturer_id, u.email, u.password_hash, u.role,
            COALESCE(s.first_name, l.first_name) AS first_name,
            COALESCE(s.last_name, l.last_name) AS last_name
     FROM app_users u
     LEFT JOIN students s ON s.student_id = u.student_id
     LEFT JOIN lecturers l ON l.lecturer_id = u.lecturer_id
     WHERE u.email = $1`,
    [String(email).toLowerCase()]
  );

  if (result.rowCount === 0) {
    return NextResponse.json({ error: "No account found with that email." }, { status: 401 });
  }

  const user = result.rows[0];
  const valid = await bcrypt.compare(password, user.password_hash);
  if (!valid) {
    return NextResponse.json({ error: "Incorrect password." }, { status: 401 });
  }

  const fullName = `${user.first_name} ${user.last_name}`;
  const token = signToken({
    userId: user.user_id,
    role: user.role,
    studentId: user.student_id ?? undefined,
    lecturerId: user.lecturer_id ?? undefined,
    email: user.email,
    fullName,
  });

  return NextResponse.json({
    token,
    user: {
      userId: user.user_id,
      role: user.role,
      studentId: user.student_id ?? undefined,
      lecturerId: user.lecturer_id ?? undefined,
      email: user.email,
      fullName,
    },
  });
}
