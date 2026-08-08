"use client";

import { useState } from "react";
import { FiX } from "react-icons/fi";
import Button from "./Button";
import ErrorMessage from "./ErrorMessage";

export default function CourseRegistrationForm({
  students,
  courses,
  onClose,
  onSubmit,
}: {
  students: any[];
  courses: any[];
  onClose: () => void;
  onSubmit: (data: any) => Promise<{ error?: string }>;
}) {
  const [studentId, setStudentId] = useState("");
  const [courseId, setCourseId] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    setLoading(true);
    const result = await onSubmit({
      studentId: Number(studentId),
      courseId: Number(courseId),
      academicYear: "2025/2026",
      semester: "First Semester",
    });
    setLoading(false);
    if (result.error) {
      setError(result.error);
      return;
    }
    onClose();
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 animate-fade-in">
      <div className="w-full max-w-md rounded-xl bg-white shadow-xl">
        <div className="flex items-center justify-between px-6 py-4 border-b border-borderc">
          <h2 className="font-semibold text-textprimary">Enroll Student in Course</h2>
          <button onClick={onClose} className="text-textsecondary hover:text-textprimary">
            <FiX className="h-5 w-5" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          {error && <ErrorMessage message={error} />}

          <div>
            <label className="label">Student</label>
            <select required className="input" value={studentId} onChange={(e) => setStudentId(e.target.value)}>
              <option value="">Select a student…</option>
              {students.map((s) => (
                <option key={s.student_id} value={s.student_id}>
                  {s.first_name} {s.last_name} ({s.index_number})
                </option>
              ))}
            </select>
          </div>

          <div>
            <label className="label">Course</label>
            <select required className="input" value={courseId} onChange={(e) => setCourseId(e.target.value)}>
              <option value="">Select a course…</option>
              {courses.map((c) => (
                <option key={c.course_id} value={c.course_id}>
                  {c.course_code} — {c.course_title}
                </option>
              ))}
            </select>
          </div>

          <div className="flex gap-3 pt-2">
            <Button type="button" variant="secondary" onClick={onClose} className="flex-1">
              Cancel
            </Button>
            <Button type="submit" variant="primary" loading={loading} className="flex-1">
              Enroll
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
}
