import { NextRequest, NextResponse } from "next/server";
import { pool } from "@/lib/db";
import { getAuth } from "@/lib/auth";

export async function DELETE(req: NextRequest, { params }: { params: { id: string } }) {
  const user = getAuth(req);
  if (!user) return NextResponse.json({ error: "Unauthorized." }, { status: 401 });

  // Students may only drop their own enrollment; lecturers may drop any.
  const ownershipClause = user.role === "student" ? "AND student_id = $2" : "";
  const values = user.role === "student" ? [params.id, user.studentId] : [params.id];

  const result = await pool.query(
    `DELETE FROM enrollments WHERE enrollment_id = $1 ${ownershipClause} RETURNING enrollment_id`,
    values
  );
  if (result.rowCount === 0) return NextResponse.json({ error: "Enrollment not found." }, { status: 404 });
  return new NextResponse(null, { status: 204 });
}
