"use client";

import { useEffect, useState, useCallback } from "react";
import { FiPlus } from "react-icons/fi";
import { useAuth } from "@/context/AuthContext";
import { useRouter } from "next/navigation";
import Card from "@/components/Card";
import Button from "@/components/Button";
import LoadingSpinner from "@/components/LoadingSpinner";
import ErrorMessage from "@/components/ErrorMessage";
import StudentTable from "@/components/StudentTable";
import StudentSearch from "@/components/StudentSearch";
import StudentForm from "@/components/StudentForm";

export default function StudentsPage() {
  const { user, authFetch } = useAuth();
  const router = useRouter();
  const [students, setStudents] = useState<any[]>([]);
  const [search, setSearch] = useState("");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [showForm, setShowForm] = useState(false);

  const load = useCallback(
    async (q = "") => {
      setLoading(true);
      setError("");
      try {
        const res = await authFetch(`/api/students${q ? `?search=${encodeURIComponent(q)}` : ""}`);
        if (!res.ok) {
          const data = await res.json().catch(() => ({}));
          throw new Error(data.error || "Failed to load students.");
        }
        setStudents(await res.json());
      } catch (e: any) {
        setError(e.message);
      } finally {
        setLoading(false);
      }
    },
    [authFetch]
  );

  useEffect(() => {
    if (user && user.role !== "lecturer") {
      router.replace("/dashboard");
      return;
    }
    if (user) load();
  }, [user, load, router]);

  useEffect(() => {
    const t = setTimeout(() => {
      if (user?.role === "lecturer") load(search);
    }, 300);
    return () => clearTimeout(t);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [search]);

  async function handleAdd(data: any) {
    const res = await authFetch("/api/students", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(data),
    });
    const body = await res.json().catch(() => ({}));
    if (!res.ok) return { error: body.error || "Failed to add student." };
    setStudents((prev) => [...prev, body].sort((a, b) => a.last_name.localeCompare(b.last_name)));
    return {};
  }

  async function handleDelete(id: number) {
    const res = await authFetch(`/api/students/${id}`, { method: "DELETE" });
    if (res.ok) {
      setStudents((prev) => prev.filter((s) => s.student_id !== id));
    }
  }

  if (user && user.role !== "lecturer") return null;

  return (
    <div className="space-y-6 animate-fade-in">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-textprimary">Students</h1>
          <p className="text-textsecondary text-sm mt-1">{students.length} students on record</p>
        </div>
        <Button variant="primary" onClick={() => setShowForm(true)}>
          <FiPlus className="h-4 w-4" /> Add Student
        </Button>
      </div>

      <Card>
        <div className="mb-5">
          <StudentSearch value={search} onChange={setSearch} />
        </div>

        {error && <ErrorMessage message={error} />}

        {loading ? (
          <div className="flex justify-center py-16">
            <LoadingSpinner size="lg" />
          </div>
        ) : (
          <StudentTable students={students} onDelete={handleDelete} />
        )}
      </Card>

      {showForm && <StudentForm onClose={() => setShowForm(false)} onSubmit={handleAdd} />}
    </div>
  );
}
