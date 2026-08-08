"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { FiUser, FiMail, FiLock, FiHash, FiPhone } from "react-icons/fi";
import { useAuth } from "@/context/AuthContext";
import Button from "@/components/Button";
import ErrorMessage from "@/components/ErrorMessage";

export default function RegisterPage() {
  const { register } = useAuth();
  const router = useRouter();
  const [form, setForm] = useState({
    firstName: "", lastName: "", indexNumber: "", email: "", phone: "", password: "", confirmPassword: "",
  });
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  function update(field: string, value: string) {
    setForm((f) => ({ ...f, [field]: value }));
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");

    if (form.password !== form.confirmPassword) {
      setError("Passwords do not match.");
      return;
    }
    if (form.password.length < 8) {
      setError("Password must be at least 8 characters.");
      return;
    }

    setLoading(true);
    const result = await register({
      firstName: form.firstName,
      lastName: form.lastName,
      indexNumber: form.indexNumber,
      email: form.email,
      phone: form.phone || undefined,
      password: form.password,
      level: 200,
    });
    setLoading(false);
    if (result.error) {
      setError(result.error);
      return;
    }
    router.push("/dashboard");
  }

  return (
    <main className="min-h-screen flex items-center justify-center bg-gradient-to-br from-background via-background to-primary/5 px-4 py-12">
      <div className="w-full max-w-lg">
        <div className="text-center mb-8">
          <div className="mx-auto h-12 w-12 rounded-xl bg-gradient-to-br from-primary to-secondary flex items-center justify-center text-white font-bold mb-4">
            CE
          </div>
          <h1 className="text-2xl font-bold text-textprimary">Create your account</h1>
          <p className="text-textsecondary text-sm mt-1">Register as a  student</p>
        </div>

        <form onSubmit={handleSubmit} className="card p-8 space-y-5 animate-fade-in">
          {error && <ErrorMessage message={error} />}

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="label">First name</label>
              <div className="relative">
                <FiUser className="absolute left-3.5 top-1/2 -translate-y-1/2 text-textsecondary h-4 w-4" />
                <input required className="input pl-10" value={form.firstName} onChange={(e) => update("firstName", e.target.value)} />
              </div>
            </div>
            <div>
              <label className="label">Last name</label>
              <input required className="input" value={form.lastName} onChange={(e) => update("lastName", e.target.value)} />
            </div>
          </div>

          <div>
            <label className="label">Index number</label>
            <div className="relative">
              <FiHash className="absolute left-3.5 top-1/2 -translate-y-1/2 text-textsecondary h-4 w-4" />
              <input required className="input pl-10" value={form.indexNumber} onChange={(e) => update("indexNumber", e.target.value)} />
            </div>
          </div>

          <div>
            <label className="label">Email</label>
            <div className="relative">
              <FiMail className="absolute left-3.5 top-1/2 -translate-y-1/2 text-textsecondary h-4 w-4" />
              <input type="email" required className="input pl-10" value={form.email} onChange={(e) => update("email", e.target.value)} />
            </div>
          </div>

          <div>
            <label className="label">Phone (optional)</label>
            <div className="relative">
              <FiPhone className="absolute left-3.5 top-1/2 -translate-y-1/2 text-textsecondary h-4 w-4" />
              <input className="input pl-10" value={form.phone} onChange={(e) => update("phone", e.target.value)} />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="label">Password</label>
              <div className="relative">
                <FiLock className="absolute left-3.5 top-1/2 -translate-y-1/2 text-textsecondary h-4 w-4" />
                <input type="password" required minLength={8} className="input pl-10" value={form.password} onChange={(e) => update("password", e.target.value)} />
              </div>
            </div>
            <div>
              <label className="label">Confirm password</label>
              <input type="password" required minLength={8} className="input" value={form.confirmPassword} onChange={(e) => update("confirmPassword", e.target.value)} />
            </div>
          </div>

          <Button type="submit" variant="primary" loading={loading} className="w-full">
            Create account
          </Button>
        </form>

        <p className="text-center text-sm text-textsecondary mt-6">
          Already registered?{" "}
          <Link href="/login" className="text-primary font-semibold hover:underline">
            Sign in
          </Link>
        </p>
      </div>
    </main>
  );
}
