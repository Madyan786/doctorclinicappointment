import React, { useState } from 'react';
import { updatePassword, EmailAuthProvider, reauthenticateWithCredential } from 'firebase/auth';
import { auth } from '../firebase';
import {
  User, Lock, Shield, Save, Eye, EyeOff, CheckCircle
} from 'lucide-react';

export default function Settings({ adminData }) {
  const [currentPassword, setCurrentPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [showCurrent, setShowCurrent] = useState(false);
  const [showNew, setShowNew] = useState(false);
  const [loading, setLoading] = useState(false);
  const [toast, setToast] = useState(null);

  const showToast = (msg, type = 'success') => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3000);
  };

  const handleChangePassword = async (e) => {
    e.preventDefault();
    if (newPassword !== confirmPassword) {
      showToast('Passwords do not match', 'error');
      return;
    }
    if (newPassword.length < 6) {
      showToast('Password must be at least 6 characters', 'error');
      return;
    }

    setLoading(true);
    try {
      const user = auth.currentUser;
      const credential = EmailAuthProvider.credential(user.email, currentPassword);
      await reauthenticateWithCredential(user, credential);
      await updatePassword(user, newPassword);
      showToast('Password updated successfully');
      setCurrentPassword('');
      setNewPassword('');
      setConfirmPassword('');
    } catch (err) {
      console.error('Password change error:', err);
      if (err.code === 'auth/wrong-password' || err.code === 'auth/invalid-credential') {
        showToast('Current password is incorrect', 'error');
      } else {
        showToast('Failed to update password. Please try again.', 'error');
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ maxWidth: 700 }}>
      {/* Admin Profile */}
      <div className="card" style={{ marginBottom: 24 }}>
        <h3 style={{ fontSize: 16, fontWeight: 700, marginBottom: 20, display: 'flex', alignItems: 'center', gap: 8 }}>
          <User size={18} /> Admin Profile
        </h3>

        <div style={{ display: 'flex', alignItems: 'center', gap: 20, marginBottom: 24 }}>
          <div style={{
            width: 72, height: 72, borderRadius: 18,
            background: 'linear-gradient(135deg, #667eea, #764ba2)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            color: 'white', fontSize: 28, fontWeight: 700
          }}>
            {(adminData?.name || 'A').charAt(0).toUpperCase()}
          </div>
          <div>
            <h2 style={{ fontSize: 20, fontWeight: 700 }}>{adminData?.name || 'Admin'}</h2>
            <p style={{ fontSize: 14, color: '#8b8b8b' }}>{auth.currentUser?.email || 'admin@doctorclinic.com'}</p>
            <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginTop: 6 }}>
              <Shield size={14} color="#667eea" />
              <span style={{ fontSize: 12, color: '#667eea', fontWeight: 600, textTransform: 'capitalize' }}>
                {adminData?.role || 'admin'}
              </span>
            </div>
          </div>
        </div>

        <div className="detail-grid">
          <div className="detail-field">
            <label>Name</label>
            <span>{adminData?.name || 'Admin'}</span>
          </div>
          <div className="detail-field">
            <label>Email</label>
            <span>{adminData?.email || auth.currentUser?.email || 'N/A'}</span>
          </div>
          <div className="detail-field">
            <label>Role</label>
            <span style={{ textTransform: 'capitalize' }}>{adminData?.role || 'admin'}</span>
          </div>
          <div className="detail-field">
            <label>Admin ID</label>
            <span style={{ fontSize: 12, color: '#8b8b8b' }}>{adminData?.id || auth.currentUser?.uid || 'N/A'}</span>
          </div>
        </div>
      </div>

      {/* Change Password */}
      <div className="card" style={{ marginBottom: 24 }}>
        <h3 style={{ fontSize: 16, fontWeight: 700, marginBottom: 20, display: 'flex', alignItems: 'center', gap: 8 }}>
          <Lock size={18} /> Change Password
        </h3>

        <form onSubmit={handleChangePassword}>
          <div className="form-group">
            <label>Current Password</label>
            <div style={{ position: 'relative' }}>
              <input
                type={showCurrent ? 'text' : 'password'}
                value={currentPassword}
                onChange={e => setCurrentPassword(e.target.value)}
                placeholder="Enter current password"
                required
                style={{ paddingRight: 40 }}
              />
              <button
                type="button"
                onClick={() => setShowCurrent(!showCurrent)}
                style={{
                  position: 'absolute', right: 12, top: '50%', transform: 'translateY(-50%)',
                  background: 'none', border: 'none', cursor: 'pointer', color: '#8b8b8b', padding: 0
                }}
              >
                {showCurrent ? <EyeOff size={16} /> : <Eye size={16} />}
              </button>
            </div>
          </div>

          <div className="form-row">
            <div className="form-group">
              <label>New Password</label>
              <div style={{ position: 'relative' }}>
                <input
                  type={showNew ? 'text' : 'password'}
                  value={newPassword}
                  onChange={e => setNewPassword(e.target.value)}
                  placeholder="Enter new password"
                  required
                  minLength={6}
                  style={{ paddingRight: 40 }}
                />
                <button
                  type="button"
                  onClick={() => setShowNew(!showNew)}
                  style={{
                    position: 'absolute', right: 12, top: '50%', transform: 'translateY(-50%)',
                    background: 'none', border: 'none', cursor: 'pointer', color: '#8b8b8b', padding: 0
                  }}
                >
                  {showNew ? <EyeOff size={16} /> : <Eye size={16} />}
                </button>
              </div>
            </div>
            <div className="form-group">
              <label>Confirm New Password</label>
              <input
                type="password"
                value={confirmPassword}
                onChange={e => setConfirmPassword(e.target.value)}
                placeholder="Confirm new password"
                required
                minLength={6}
              />
            </div>
          </div>

          <div className="form-actions" style={{ justifyContent: 'flex-start' }}>
            <button type="submit" className="btn btn-primary" disabled={loading}>
              <Save size={16} /> {loading ? 'Updating...' : 'Update Password'}
            </button>
          </div>
        </form>
      </div>

      {/* App Info */}
      <div className="card">
        <h3 style={{ fontSize: 16, fontWeight: 700, marginBottom: 20, display: 'flex', alignItems: 'center', gap: 8 }}>
          <CheckCircle size={18} /> Application Info
        </h3>

        <div className="detail-grid">
          <div className="detail-field">
            <label>App Name</label>
            <span>Doctor Clinic Admin Panel</span>
          </div>
          <div className="detail-field">
            <label>Version</label>
            <span>1.0.0</span>
          </div>
          <div className="detail-field">
            <label>Framework</label>
            <span>React 18</span>
          </div>
          <div className="detail-field">
            <label>Backend</label>
            <span>Firebase (Firestore + Auth + Storage)</span>
          </div>
          <div className="detail-field">
            <label>Mobile App</label>
            <span>Flutter (Android & iOS)</span>
          </div>
          <div className="detail-field">
            <label>Database</label>
            <span>Cloud Firestore</span>
          </div>
        </div>

        <div style={{ marginTop: 20, padding: 16, background: '#f0f2ff', borderRadius: 12, fontSize: 13, color: '#667eea' }}>
          <strong>Note:</strong> Any changes made in the admin panel will reflect in the mobile app in real-time through Firebase.
        </div>
      </div>

      {/* Toast */}
      {toast && <div className={`toast toast-${toast.type}`}>{toast.msg}</div>}
    </div>
  );
}
