import { FiSearch } from "react-icons/fi";

export default function StudentSearch({ value, onChange }: { value: string; onChange: (v: string) => void }) {
  return (
    <div className="relative w-full sm:max-w-xs">
      <FiSearch className="absolute left-3.5 top-1/2 -translate-y-1/2 text-textsecondary h-4 w-4" />
      <input
        type="search"
        placeholder="Search students..."
        value={value}
        onChange={(e) => onChange(e.target.value)}
        className="input pl-10"
      />
    </div>
  );
}
