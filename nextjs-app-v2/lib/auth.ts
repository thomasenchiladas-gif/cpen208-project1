import jwt from "jsonwebtoken";
import { NextRequest } from "next/server";

export type TokenPayload = {
  userId: number;
  role: "student" | "lecturer";
  studentId?: number;
  lecturerId?: number;
  email: string;
  fullName: string;
};

export function signToken(payload: TokenPayload) {
  const options: jwt.SignOptions = {
    expiresIn: (process.env.JWT_EXPIRES_IN || "7d") as jwt.SignOptions["expiresIn"],
  };
  return jwt.sign(payload, process.env.JWT_SECRET as string, options);
}

export function verifyToken(token: string): TokenPayload | null {
  try {
    return jwt.verify(token, process.env.JWT_SECRET as string) as TokenPayload;
  } catch {
    return null;
  }
}

/** Pulls and verifies the Bearer token from an API route's request. Returns null if missing/invalid. */
export function getAuth(req: NextRequest): TokenPayload | null {
  const header = req.headers.get("authorization") ?? "";
  const [scheme, token] = header.split(" ");
  if (scheme !== "Bearer" || !token) return null;
  return verifyToken(token);
}
