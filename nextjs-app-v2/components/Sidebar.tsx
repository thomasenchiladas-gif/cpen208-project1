"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  FiHome, FiUsers, FiDollarSign, FiBook, FiUser, FiX,
} from "react-icons/fi";
import { useAuth } from "@/context/AuthContext";

const studentLinks = [
  { href: "/dashboard", label: "Dashboard", icon: FiHome },
  { href: "/fees", label: "My Fees", icon: FiDollarSign },
  { href: "/courses", label: "Courses", icon: FiBook },
  { href: "/profile", label: "Profile", icon: FiUser },
];

const lecturerLinks = [
  { href: "/dashboard", label: "Dashboard", icon: FiHome },
  { href: "/students", label: "Students", icon: FiUsers },
  { href: "/fees", label: "Fees", icon: FiDollarSign },
  { href: "/courses", label: "Courses", icon: FiBook },
  { href: "/profile", label: "Profile", icon: FiUser },
];

export default function Sidebar({ mobileOpen, onClose }: { mobileOpen: boolean; onClose: () => void }) {
  const { user } = useAuth();
  const pathname = usePathname();
  const links = user?.role === "lecturer" ? lecturerLinks : studentLinks;

  return (
    <>
      {/* Mobile backdrop */}
      {mobileOpen && (
        <div className="fixed inset-0 z-30 bg-black/40 lg:hidden" onClick={onClose} />
      )}

      <aside
        className={`fixed z-40 inset-y-0 left-0 w-[280px] bg-sidebar text-white flex flex-col
          transition-transform duration-200 lg:translate-x-0
          ${mobileOpen ? "translate-x-0" : "-translate-x-full"}`}
      >
        <div className="flex items-center justify-between px-6 h-16 border-b border-white/10">
          <div className="flex items-center gap-2">
            <div className="h-8 w-8 rounded-lg bg-gradient-to-br from-primary to-secondary flex items-center justify-center font-bold text-sm">
              CE
            </div>
            <span className="font-semibold tracking-tight">STUDENT MANAGEMENT SYSTEM</span>
          </div>
          <button className="lg:hidden text-white/70 hover:text-white" onClick={onClose} aria-label="Close menu">
            <FiX className="h-5 w-5" />
          </button>
        </div>

        <nav className="flex-1 px-3 py-6 space-y-1">
          {links.map(({ href, label, icon: Icon }) => {
            const active = pathname === href;
            return (
              <Link
                key={href}
                href={href}
                onClick={onClose}
                className={`flex items-center gap-3 rounded-lg px-3.5 py-2.5 text-sm font-medium transition-all
                  ${
                    active
                      ? "bg-gradient-to-r from-primary to-secondary text-white shadow-md"
                      : "text-slate-300 hover:bg-white/5 hover:text-white"
                  }`}
              >
                <Icon className="h-[18px] w-[18px]" />
                {label}
              </Link>
            );
          })}
        </nav>

        <div className="px-6 py-4 border-t border-white/10 text-xs text-slate-400">
          University of Ghana
          <br />
          Computer Engineering
        </div>
      </aside>
    </>
  );
}
