import React, { useEffect, useState } from 'react';
import { collection, onSnapshot, query, where } from 'firebase/firestore';
import { db } from '../firebase';
import {
  Search, Users as UsersIcon, Mail, Phone, Calendar,
  Eye, X, MapPin, Droplets
} from 'lucide-react';

export default function Users() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [detailModal, setDetailModal] = useState(null);
  const [userAppointments, setUserAppointments] = useState([]);
  const [loadingAppts, setLoadingAppts] = useState(false);

  useEffect(() => {
    const unsub = onSnapshot(collection(db, 'users'), (snap) => {
      const list = snap.docs.map(d => ({ id: d.id, ...d.data() }));
      list.sort((a, b) => {
        const ta = a.createdAt?.toDate?.() || new Date(0);
        const tb = b.createdAt?.toDate?.() || new Date(0);
        return tb - ta;
      });
      setUsers(list);
      setLoading(false);
    });
    return () => unsub();
  }, []);

  const formatDate = (timestamp) => {
    if (!timestamp) return 'N/A';
    const date = timestamp.toDate ? timestamp.toDate() : new Date(timestamp);
    return date.toLocaleDateString('en-PK', { day: 'numeric', month: 'short', year: 'numeric' });
  };

  const filtered = users.filter(u =>
    u.name?.toLowerCase().includes(search.toLowerCase()) ||
    u.email?.toLowerCase().includes(search.toLowerCase()) ||
    u.phone?.toLowerCase().includes(search.toLowerCase())
  );

  const openDetail = (user) => {
    setDetailModal(user);
    setLoadingAppts(true);
    // Fetch user's appointments
    const q = query(collection(db, 'appointments'), where('patientId', '==', user.id));
    const unsub = onSnapshot(q, (snap) => {
      const list = snap.docs.map(d => ({ id: d.id, ...d.data() }));
      list.sort((a, b) => {
        const ta = a.appointmentDate?.toDate?.() || new Date(0);
        const tb = b.appointmentDate?.toDate?.() || new Date(0);
        return tb - ta;
      });
      setUserAppointments(list);
      setLoadingAppts(false);
    });
    // Store unsub to clean up when modal closes
    setDetailModal({ ...user, _unsub: unsub });
  };

  const closeDetail = () => {
    if (detailModal?._unsub) detailModal._unsub();
    setDetailModal(null);
    setUserAppointments([]);
  };

  if (loading) {
    return <div className="loading-spinner"><div className="spinner" /></div>;
  }

  return (
    <div>
      {/* Stats */}
      <div className="stats-grid" style={{ gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', marginBottom: 20 }}>
        <div className="stat-card stat-pink" style={{ padding: 20 }}>
          <div className="stat-card-icon"><UsersIcon size={20} color="white" /></div>
          <h3>{users.length}</h3>
          <p>Total Patients</p>
        </div>
        <div className="stat-card stat-green" style={{ padding: 20 }}>
          <div className="stat-card-icon"><Calendar size={20} color="white" /></div>
          <h3>{users.filter(u => {
            const d = u.createdAt?.toDate?.();
            if (!d) return false;
            const now = new Date();
            return d.getMonth() === now.getMonth() && d.getFullYear() === now.getFullYear();
          }).length}</h3>
          <p>New This Month</p>
        </div>
      </div>

      {/* Filters */}
      <div className="filters-bar">
        <div className="search-input">
          <Search size={16} color="#8b8b8b" />
          <input placeholder="Search users by name, email or phone..." value={search} onChange={e => setSearch(e.target.value)} style={{ width: 300 }} />
        </div>
        <div style={{ flex: 1 }} />
        <span style={{ fontSize: 13, color: '#8b8b8b' }}>
          Showing {filtered.length} of {users.length} users
        </span>
      </div>

      {/* Table */}
      <div className="card">
        {filtered.length === 0 ? (
          <div className="empty-state">
            <UsersIcon size={48} />
            <h3>No users found</h3>
            <p>{search ? 'Try a different search term' : 'No registered patients yet'}</p>
          </div>
        ) : (
          <table className="data-table">
            <thead>
              <tr>
                <th>User</th>
                <th>Email</th>
                <th>Phone</th>
                <th>Joined</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map(user => (
                <tr key={user.id}>
                  <td>
                    <div className="info-row">
                      <div className="avatar">
                        {user.profileImage ? (
                          <img src={user.profileImage} alt={user.name} />
                        ) : (
                          (user.name || 'U').charAt(0).toUpperCase()
                        )}
                      </div>
                      <div className="info-row-text">
                        <h4>{user.name || 'Unknown'}</h4>
                        <p style={{ fontSize: 10, color: '#aaa' }}>ID: {user.id.substring(0, 12)}...</p>
                      </div>
                    </div>
                  </td>
                  <td>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: 13 }}>
                      <Mail size={12} color="#8b8b8b" />
                      {user.email || 'N/A'}
                    </div>
                  </td>
                  <td>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: 13 }}>
                      <Phone size={12} color="#8b8b8b" />
                      {user.phone || 'N/A'}
                    </div>
                  </td>
                  <td style={{ whiteSpace: 'nowrap', fontSize: 13 }}>{formatDate(user.createdAt)}</td>
                  <td>
                    <button className="btn-icon" style={{ background: '#e3f2fd' }} onClick={() => openDetail(user)} title="View Details">
                      <Eye size={14} color="#1976d2" />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      {/* Detail Modal */}
      {detailModal && (
        <div className="modal-overlay" onClick={closeDetail}>
          <div className="modal" onClick={e => e.stopPropagation()} style={{ maxWidth: 650 }}>
            <div className="modal-header">
              <h2>Patient Details</h2>
              <button className="modal-close" onClick={closeDetail}><X size={16} /></button>
            </div>

            {/* User Info */}
            <div style={{ display: 'flex', alignItems: 'center', gap: 16, marginBottom: 24 }}>
              <div className="detail-avatar" style={{ width: 64, height: 64, fontSize: 24 }}>
                {detailModal.profileImage ? (
                  <img src={detailModal.profileImage} alt={detailModal.name} />
                ) : (
                  (detailModal.name || 'U').charAt(0).toUpperCase()
                )}
              </div>
              <div>
                <h3 style={{ fontSize: 18, fontWeight: 700 }}>{detailModal.name || 'Unknown'}</h3>
                <p style={{ fontSize: 13, color: '#8b8b8b' }}>Patient ID: {detailModal.id}</p>
              </div>
            </div>

            <div className="detail-grid" style={{ marginBottom: 24 }}>
              <div className="detail-field">
                <label>Email</label>
                <span>{detailModal.email || 'N/A'}</span>
              </div>
              <div className="detail-field">
                <label>Phone</label>
                <span>{detailModal.phone || 'N/A'}</span>
              </div>
              <div className="detail-field">
                <label>Gender</label>
                <span>{detailModal.gender || 'N/A'}</span>
              </div>
              <div className="detail-field">
                <label>Date of Birth</label>
                <span>{formatDate(detailModal.dateOfBirth)}</span>
              </div>
              <div className="detail-field">
                <label>Blood Group</label>
                <span>{detailModal.bloodGroup || 'N/A'}</span>
              </div>
              <div className="detail-field">
                <label>Joined</label>
                <span>{formatDate(detailModal.createdAt)}</span>
              </div>
              {detailModal.address && (
                <div className="detail-field" style={{ gridColumn: '1 / -1' }}>
                  <label>Address</label>
                  <span>{detailModal.address}</span>
                </div>
              )}
              {detailModal.emergencyContact && (
                <div className="detail-field">
                  <label>Emergency Contact</label>
                  <span>{detailModal.emergencyContact}</span>
                </div>
              )}
            </div>

            {/* User's Appointments */}
            <h3 style={{ fontSize: 16, fontWeight: 700, marginBottom: 12 }}>
              <Calendar size={16} style={{ marginRight: 8, verticalAlign: 'middle' }} />
              Appointment History ({userAppointments.length})
            </h3>

            {loadingAppts ? (
              <div className="loading-spinner" style={{ padding: 20 }}><div className="spinner" /></div>
            ) : userAppointments.length === 0 ? (
              <div style={{ textAlign: 'center', padding: 20, color: '#8b8b8b', fontSize: 13 }}>
                No appointments found for this patient
              </div>
            ) : (
              <table className="data-table">
                <thead>
                  <tr>
                    <th>Doctor</th>
                    <th>Date</th>
                    <th>Time</th>
                    <th>Fee</th>
                    <th>Status</th>
                  </tr>
                </thead>
                <tbody>
                  {userAppointments.slice(0, 10).map(appt => (
                    <tr key={appt.id}>
                      <td style={{ fontSize: 13, fontWeight: 500 }}>{appt.doctorName || 'Unknown'}</td>
                      <td style={{ fontSize: 13 }}>{formatDate(appt.appointmentDate)}</td>
                      <td style={{ fontSize: 13 }}>{appt.timeSlot || 'N/A'}</td>
                      <td style={{ fontSize: 13, fontWeight: 600 }}>Rs {appt.fee || 0}</td>
                      <td><span className={`status-badge status-${appt.status}`}>{appt.status}</span></td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
