export default function FeeTable({ payments }: { payments: any[] }) {
  return (
    <div className="overflow-x-auto">
      <table className="w-full text-sm">
        <thead>
          <tr className="text-left text-xs uppercase tracking-wide text-textsecondary border-b border-borderc">
            <th className="pb-3 font-semibold">Date</th>
            <th className="pb-3 font-semibold">Reference</th>
            <th className="pb-3 font-semibold">Method</th>
            <th className="pb-3 font-semibold">Semester</th>
            <th className="pb-3 font-semibold text-right">Amount</th>
          </tr>
        </thead>
        <tbody>
          {payments.map((p, i) => (
            <tr key={p.payment_id} className={`border-b border-borderc last:border-0 ${i % 2 ? "bg-slate-50/50" : ""} hover:bg-primary/5 transition`}>
              <td className="py-3 text-textsecondary">{new Date(p.payment_date).toLocaleDateString()}</td>
              <td className="py-3 font-mono text-xs text-textsecondary">{p.reference_number}</td>
              <td className="py-3 text-textsecondary">{p.payment_method}</td>
              <td className="py-3 text-textsecondary">{p.academic_year} &middot; {p.semester}</td>
              <td className="py-3 text-right font-semibold text-success">GHS {Number(p.amount_paid).toLocaleString()}</td>
            </tr>
          ))}
          {payments.length === 0 && (
            <tr>
              <td colSpan={5} className="py-8 text-center text-textsecondary">
                No payments recorded yet.
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}
