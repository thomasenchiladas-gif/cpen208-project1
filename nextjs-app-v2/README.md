# CPEN 208 — Student Management System 

A full UI and architecture overhaul of the Project 1 Next.js app: client
components fetching from Next.js API routes (instead of Server Actions),
JWT stored in `localStorage`, and a new design system (blue/purple
gradient palette, Inter font, card-based layout with a dark sidebar).

## Architecture

```
Browser (client components)
   │  fetch() with Authorization: Bearer <token from localStorage>
   ▼
app/api/*/route.ts   (Next.js Route Handlers — server-side, talk to Postgres)
   │
   ▼
cpen_db (PostgreSQL)
```
 `app/(app)/layout.tsx` is a client
component that wraps every protected page (dashboard, students, fees,
courses, profile). On mount it checks `AuthContext` for a valid user; if
none is found, it redirects to `/login`. This is the standard pattern
for `localStorage`-based auth in Next.js App Router, and is functionally
equivalent from a user's perspective — you cannot reach a protected page




## Setup

```bash
cp .env.example .env.local   # fill in your DATABASE_URL and JWT_SECRET
npm install
npm run build
npm start
```

Demo accounts (same as the rest of the project, password `password123`
for all seeded accounts):
- Student: `abu.golda@st.ug.edu.gh`
- Lecturer: `kwame.anokye@ug.edu.gh`

## Pages

| Route | Access | Purpose |
|---|---|---|
| `/login` | Public | Sign in |
| `/register` | Public | Student self-registration |
| `/dashboard` | Protected | Role-aware overview (stats cards, fee summary, courses/students) |
| `/students` | Lecturer only | Search, add, delete students |
| `/fees` | Protected | Student: own balance + history. Lecturer: everyone's balances, record payments |
| `/courses` | Protected | Student: register/drop. Lecturer: enroll any student |
| `/profile` | Protected | View info, edit contact details, change password |

## API Routes

| Route | Method(s) | Access |
|---|---|---|
| `/api/auth/register` | POST | Public |
| `/api/auth/login` | POST | Public |
| `/api/auth/me` | GET | Any authenticated |
| `/api/auth/change-password` | POST | Any authenticated |
| `/api/students` | GET, POST | Lecturer |
| `/api/students/[id]` | GET, PUT, DELETE | GET: any; PUT/DELETE: lecturer |
| `/api/courses` | GET | Any authenticated |
| `/api/enrollments` | GET, POST | Any authenticated (students act on themselves only) |
| `/api/enrollments/[id]` | DELETE | Any authenticated (students can only drop their own) |
| `/api/fees/me` | GET | Student |
| `/api/fees/outstanding` | GET | Lecturer — calls `get_outstanding_fees()` |
| `/api/fees/payments` | GET, POST | GET: any (own or by studentId for lecturer); POST: lecturer |

## What was tested

Every route above was exercised against the live `cpen_db` with `curl`
after a production build (`npm run build && npm start`):
- Student and lecturer login, correct token payloads
- Role restrictions (403 on lecturer-only routes for a student token)
- Registration, then immediate login with the new account
- Recording a payment and seeing it reflected in `get_outstanding_fees()`
- Course registration and drop, verified via `/api/enrollments` before/after
- Change password: wrong current password rejected (401), correct change
  accepted, then successful login with the new password

All test data created during this pass was deleted afterward; the
database is back to its original 70-student seed state.
