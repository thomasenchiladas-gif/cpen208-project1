import { NextRequest, NextResponse } from "next/server";
import { pool } from "@/lib/db";
import { getAuth } from "@/lib/auth";

export async function GET(req: NextRequest) {
  const user = getAuth(req);
  if (!user) return NextResponse.json({ error: "Unauthorized." }, { status: 401 });
  if (user.role !== "lecturer") return NextResponse.json({ error: "Forbidden. Requires role: lecturer." }, { status: 403 });

  const result = await pool.query(`SELECT get_outstanding_fees() AS fees`);
  return NextResponse.json(result.rows[0].fees);
}
