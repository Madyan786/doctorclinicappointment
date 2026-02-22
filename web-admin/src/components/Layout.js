import React, { useState, useEffect } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { signOut } from 'firebase/auth';
import { collection, query, where, onSnapshot } from 'firebase/firestore';
import { auth, db } from '../firebase';
import {
  LayoutDashboard, Users, Calendar, Star, Stethoscope,
  Settings, LogOut, Search, Bell, Menu, X
} from 'lucide-react';

const navItems = [
  { path: '/', label: 'Dashboard', icon: LayoutDashboard, section: 'main' },
  { path: '/doctors', label: 'Doctors', icon: Stethoscope, section: 'management', badgeKey: 'pendingDoctors' },
  { path: '/appointments', label: 'Appointments', icon: Calendar, section: 'management', badgeKey: 'pendingAppointments' },
  { path: '/users', label: 'Users', icon: Users, section: 'management' },
  { path: '/reviews', label: 'Reviews', icon: Star, section: 'management', badgeKey: 'pendingReviews' },
  { path: '/settings', label: 'Settings', icon: Settings, section: 'settings' },
];

export default function Layout({ children, adminData }) {
  const navigate = useNavigate();
  const location = useLocation();
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [badges, setBadges] = useState({});

  useEffect(() => {
    const unsubs = [];

    // Pending doctors count
    const doctorsQ = query(collection(db, 'doctors'), where('verificationStatus', '==', 'pending'));
    unsubs.push(onSnapshot(doctorsQ, (snap) => {
      setBadges(prev => ({ ...prev, pendingDoctors: snap.size }));
    }));

    // Pending appointments count
    const apptsQ = query(collection(db, 'appointments'), where('status', '==', 'pending'));
    unsubs.push(onSnapshot(apptsQ, (snap) => {
      setBadges(prev => ({ ...prev, pendingAppointments: snap.size }));
    }));

    // Pending reviews count
    const reviewsQ = query(collection(db, 'reviews'), where('isApproved', '==', false));
    unsubs.push(onSnapshot(reviewsQ, (snap) => {
      setBadges(prev => ({ ...prev, pendingReviews: snap.size }));
    }));

    return () => unsubs.forEach(u => u());
  }, []);

  const handleLogout = async () => {
    await signOut(auth);
    navigate('/login');
  };

  const getPageTitle = () => {
    const path = location.pathname;
    if (path === '/') return { title: 'Dashboard', subtitle: 'Overview of your clinic' };
    if (path === '/doctors') return { title: 'Doctors', subtitle: 'Manage all doctors' };
    if (path.startsWith('/doctors/')) return { title: 'Doctor Details', subtitle: 'View doctor profile' };
    if (path === '/appointments') return { title: 'Appointments', subtitle: 'Manage appointments' };
    if (path === '/users') return { title: 'Users', subtitle: 'Registered patients' };
    if (path === '/reviews') return { title: 'Reviews', subtitle: 'Moderate reviews' };
    if (path === '/settings') return { title: 'Settings', subtitle: 'Admin settings' };
    return { title: 'Admin Panel', subtitle: '' };
  };

  const { title, subtitle } = getPageTitle();

  const renderNavSection = (sectionName, label) => {
    const items = navItems.filter(i => i.section === sectionName);
    if (items.length === 0) return null;
    return (
      <div key={sectionName}>
        {label && <div className="sidebar-section-title">{label}</div>}
        {items.map((item) => {
          const Icon = item.icon;
          const isActive = location.pathname === item.path ||
            (item.path !== '/' && location.pathname.startsWith(item.path));
          const badgeCount = item.badgeKey ? badges[item.badgeKey] : 0;
          return (
            <div
              key={item.path}
              className={`sidebar-link ${isActive ? 'active' : ''}`}
              onClick={() => { navigate(item.path); setSidebarOpen(false); }}
            >
              <Icon size={20} />
              <span>{item.label}</span>
              {badgeCount > 0 && <span className="sidebar-badge">{badgeCount}</span>}
            </div>
          );
        })}
      </div>
    );
  };

  return (
    <div className="app-layout">
      {/* Mobile overlay */}
      {sidebarOpen && (
        <div
          style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.5)', zIndex: 99 }}
          onClick={() => setSidebarOpen(false)}
        />
      )}

      {/* Sidebar */}
      <aside className={`sidebar ${sidebarOpen ? 'open' : ''}`}>
        <div className="sidebar-header">
          <div className="sidebar-logo">
            <div className="sidebar-logo-icon">
              <Stethoscope size={22} />
            </div>
            <div className="sidebar-logo-text">
              <h2>Doctor Clinic</h2>
              <p>Admin Panel</p>
            </div>
          </div>
        </div>

        <nav className="sidebar-nav">
          {renderNavSection('main', 'Main')}
          {renderNavSection('management', 'Management')}
          {renderNavSection('settings', 'System')}
        </nav>

        <div className="sidebar-footer">
          <div className="sidebar-user">
            <div className="sidebar-user-avatar">
              {(adminData?.name || 'A').charAt(0).toUpperCase()}
            </div>
            <div className="sidebar-user-info">
              <h4>{adminData?.name || 'Admin'}</h4>
              <p>{adminData?.role || 'admin'}</p>
            </div>
            <button className="sidebar-logout" onClick={handleLogout} title="Logout">
              <LogOut size={16} />
            </button>
          </div>
        </div>
      </aside>

      {/* Main Content */}
      <div className="main-content">
        <header className="topbar">
          <div style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
            <button
              className="topbar-icon-btn"
              style={{ display: 'none' }}
              onClick={() => setSidebarOpen(!sidebarOpen)}
              id="mobile-menu-btn"
            >
              {sidebarOpen ? <X size={18} /> : <Menu size={18} />}
            </button>
            <div className="topbar-left">
              <h1>{title}</h1>
              <p>{subtitle}</p>
            </div>
          </div>
          <div className="topbar-right">
            <div className="topbar-search">
              <Search size={16} color="#8b8b8b" />
              <input type="text" placeholder="Search..." />
            </div>
            <button className="topbar-icon-btn">
              <Bell size={18} />
              {(badges.pendingDoctors > 0 || badges.pendingReviews > 0) && (
                <span className="topbar-notification-dot" />
              )}
            </button>
          </div>
        </header>

        <div className="page-content">
          {children}
        </div>
      </div>

      <style>{`
        @media (max-width: 768px) {
          #mobile-menu-btn { display: flex !important; }
        }
      `}</style>
    </div>
  );
}
