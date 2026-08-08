import { NextRequest, NextResponse } from "next/server";
import { pool } from "@/lib/db";
import { getAuth } from "@/lib/auth";

export async function GET(req: NextRequest) {
  const user = getAuth(req);
  if (!user) return NextResponse.json({ error: "Unauthorized." }, { status: 401 });

  const studentIdParam = req.nextUrl.searchParams.get("studentId");
  let studentId: number | string | undefined = studentIdParam ?? undefined;

  if (user.role === "student") {
    // Students may only ever see their own payment history, regardless of what's in the query string.
    studentId = user.studentId;
  } else if (!studentId) {
    return NextResponse.json({ error: "studentId query param is required for lecturer requests." }, { status: 400 });
  }

  const result = await pool.query(
    `SELECT payment_id, academic_year, semester::text, amount_paid, payment_date, payment_method::text, reference_number
     FROM fee_payments WHERE student_id = $1 ORDER BY payment_date DESC`,
    [studentId]
  );
  return NextResponse.json(result.rows);
}

export async function POST(req: NextRequest) {
  const user = getAuth(req);
  if (!user) return NextResponse.json({ error: "Unauthorized." }, { status: 401 });
  if (user.role !== "lecturer") return NextResponse.json({ error: "Forbidden. Requires role: lecturer." }, { status: 403 });

  const { studentId, academicYear, semester, amountPaid, paymentMethod, referenceNumber } = await req.json();
  if (!studentId || !academicYear || !semester || !amountPaid || !referenceNumber) {
    return NextResponse.json(
      { error: "studentId, academicYear, semester, amountPaid, and referenceNumber are required." },
      { status: 400 }
    );
  }

  try {
    const result = await pool.query(
      `INSERT INTO fee_payments (student_id, academic_year, semester, amount_paid, payment_method, reference_number)
       VALUES ($1,$2,$3::semester_type,$4, COALESCE($5,'Mobile Money')::payment_method_type,$6)
       RETURNING *`,
      [studentId, academicYear, semester, amountPaid, paymentMethod, referenceNumber]
    );
    return NextResponse.json(result.rows[0], { status: 201 });
  } catch (err: any) {
    if (err.code === "23505") {
      return NextResponse.json({ error: "A payment with that reference number already exists." }, { status: 409 });
    }
    console.error(err);
    return NextResponse.json({ error: "Internal server error." }, { status: 500 });
  }
}
