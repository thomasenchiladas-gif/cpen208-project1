"use client";

import { useState } from "react";
import { FiEdit2, FiTrash2, FiX } from "react-icons/fi";
import Button from "./Button";

export default function StudentTable({
  students,
  onDelete,
}: {
  students: any[];
  onDelete: (id: number) => Promise<void>;
}) {
  const [confirmId, setConfirmId] = useState<number | null>(null);
  const [deleting, setDeleting] = useState(false);

  async function handleConfirmDelete() {
    if (confirmId == null) return;
    setDeleting(true);
    await onDelete(confirmId);
    setDeleting(false);
    setConfirmId(null);
  }

  return (
    <div className="overflow-x-auto">
      <table className="w-full text-sm">
        <thead>
          <tr className="text-left text-xs uppercase tracking-wide text-textsecondary border-b border-borderc">
            <th className="pb-3 font-semibold">Index No.</th>
            <th className="pb-3 font-semibold">Name</th>
            <th className="pb-3 font-semibold">Email</th>
            <th className="pb-3 font-semibold">Phone</th>
            <th className="pb-3 font-semibold">Level</th>
            <th className="pb-3 font-semibold text-right">Actions</th>
          </tr>
        </thead>
        <tbody>
          {students.map((s, i) => (
            <tr
              key={s.student_id}
              className={`border-b border-borderc last:border-0 ${i % 2 ? "bg-slate-50/50" : ""} hover:bg-primary/5 transition`}
            >
              <td className="py-3 font-mono text-xs text-textsecondary">{s.index_number}</td>
              <td className="py-3 font-medium text-textprimary">{s.first_name} {s.last_name}</td>
              <td className="py-3 text-textsecondary">{s.email}</td>
              <td className="py-3 text-textsecondary">{s.phone || "—"}</td>
              <td className="py-3 text-textsecondary">{s.level}</td>
              <td className="py-3">
                <div className="flex justify-end gap-2">
                  <button className="p-1.5 rounded-md text-textsecondary hover:text-primary hover:bg-primary/10 transition" aria-label="Edit">
                    <FiEdit2 className="h-4 w-4" />
                  </button>
                  <button
                    onClick={() => setConfirmId(s.student_id)}
                    className="p-1.5 rounded-md text-textsecondary hover:text-danger hover:bg-danger/10 transition"
                    aria-label="Delete"
                  >
                    <FiTrash2 className="h-4 w-4" />
                  </button>
                </div>
              </td>
            </tr>
          ))}
          {students.length === 0 && (
            <tr>
              <td colSpan={6} className="py-8 text-center text-textsecondary">
                No students found.
              </td>
            </tr>
          )}
        </tbody>
      </table>

      {confirmId != null && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 animate-fade-in">
          <div className="w-full max-w-sm rounded-xl bg-white shadow-xl p-6">
            <div className="flex items-center justify-between mb-2">
              <h3 className="font-semibold text-textprimary">Delete student?</h3>
              <button onClick={() => setConfirmId(null)} className="text-textsecondary hover:text-textprimary">
                <FiX className="h-5 w-5" />
              </button>
            </div>
            <p className="text-sm text-textsecondary mb-6">
              This will permanently remove the student record and all associated enrollments and payments. This cannot be undone.
            </p>
            <div className="flex gap-3">
              <Button variant="secondary" onClick={() => setConfirmId(null)} className="flex-1">
                Cancel
              </Button>
              <Button variant="danger" onClick={handleConfirmDelete} loading={deleting} className="flex-1">
                Delete
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
