import { NextRequest, NextResponse } from "next/server";
import { pool } from "@/lib/db";
import { getAuth } from "@/lib/auth";

export async function GET(req: NextRequest) {
  const user = getAuth(req);
  if (!user) return NextResponse.json({ error: "Unauthorized." }, { status: 401 });
  if (user.role !== "student") return NextResponse.json({ error: "Only student accounts have a fee balance." }, { status: 403 });

  const result = await pool.query(`SELECT get_outstanding_fees($1) AS fees`, [user.studentId]);
  const fees = result.rows[0].fees;
  return NextResponse.json(fees?.[0] ?? null);
}
