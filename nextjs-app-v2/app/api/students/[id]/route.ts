import { NextRequest, NextResponse } from "next/server";
import { pool } from "@/lib/db";
import { getAuth } from "@/lib/auth";

export async function GET(req: NextRequest, { params }: { params: { id: string } }) {
  const user = getAuth(req);
  if (!user) return NextResponse.json({ error: "Unauthorized." }, { status: 401 });

  const result = await pool.query(`SELECT * FROM students WHERE student_id = $1`, [params.id]);
  if (result.rowCount === 0) return NextResponse.json({ error: "Student not found." }, { status: 404 });
  return NextResponse.json(result.rows[0]);
}

export async function PUT(req: NextRequest, { params }: { params: { id: string } }) {
  const user = getAuth(req);
  if (!user) return NextResponse.json({ error: "Unauthorized." }, { status: 401 });
  if (user.role !== "lecturer") return NextResponse.json({ error: "Forbidden. Requires role: lecturer." }, { status: 403 });

  const { phone, hallOfResidence, level } = await req.json();
  const result = await pool.query(
    `UPDATE students SET
       phone = COALESCE($1, phone),
       hall_of_residence = COALESCE($2, hall_of_residence),
       level = COALESCE($3, level)
     WHERE student_id = $4 RETURNING *`,
    [phone, hallOfResidence, level, params.id]
  );
  if (result.rowCount === 0) return NextResponse.json({ error: "Student not found." }, { status: 404 });
  return NextResponse.json(result.rows[0]);
}

export async function DELETE(req: NextRequest, { params }: { params: { id: string } }) {
  const user = getAuth(req);
  if (!user) return NextResponse.json({ error: "Unauthorized." }, { status: 401 });
  if (user.role !== "lecturer") return NextResponse.json({ error: "Forbidden. Requires role: lecturer." }, { status: 403 });

  const result = await pool.query(`DELETE FROM students WHERE student_id = $1 RETURNING student_id`, [params.id]);
  if (result.rowCount === 0) return NextResponse.json({ error: "Student not found." }, { status: 404 });
  return new NextResponse(null, { status: 204 });
}
