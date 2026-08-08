"use client";

import { useEffect, useState } from "react";
import { FiUser, FiMail, FiPhone, FiHash, FiLock } from "react-icons/fi";
import { useAuth } from "@/context/AuthContext";
import Card from "@/components/Card";
import Button from "@/components/Button";
import LoadingSpinner from "@/components/LoadingSpinner";
import ErrorMessage from "@/components/ErrorMessage";

export default function ProfilePage() {
  const { user, authFetch } = useAuth();
  const [profile, setProfile] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const [phone, setPhone] = useState("");
  const [hall, setHall] = useState("");
  const [savingProfile, setSavingProfile] = useState(false);
  const [profileMsg, setProfileMsg] = useState("");

  const [currentPassword, setCurrentPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [pwError, setPwError] = useState("");
  const [pwSuccess, setPwSuccess] = useState("");
  const [changingPw, setChangingPw] = useState(false);

  useEffect(() => {
    let cancelled = false;
    async function load() {
      setLoading(true);
      setError("");
      try {
        const res = await authFetch("/api/auth/me");
        if (!res.ok) throw new Error("Failed to load profile.");
        const data = await res.json();
        if (cancelled) return;
        setProfile(data.profile);
        setPhone(data.profile?.phone || "");
        setHall(data.profile?.hall_of_residence || "");
      } catch (e: any) {
        if (!cancelled) setError(e.message);
      } finally {
        if (!cancelled) setLoading(false);
      }
    }
    if (user) load();
    return () => {
      cancelled = true;
    };
  }, [user, authFetch]);

  async function handleSaveProfile(e: React.FormEvent) {
    e.preventDefault();
    setProfileMsg("");
    setSavingProfile(true);
    try {
      const res = await authFetch(`/api/students/${profile.student_id}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ phone, hallOfResidence: hall }),
      });
      if (!res.ok) throw new Error("Failed to update profile.");
      setProfileMsg("Profile updated.");
    } catch (e: any) {
      setProfileMsg(e.message);
    } finally {
      setSavingProfile(false);
    }
  }

  async function handleChangePassword(e: React.FormEvent) {
    e.preventDefault();
    setPwError("");
    setPwSuccess("");
    if (newPassword !== confirmPassword) {
      setPwError("New passwords do not match.");
      return;
    }
    if (newPassword.length < 8) {
      setPwError("New password must be at least 8 characters.");
      return;
    }
    setChangingPw(true);
    try {
      const res = await authFetch("/api/auth/change-password", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ currentPassword, newPassword }),
      });
      const body = await res.json().catch(() => ({}));
      if (!res.ok) {
        setPwError(body.error || "Failed to change password.");
      } else {
        setPwSuccess("Password updated successfully.");
        setCurrentPassword("");
        setNewPassword("");
        setConfirmPassword("");
      }
    } catch {
      setPwError("Failed to change password.");
    } finally {
      setChangingPw(false);
    }
  }

  if (loading) {
    return (
      <div className="flex justify-center py-24">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  return (
    <div className="space-y-6 animate-fade-in max-w-2xl">
      <div>
        <h1 className="text-2xl font-bold text-textprimary">Profile</h1>
        <p className="text-textsecondary text-sm mt-1">Manage your account information</p>
      </div>

      {error && <ErrorMessage message={error} />}

      <Card>
        <h2 className="font-semibold text-textprimary mb-4">Account Information</h2>
        <div className="grid grid-cols-2 gap-4 text-sm mb-2">
          <InfoRow icon={FiUser} label="Name" value={user?.fullName} />
          <InfoRow icon={FiHash} label={user?.role === "lecturer" ? "Staff ID" : "Index Number"} value={profile?.index_number || profile?.staff_id} />
          <InfoRow icon={FiMail} label="Email" value={user?.email} />
          <InfoRow icon={FiUser} label="Role" value={user?.role} capitalize />
        </div>
      </Card>

      {user?.role === "student" && (
        <Card>
          <h2 className="font-semibold text-textprimary mb-4">Edit Profile</h2>
          <form onSubmit={handleSaveProfile} className="space-y-4">
            <div>
              <label className="label">Phone</label>
              <div className="relative">
                <FiPhone className="absolute left-3.5 top-1/2 -translate-y-1/2 text-textsecondary h-4 w-4" />
                <input className="input pl-10" value={phone} onChange={(e) => setPhone(e.target.value)} />
              </div>
            </div>
            <div>
              <label className="label">Hall of Residence</label>
              <input className="input" value={hall} onChange={(e) => setHall(e.target.value)} />
            </div>
            {profileMsg && <p className="text-sm text-textsecondary">{profileMsg}</p>}
            <Button type="submit" variant="primary" loading={savingProfile}>
              Save Changes
            </Button>
          </form>
        </Card>
      )}

      <Card>
        <h2 className="font-semibold text-textprimary mb-4">Change Password</h2>
        <form onSubmit={handleChangePassword} className="space-y-4">
          {pwError && <ErrorMessage message={pwError} />}
          {pwSuccess && <p className="text-sm text-success">{pwSuccess}</p>}
          <div>
            <label className="label">Current password</label>
            <div className="relative">
              <FiLock className="absolute left-3.5 top-1/2 -translate-y-1/2 text-textsecondary h-4 w-4" />
              <input type="password" required className="input pl-10" value={currentPassword} onChange={(e) => setCurrentPassword(e.target.value)} />
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="label">New password</label>
              <input type="password" required minLength={8} className="input" value={newPassword} onChange={(e) => setNewPassword(e.target.value)} />
            </div>
            <div>
              <label className="label">Confirm new password</label>
              <input type="password" required minLength={8} className="input" value={confirmPassword} onChange={(e) => setConfirmPassword(e.target.value)} />
            </div>
          </div>
          <Button type="submit" variant="secondary" loading={changingPw}>
            Update Password
          </Button>
        </form>
      </Card>
    </div>
  );
}

function InfoRow({ icon: Icon, label, value, capitalize }: { icon: any; label: string; value?: string; capitalize?: boolean }) {
  return (
    <div className="flex items-start gap-2.5 py-2">
      <Icon className="h-4 w-4 text-textsecondary mt-0.5" />
      <div>
        <p className="text-xs text-textsecondary">{label}</p>
        <p className={`font-medium text-textprimary ${capitalize ? "capitalize" : ""}`}>{value || "—"}</p>
      </div>
    </div>
  );
}
