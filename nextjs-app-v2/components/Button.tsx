import { ButtonHTMLAttributes } from "react";
import LoadingSpinner from "./LoadingSpinner";

type Variant = "primary" | "secondary" | "danger" | "success";

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: Variant;
  loading?: boolean;
}

const variantClass: Record<Variant, string> = {
  primary: "btn-primary",
  secondary: "btn-secondary",
  danger: "btn-danger",
  success: "btn-success",
};

export default function Button({ variant = "primary", loading, disabled, children, className = "", ...rest }: ButtonProps) {
  return (
    <button className={`${variantClass[variant]} ${className}`} disabled={disabled || loading} {...rest}>
      {loading && <LoadingSpinner size="sm" />}
      {children}
    </button>
  );
}
