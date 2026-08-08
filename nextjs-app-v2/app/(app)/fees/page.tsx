"use client";

import { useEffect, useState, useCallback } from "react";
import { FiPlus } from "react-icons/fi";
import { useAuth } from "@/context/AuthContext";
import Card from "@/components/Card";
import Button from "@/components/Button";
import LoadingSpinner from "@/components/LoadingSpinner";
import ErrorMessage from "@/components/ErrorMessage";
import FeeSummary from "@/components/FeeSummary";
import FeeTable from "@/components/FeeTable";
import PayFeeModal from "@/components/PayFeeModal";

export default function FeesPage() {
  const { user, authFetch } = useAuth();
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [fee, setFee] = useState<any>(null);
  const [payments, setPayments] = useState<any[]>([]);
  const [allFees, setAllFees] = useState<any[]>([]);
  const [selectedStudent, setSelectedStudent] = useState<any>(null);
  const [showPayModal, setShowPayModal] = useState(false);

  const loadStudentView = useCallback(async () => {
    setLoading(true);
    setError("");
    try {
      const [feeRes, paymentsRes] = await Promise.all([
        authFetch("/api/fees/me"),
        authFetch("/api/fees/payments"),
      ]);
      if (!feeRes.ok || !paymentsRes.ok) throw new Error("Failed to load fee data.");
      setFee(await feeRes.json());
      setPayments(await paymentsRes.json());
    } catch (e: any) {
      setError(e.message);
    } finally {
      setLoading(false);
    }
  }, [authFetch]);

  const loadLecturerView = useCallback(async () => {
    setLoading(true);
    setError("");
    try {
      const res = await authFetch("/api/fees/outstanding");
      if (!res.ok) throw new Error("Failed to load fee data.");
      setAllFees(await res.json());
    } catch (e: any) {
      setError(e.message);
    } finally {
      setLoading(false);
    }
  }, [authFetch]);

  useEffect(() => {
    if (!user) return;
    if (user.role === "lecturer") loadLecturerView();
    else loadStudentView();
  }, [user, loadLecturerView, loadStudentView]);

  async function handlePayment(data: any) {
    const res = await authFetch("/api/fees/payments", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(data),
    });
    const body = await res.json().catch(() => ({}));
    if (!res.ok) return { error: body.error || "Failed to record payment." };
    await loadLecturerView();
    return {};
  }

  if (loading) {
    return (
      <div className="flex justify-center py-24">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  if (user?.role === "lecturer") {
    return (
      <div className="space-y-6 animate-fade-in">
        <div>
          <h1 className="text-2xl font-bold text-textprimary">Fee Management</h1>
          <p className="text-textsecondary text-sm mt-1">Outstanding balances across all students</p>
        </div>

        {error && <ErrorMessage message={error} />}

        <Card padded={false}>
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="text-left text-xs uppercase tracking-wide text-textsecondary border-b border-borderc">
                  <th className="p-4 font-semibold">Student</th>
                  <th className="p-4 font-semibold">Billed</th>
                  <th className="p-4 font-semibold">Paid</th>
                  <th className="p-4 font-semibold">Outstanding</th>
                  <th className="p-4 font-semibold">Status</th>
                  <th className="p-4 font-semibold text-right">Actions</th>
                </tr>
              </thead>
              <tbody>
                {allFees.map((f, i) => {
                  const outstanding = Number(f.outstanding_balance);
                  const status = outstanding <= 0 ? "Paid" : Number(f.amount_paid) > 0 ? "Partial" : "Due";
                  const badgeClass = status === "Paid" ? "badge-success" : status === "Partial" ? "badge-warning" : "badge-danger";
                  return (
                    <tr key={f.student_id} className={`border-b border-borderc last:border-0 ${i % 2 ? "bg-slate-50/50" : ""} hover:bg-primary/5 transition`}>
                      <td className="p-4 font-medium text-textprimary">{f.full_name}</td>
                      <td className="p-4 text-textsecondary">GHS {Number(f.amount_billed).toLocaleString()}</td>
                      <td className="p-4 text-success">GHS {Number(f.amount_paid).toLocaleString()}</td>
                      <td className="p-4 font-semibold text-danger">GHS {outstanding.toLocaleString()}</td>
                      <td className="p-4"><span className={badgeClass}>{status}</span></td>
                      <td className="p-4 text-right">
                        <Button
                          variant="secondary"
                          onClick={() => {
                            setSelectedStudent(f);
                            setShowPayModal(true);
                          }}
                        >
                          Record Payment
                        </Button>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </Card>

        {showPayModal && selectedStudent && (
          <PayFeeModal
            studentId={selectedStudent.student_id}
            onClose={() => setShowPayModal(false)}
            onSubmit={handlePayment}
          />
        )}
      </div>
    );
  }

  return (
    <div className="space-y-6 animate-fade-in">
      <div>
        <h1 className="text-2xl font-bold text-textprimary">My Fees</h1>
        <p className="text-textsecondary text-sm mt-1">Your fee balance and payment history</p>
      </div>

      {error && <ErrorMessage message={error} />}

      <Card>
        <h2 className="font-semibold text-textprimary mb-4">Fee Summary</h2>
        <FeeSummary fee={fee} />
      </Card>

      <Card>
        <h2 className="font-semibold text-textprimary mb-4">Payment History</h2>
        <FeeTable payments={payments} />
      </Card>
    </div>
  );
}
