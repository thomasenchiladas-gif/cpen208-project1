"use client";

import { useEffect, useState } from "react";
import { FiUsers, FiBook, FiCheckCircle, FiAlertTriangle } from "react-icons/fi";
import { useAuth } from "@/context/AuthContext";
import StatsCard from "@/components/StatsCard";
import Card from "@/components/Card";
import FeeSummary from "@/components/FeeSummary";
import LoadingSpinner from "@/components/LoadingSpinner";
import ErrorMessage from "@/components/ErrorMessage";

export default function DashboardPage() {
  const { user, authFetch } = useAuth();
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  // student state
  const [myFee, setMyFee] = useState<any>(null);
  const [myCourses, setMyCourses] = useState<any[]>([]);

  // lecturer state
  const [allFees, setAllFees] = useState<any[]>([]);
  const [students, setStudents] = useState<any[]>([]);
  const [courses, setCourses] = useState<any[]>([]);

  useEffect(() => {
    let cancelled = false;
    async function load() {
      setLoading(true);
      setError("");
      try {
        if (user?.role === "lecturer") {
          const [feesRes, studentsRes, coursesRes] = await Promise.all([
            authFetch("/api/fees/outstanding"),
            authFetch("/api/students"),
            authFetch("/api/courses"),
          ]);
          if (!feesRes.ok || !studentsRes.ok || !coursesRes.ok) throw new Error("Failed to load dashboard data.");
          const [fees, studentsData, coursesData] = await Promise.all([
            feesRes.json(),
            studentsRes.json(),
            coursesRes.json(),
          ]);
          if (cancelled) return;
          setAllFees(fees);
          setStudents(studentsData);
          setCourses(coursesData);
        } else {
          const [feeRes, coursesRes] = await Promise.all([
            authFetch("/api/fees/me"),
            authFetch("/api/courses"),
          ]);
          if (!feeRes.ok || !coursesRes.ok) throw new Error("Failed to load dashboard data.");
          const [fee, coursesData] = await Promise.all([feeRes.json(), coursesRes.json()]);
          if (cancelled) return;
          setMyFee(fee);
          setMyCourses(coursesData);
        }
      } catch (e: any) {
        if (!cancelled) setError(e.message || "Something went wrong.");
      } finally {
        if (!cancelled) setLoading(false);
      }
    }
    if (user) load();
    return () => {
      cancelled = true;
    };
  }, [user, authFetch]);

  if (loading) {
    return (
      <div className="flex items-center justify-center py-24">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  return (
    <div className="space-y-6 animate-fade-in">
      <div>
        <h1 className="text-2xl font-bold text-textprimary">Welcome back, {user?.fullName?.split(" ")[0]} 👋</h1>
        <p className="text-textsecondary text-sm mt-1">
          {user?.role === "lecturer" ? "Here's what's happening across your courses." : "Here's your academic snapshot."}
        </p>
      </div>

      {error && <ErrorMessage message={error} />}

      {user?.role === "lecturer" ? (
        <LecturerDashboard allFees={allFees} students={students} courses={courses} />
      ) : (
        <StudentDashboard myFee={myFee} myCourses={myCourses} />
      )}
    </div>
  );
}

function StudentDashboard({ myFee, myCourses }: { myFee: any; myCourses: any[] }) {
  const outstanding = myFee ? Number(myFee.outstanding_balance) : 0;
  return (
    <>
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatsCard label="Enrolled Courses" value={myCourses.length} icon={FiBook} tone="primary" />
        <StatsCard
          label="Fee Status"
          value={outstanding <= 0 ? "Paid" : "Due"}
          icon={outstanding <= 0 ? FiCheckCircle : FiAlertTriangle}
          tone={outstanding <= 0 ? "success" : "danger"}
        />
        <StatsCard label="Amount Paid" value={`GHS ${Number(myFee?.amount_paid ?? 0).toLocaleString()}`} icon={FiCheckCircle} tone="success" />
        <StatsCard label="Outstanding" value={`GHS ${outstanding.toLocaleString()}`} icon={FiAlertTriangle} tone="warning" />
      </div>

      <div className="grid md:grid-cols-2 gap-6">
        <Card>
          <h2 className="font-semibold text-textprimary mb-4">Fee Summary</h2>
          <FeeSummary fee={myFee} />
        </Card>
        <Card>
          <h2 className="font-semibold text-textprimary mb-4">My Courses</h2>
          <ul className="divide-y divide-borderc">
            {myCourses.map((c) => (
              <li key={c.course_id} className="py-3 flex justify-between items-center">
                <div>
                  <p className="font-medium text-sm text-textprimary">{c.course_code}</p>
                  <p className="text-xs text-textsecondary">{c.course_title}</p>
                </div>
                <span className="text-xs text-textsecondary">{c.credit_hours} cr</span>
              </li>
            ))}
          </ul>
        </Card>
      </div>
    </>
  );
}

function LecturerDashboard({ allFees, students, courses }: { allFees: any[]; students: any[]; courses: any[] }) {
  const totalPaid = allFees.reduce((sum, f) => sum + Number(f.amount_paid), 0);
  const totalOutstanding = allFees.reduce((sum, f) => sum + Number(f.outstanding_balance), 0);

  return (
    <>
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatsCard label="Total Students" value={students.length} icon={FiUsers} tone="primary" />
        <StatsCard label="Total Courses" value={courses.length} icon={FiBook} tone="secondary" />
        <StatsCard label="Total Paid" value={`GHS ${totalPaid.toLocaleString()}`} icon={FiCheckCircle} tone="success" />
        <StatsCard label="Outstanding Fees" value={`GHS ${totalOutstanding.toLocaleString()}`} icon={FiAlertTriangle} tone="danger" />
      </div>

      <Card>
        <h2 className="font-semibold text-textprimary mb-4">Recent Students</h2>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="text-left text-xs uppercase tracking-wide text-textsecondary border-b border-borderc">
                <th className="pb-2 font-semibold">Name</th>
                <th className="pb-2 font-semibold">Index Number</th>
                <th className="pb-2 font-semibold">Level</th>
              </tr>
            </thead>
            <tbody>
              {students.slice(0, 8).map((s, i) => (
                <tr key={s.student_id} className={`border-b border-borderc last:border-0 ${i % 2 ? "bg-slate-50/50" : ""} hover:bg-primary/5 transition`}>
                  <td className="py-2.5">{s.first_name} {s.last_name}</td>
                  <td className="py-2.5 text-textsecondary">{s.index_number}</td>
                  <td className="py-2.5 text-textsecondary">{s.level}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </Card>
    </>
  );
}
