import { NextRequest, NextResponse } from "next/server";
import bcrypt from "bcryptjs";
import { pool } from "@/lib/db";
import { getAuth } from "@/lib/auth";

export async function POST(req: NextRequest) {
  const user = getAuth(req);
  if (!user) return NextResponse.json({ error: "Unauthorized." }, { status: 401 });

  const { currentPassword, newPassword } = await req.json();
  if (!currentPassword || !newPassword) {
    return NextResponse.json({ error: "currentPassword and newPassword are required." }, { status: 400 });
  }
  if (String(newPassword).length < 8) {
    return NextResponse.json({ error: "New password must be at least 8 characters." }, { status: 400 });
  }

  const result = await pool.query(`SELECT password_hash FROM app_users WHERE user_id = $1`, [user.userId]);
  if (result.rowCount === 0) {
    return NextResponse.json({ error: "Account not found." }, { status: 404 });
  }

  const valid = await bcrypt.compare(currentPassword, result.rows[0].password_hash);
  if (!valid) {
    return NextResponse.json({ error: "Current password is incorrect." }, { status: 401 });
  }

  const newHash = await bcrypt.hash(newPassword, 10);
  await pool.query(`UPDATE app_users SET password_hash = $1 WHERE user_id = $2`, [newHash, user.userId]);

  return NextResponse.json({ success: true });
}
