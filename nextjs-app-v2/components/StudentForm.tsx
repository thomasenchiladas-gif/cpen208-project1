"use client";

import { useState } from "react";
import { FiX } from "react-icons/fi";
import Button from "./Button";
import ErrorMessage from "./ErrorMessage";

export default function StudentForm({
  onClose,
  onSubmit,
}: {
  onClose: () => void;
  onSubmit: (data: any) => Promise<{ error?: string }>;
}) {
  const [form, setForm] = useState({ indexNumber: "", firstName: "", lastName: "", email: "", phone: "", level: "200" });
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  function update(field: string, value: string) {
    setForm((f) => ({ ...f, [field]: value }));
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    setLoading(true);
    const result = await onSubmit({ ...form, level: Number(form.level) });
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
          <h2 className="font-semibold text-textprimary">Add Student</h2>
          <button onClick={onClose} className="text-textsecondary hover:text-textprimary">
            <FiX className="h-5 w-5" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          {error && <ErrorMessage message={error} />}

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="label">First name</label>
              <input required className="input" value={form.firstName} onChange={(e) => update("firstName", e.target.value)} />
            </div>
            <div>
              <label className="label">Last name</label>
              <input required className="input" value={form.lastName} onChange={(e) => update("lastName", e.target.value)} />
            </div>
          </div>

          <div>
            <label className="label">Index number</label>
            <input required className="input" value={form.indexNumber} onChange={(e) => update("indexNumber", e.target.value)} />
          </div>

          <div>
            <label className="label">Email</label>
            <input type="email" required className="input" value={form.email} onChange={(e) => update("email", e.target.value)} />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="label">Phone</label>
              <input className="input" value={form.phone} onChange={(e) => update("phone", e.target.value)} />
            </div>
            <div>
              <label className="label">Level</label>
              <select className="input" value={form.level} onChange={(e) => update("level", e.target.value)}>
                <option value="100">100</option>
                <option value="200">200</option>
                <option value="300">300</option>
                <option value="400">400</option>
              </select>
            </div>
          </div>

          <div className="flex gap-3 pt-2">
            <Button type="button" variant="secondary" onClick={onClose} className="flex-1">
              Cancel
            </Button>
            <Button type="submit" variant="primary" loading={loading} className="flex-1">
              Add Student
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
}
