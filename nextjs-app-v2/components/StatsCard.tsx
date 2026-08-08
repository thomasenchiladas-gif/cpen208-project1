import { IconType } from "react-icons";

type Tone = "primary" | "success" | "warning" | "danger" | "secondary";

const toneClasses: Record<Tone, { border: string; iconBg: string; iconColor: string }> = {
  primary: { border: "border-l-primary", iconBg: "bg-primary/10", iconColor: "text-primary" },
  success: { border: "border-l-success", iconBg: "bg-success/10", iconColor: "text-success" },
  warning: { border: "border-l-warning", iconBg: "bg-warning/10", iconColor: "text-warning" },
  danger: { border: "border-l-danger", iconBg: "bg-danger/10", iconColor: "text-danger" },
  secondary: { border: "border-l-secondary", iconBg: "bg-secondary/10", iconColor: "text-secondary" },
};

export default function StatsCard({
  label,
  value,
  icon: Icon,
  tone = "primary",
}: {
  label: string;
  value: string | number;
  icon: IconType;
  tone?: Tone;
}) {
  const t = toneClasses[tone];
  return (
    <div className={`card p-5 border-l-4 ${t.border} animate-fade-in`}>
      <div className="flex items-center justify-between">
        <div>
          <p className="text-xs font-semibold uppercase tracking-wide text-textsecondary">{label}</p>
          <p className="mt-1.5 text-2xl font-bold text-textprimary">{value}</p>
        </div>
        <div className={`flex h-11 w-11 items-center justify-center rounded-xl ${t.iconBg}`}>
          <Icon className={`h-5 w-5 ${t.iconColor}`} />
        </div>
      </div>
    </div>
  );
}
