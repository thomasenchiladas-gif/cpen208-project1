"use client";

import { useEffect, useState, useCallback } from "react";
import { FiPlus } from "react-icons/fi";
import { useAuth } from "@/context/AuthContext";
import Card from "@/components/Card";
import Button from "@/components/Button";
import LoadingSpinner from "@/components/LoadingSpinner";
import ErrorMessage from "@/components/ErrorMessage";
import CourseGrid from "@/components/CourseGrid";
import CourseRegistrationForm from "@/components/CourseRegistrationForm";

export default function CoursesPage() {
  const { user, authFetch } = useAuth();
  const [courses, setCourses] = useState<any[]>([]);
  const [myEnrollments, setMyEnrollments] = useState<any[]>([]);
  const [students, setStudents] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [actionLoadingId, setActionLoadingId] = useState<number | null>(null);
  const [showEnrollForm, setShowEnrollForm] = useState(false);

  const load = useCallback(async () => {
    setLoading(true);
    setError("");
    try {
      if (user?.role === "lecturer") {
        const [coursesRes, studentsRes] = await Promise.all([
          authFetch("/api/courses"),
          authFetch("/api/students"),
        ]);
        if (!coursesRes.ok || !studentsRes.ok) throw new Error("Failed to load courses.");
        setCourses(await coursesRes.json());
        setStudents(await studentsRes.json());
      } else {
        const [coursesRes, enrollRes] = await Promise.all([
          authFetch("/api/courses"),
          authFetch("/api/enrollments"),
        ]);
        if (!coursesRes.ok || !enrollRes.ok) throw new Error("Failed to load courses.");
        setCourses(await coursesRes.json());
        setMyEnrollments(await enrollRes.json());
      }
    } catch (e: any) {
      setError(e.message);
    } finally {
      setLoading(false);
    }
  }, [authFetch, user]);

  useEffect(() => {
    if (user) load();
  }, [user, load]);

  async function handleRegister(courseId: number) {
    setActionLoadingId(courseId);
    const res = await authFetch("/api/enrollments", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ courseId, academicYear: "2025/2026", semester: "First Semester" }),
    });
    if (res.ok) await load();
    else {
      const body = await res.json().catch(() => ({}));
      setError(body.error || "Failed to register for course.");
    }
    setActionLoadingId(null);
  }

  async function handleDrop(courseId: number) {
    setActionLoadingId(courseId);
    const enrollment = myEnrollments.find((e) => e.course_id === courseId);
    if (enrollment) {
      const res = await authFetch(`/api/enrollments/${enrollment.enrollment_id}`, { method: "DELETE" });
      if (res.ok) await load();
      else setError("Failed to drop course.");
    }
    setActionLoadingId(null);
  }

  async function handleLecturerEnroll(data: any) {
    const res = await authFetch("/api/enrollments", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(data),
    });
    const body = await res.json().catch(() => ({}));
    if (!res.ok) return { error: body.error || "Failed to enroll student." };
    await load();
    return {};
  }

  if (loading) {
    return (
      <div className="flex justify-center py-24">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  const enrolledCourseIds = new Set(myEnrollments.map((e) => e.course_id));

  return (
    <div className="space-y-6 animate-fade-in">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-textprimary">Courses</h1>
          <p className="text-textsecondary text-sm mt-1">
            {user?.role === "lecturer" ? `${courses.length} courses in the department` : "Browse and manage your enrollment"}
          </p>
        </div>
        {user?.role === "lecturer" && (
          <Button variant="primary" onClick={() => setShowEnrollForm(true)}>
            <FiPlus className="h-4 w-4" /> Enroll Student
          </Button>
        )}
      </div>

      {error && <ErrorMessage message={error} />}

      <CourseGrid
        courses={courses}
        enrolledCourseIds={enrolledCourseIds}
        role={user?.role === "lecturer" ? "lecturer" : "student"}
        onRegister={handleRegister}
        onDrop={handleDrop}
        actionLoadingId={actionLoadingId}
      />

      {showEnrollForm && (
        <CourseRegistrationForm
          students={students}
          courses={courses}
          onClose={() => setShowEnrollForm(false)}
          onSubmit={handleLecturerEnroll}
        />
      )}
    </div>
  );
}
