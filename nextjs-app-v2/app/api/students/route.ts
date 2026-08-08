import { NextRequest, NextResponse } from "next/server";
import { pool } from "@/lib/db";
import { getAuth } from "@/lib/auth";

export async function GET(req: NextRequest) {
  const user = getAuth(req);
  if (!user) return NextResponse.json({ error: "Unauthorized." }, { status: 401 });
  if (user.role !== "lecturer") return NextResponse.json({ error: "Forbidden. Requires role: lecturer." }, { status: 403 });

  const search = req.nextUrl.searchParams.get("search")?.trim();

  const result = await pool.query(
    search
      ? `SELECT student_id, index_number, first_name, last_name, email, phone, program, level, hall_of_residence
         FROM students
         WHERE first_name ILIKE $1 OR last_name ILIKE $1 OR index_number ILIKE $1 OR email ILIKE $1
         ORDER BY last_name, first_name`
      : `SELECT student_id, index_number, first_name, last_name, email, phone, program, level, hall_of_residence
         FROM students ORDER BY last_name, first_name`,
    search ? [`%${search}%`] : []
  );
  return NextResponse.json(result.rows);
}

export async function POST(req: NextRequest) {
  const user = getAuth(req);
  if (!user) return NextResponse.json({ error: "Unauthorized." }, { status: 401 });
  if (user.role !== "lecturer") return NextResponse.json({ error: "Forbidden. Requires role: lecturer." }, { status: 403 });

  const { indexNumber, firstName, lastName, email, phone, level, yearOfAdmission } = await req.json();
  if (!indexNumber || !firstName || !lastName || !email || !level) {
    return NextResponse.json({ error: "indexNumber, firstName, lastName, email, and level are required." }, { status: 400 });
  }

  try {
    const result = await pool.query(
      `INSERT INTO students (index_number, first_name, last_name, email, phone, level, year_of_admission)
       VALUES ($1,$2,$3,$4,$5,$6, COALESCE($7, EXTRACT(YEAR FROM CURRENT_DATE)))
       RETURNING *`,
      [indexNumber, firstName, lastName, email, phone || null, level, yearOfAdmission || null]
    );
    return NextResponse.json(result.rows[0], { status: 201 });
  } catch (err: any) {
    if (err.code === "23505") {
      return NextResponse.json({ error: "A student with that index number or email already exists." }, { status: 409 });
    }
    console.error(err);
    return NextResponse.json({ error: "Internal server error." }, { status: 500 });
  }
}
