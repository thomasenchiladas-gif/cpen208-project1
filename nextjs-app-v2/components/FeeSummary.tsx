type Fee = {
  amount_billed: number | string;
  amount_paid: number | string;
  outstanding_balance: number | string;
  academic_year?: string;
  semester?: string;
};

export default function FeeSummary({ fee }: { fee: Fee | null }) {
  if (!fee) {
    return <p className="text-sm text-textsecondary">No fee record found.</p>;
  }

  const billed = Number(fee.amount_billed);
  const paid = Number(fee.amount_paid);
  const outstanding = Number(fee.outstanding_balance);
  const pct = billed > 0 ? Math.min(100, Math.round((paid / billed) * 100)) : 0;

  const status = outstanding <= 0 ? "Paid" : paid > 0 ? "Partial" : "Due";
  const badgeClass =
    status === "Paid" ? "badge-success" : status === "Partial" ? "badge-warning" : "badge-danger";

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <p className="text-xs text-textsecondary">
          {fee.academic_year} &middot; {fee.semester}
        </p>
        <span className={badgeClass}>{status}</span>
      </div>

      <div>
        <div className="flex justify-between text-xs text-textsecondary mb-1.5">
          <span>GHS {paid.toLocaleString()} paid</span>
          <span>GHS {billed.toLocaleString()} billed</span>
        </div>
        <div className="h-2.5 w-full rounded-full bg-slate-100 overflow-hidden">
          <div
            className="h-full rounded-full bg-gradient-to-r from-success to-emerald-400 transition-all duration-500"
            style={{ width: `${pct}%` }}
          />
        </div>
      </div>

      <div className="grid grid-cols-3 gap-3 text-center">
        <div className="rounded-lg border border-borderc p-3">
          <p className="text-[10px] uppercase tracking-wide text-textsecondary">Billed</p>
          <p className="text-sm font-bold text-textprimary">GHS {billed.toLocaleString()}</p>
        </div>
        <div className="rounded-lg border border-borderc p-3">
          <p className="text-[10px] uppercase tracking-wide text-textsecondary">Paid</p>
          <p className="text-sm font-bold text-success">GHS {paid.toLocaleString()}</p>
        </div>
        <div className={`rounded-lg border p-3 ${outstanding > 0 ? "border-danger/30 bg-danger/5" : "border-borderc"}`}>
          <p className="text-[10px] uppercase tracking-wide text-textsecondary">Outstanding</p>
          <p className={`text-sm font-bold ${outstanding > 0 ? "text-danger" : "text-textprimary"}`}>
            GHS {outstanding.toLocaleString()}
          </p>
        </div>
      </div>
    </div>
  );
}
