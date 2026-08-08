import { NextRequest, NextResponse } from "next/server";
import bcrypt from "bcryptjs";
import { pool } from "@/lib/db";
import { signToken } from "@/lib/auth";

export async function POST(req: NextRequest) {
  const { firstName, lastName, indexNumber, email, phone, password, level } = await req.json();

  if (!firstName || !lastName || !indexNumber || !email || !password) {
    return NextResponse.json(
      { error: "firstName, lastName, indexNumber, email, and password are required." },
      { status: 400 }
    );
  }
  if (String(password).length < 8) {
    return NextResponse.json({ error: "Password must be at least 8 characters." }, { status: 400 });
  }

  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    const existing = await client.query(
      `SELECT 1 FROM students WHERE index_number = $1 OR email = $2
       UNION SELECT 1 FROM app_users WHERE email = $2`,
      [indexNumber, String(email).toLowerCase()]
    );
    if ((existing.rowCount ?? 0) > 0) {
      await client.query("ROLLBACK");
      return NextResponse.json(
        { error: "A student with that index number or email already exists." },
        { status: 409 }
      );
    }

    const studentResult = await client.query(
      `INSERT INTO students (index_number, first_name, last_name, email, phone, level, year_of_admission)
       VALUES ($1,$2,$3,$4,$5,$6, EXTRACT(YEAR FROM CURRENT_DATE))
       RETURNING student_id`,
      [indexNumber, firstName, lastName, String(email).toLowerCase(), phone || null, level || 200]
    );
    const studentId = studentResult.rows[0].student_id;

    const passwordHash = await bcrypt.hash(password, 10);
    const userResult = await client.query(
      `INSERT INTO app_users (student_id, email, password_hash, role)
       VALUES ($1,$2,$3,'student') RETURNING user_id`,
      [studentId, String(email).toLowerCase(), passwordHash]
    );

    await client.query("COMMIT");

    const fullName = `${firstName} ${lastName}`;
    const token = signToken({
      userId: userResult.rows[0].user_id,
      role: "student",
      studentId,
      email: String(email).toLowerCase(),
      fullName,
    });

    return NextResponse.json(
      {
        token,
        user: { userId: userResult.rows[0].user_id, role: "student", studentId, email: String(email).toLowerCase(), fullName },
      },
      { status: 201 }
    );
  } catch (err) {
    await client.query("ROLLBACK");
    console.error(err);
    return NextResponse.json({ error: "Something went wrong while creating your account." }, { status: 500 });
  } finally {
    client.release();
  }
}
