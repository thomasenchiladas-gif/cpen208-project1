"use client";

import { useState } from "react";
import { FiSearch, FiBell, FiLogOut, FiMenu, FiChevronDown } from "react-icons/fi";
import { useAuth } from "@/context/AuthContext";

export default function TopNav({ onMenuClick }: { onMenuClick: () => void }) {
  const { user, logout } = useAuth();
  const [menuOpen, setMenuOpen] = useState(false);

  const initials =
    user?.fullName
      ?.split(" ")
      .map((p) => p[0])
      .slice(0, 2)
      .join("")
      .toUpperCase() || "?";

  return (
    <header className="sticky top-0 z-20 h-16 bg-white border-b border-borderc flex items-center justify-between px-4 sm:px-6">
      <div className="flex items-center gap-3 flex-1">
        <button className="lg:hidden text-textsecondary" onClick={onMenuClick} aria-label="Open menu">
          <FiMenu className="h-6 w-6" />
        </button>
        <div className="relative hidden sm:block w-full max-w-xs">
          <FiSearch className="absolute left-3 top-1/2 -translate-y-1/2 text-textsecondary h-4 w-4" />
          <input
            type="search"
            placeholder="Search..."
            className="input pl-9 py-2 bg-slate-50"
          />
        </div>
      </div>

      <div className="flex items-center gap-4">
        <button
          className="relative text-textsecondary hover:text-textprimary transition"
          aria-label="Notifications"
        >
          <FiBell className="h-5 w-5" />
          <span className="absolute -top-1 -right-1 h-2 w-2 rounded-full bg-danger" />
        </button>

        <div className="relative">
          <button
            className="flex items-center gap-2"
            onClick={() => setMenuOpen((v) => !v)}
          >
            <div className="h-9 w-9 rounded-full bg-gradient-to-br from-primary to-secondary text-white flex items-center justify-center text-xs font-bold">
              {initials}
            </div>
            <div className="hidden sm:block text-left">
              <p className="text-sm font-semibold text-textprimary leading-tight">{user?.fullName}</p>
              <p className="text-xs text-textsecondary capitalize leading-tight">{user?.role}</p>
            </div>
            <FiChevronDown className="hidden sm:block h-4 w-4 text-textsecondary" />
          </button>

          {menuOpen && (
            <>
              <div className="fixed inset-0 z-10" onClick={() => setMenuOpen(false)} />
              <div className="absolute right-0 mt-2 w-44 rounded-lg border border-borderc bg-white shadow-lg z-20 animate-fade-in overflow-hidden">
                <button
                  onClick={logout}
                  className="flex w-full items-center gap-2 px-4 py-2.5 text-sm text-danger hover:bg-danger/5 transition"
                >
                  <FiLogOut className="h-4 w-4" />
                  Log out
                </button>
              </div>
            </>
          )}
        </div>
      </div>
    </header>
  );
}
