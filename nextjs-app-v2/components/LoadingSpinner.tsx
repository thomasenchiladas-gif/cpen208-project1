export default function LoadingSpinner({ size = "md" }: { size?: "sm" | "md" | "lg" }) {
  const dims = { sm: "h-4 w-4 border-2", md: "h-8 w-8 border-[3px]", lg: "h-12 w-12 border-4" }[size];
  return (
    <div
      className={`${dims} animate-spin rounded-full border-primary/20 border-t-primary`}
      role="status"
      aria-label="Loading"
    />
  );
}
