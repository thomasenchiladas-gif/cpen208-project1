import { FiAlertCircle } from "react-icons/fi";

export default function ErrorMessage({ message }: { message: string }) {
  if (!message) return null;
  return (
    <div className="flex items-start gap-2 rounded-lg border border-danger/30 bg-danger/5 px-4 py-3 text-sm text-danger animate-fade-in">
      <FiAlertCircle className="mt-0.5 shrink-0" />
      <span>{message}</span>
    </div>
  );
}
