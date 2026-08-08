"use client";

import { useState } from "react";
import { FiX } from "react-icons/fi";
import Button from "./Button";
import ErrorMessage from "./ErrorMessage";

export default function PayFeeModal({
  studentId,
  onClose,
  onSubmit,
}: {
  studentId: number;
  onClose: () => void;
  onSubmit: (data: any) => Promise<{ error?: string }>;
}) {
  const [form, setForm] = useState({
    amountPaid: "",
    paymentMethod: "Mobile Money",
    referenceNumber: "",
    academicYear: "2025/2026",
    semester: "First Semester",
  });
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  function update(field: string, value: string) {
    setForm((f) => ({ ...f, [field]: value }));
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    setLoading(true);
    const result = await onSubmit({ ...form, studentId, amountPaid: Number(form.amountPaid) });
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
          <h2 className="font-semibold text-textprimary">Record Payment</h2>
          <button onClick={onClose} className="text-textsecondary hover:text-textprimary">
            <FiX className="h-5 w-5" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          {error && <ErrorMessage message={error} />}

          <div>
            <label className="label">Amount (GHS)</label>
            <input type="number" min="1" step="0.01" required className="input" value={form.amountPaid} onChange={(e) => update("amountPaid", e.target.value)} />
          </div>

          <div>
            <label className="label">Payment method</label>
            <select className="input" value={form.paymentMethod} onChange={(e) => update("paymentMethod", e.target.value)}>
              <option>Mobile Money</option>
              <option>Bank Transfer</option>
              <option>Card</option>
              <option>Cash</option>
              <option>University Portal</option>
            </select>
          </div>

          <div>
            <label className="label">Reference number</label>
            <input required className="input" value={form.referenceNumber} onChange={(e) => update("referenceNumber", e.target.value)} placeholder="e.g. MM-2026-0001" />
          </div>

          <div className="flex gap-3 pt-2">
            <Button type="button" variant="secondary" onClick={onClose} className="flex-1">
              Cancel
            </Button>
            <Button type="submit" variant="success" loading={loading} className="flex-1">
              Record Payment
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
}
