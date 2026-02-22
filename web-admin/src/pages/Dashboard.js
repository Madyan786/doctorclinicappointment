import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { collection, onSnapshot, query, where, orderBy, limit, Timestamp } from 'firebase/firestore';
import { db } from '../firebase';
import {
  Stethoscope, Calendar, Users, Wallet, Clock, CheckCircle,
  AlertCircle, Star, TrendingUp, ArrowRight, Eye
} from 'lucide-react';

export default function Dashboard() {
  const navigate = useNavigate();
  const [stats, setStats] = useState({
    totalDoctors: 0, pendingDoctors: 0,
    totalAppointments: 0, todayAppointments: 0, pendingAppointments: 0,
    totalUsers: 0, totalRevenue: 0,
    totalReviews: 0, pendingReviews: 0,
  });
  const [recentAppointments, setRecentAppointments] = useState([]);
  const [pendingDoctors, setPendingDoctors] = useState([]);
  const [recentReviews, setRecentReviews] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsubs = [];

    // Doctors
    unsubs.push(onSnapshot(collection(db, 'doctors'), (snap) => {
      let pending = 0;
      snap.docs.forEach(d => {
        if (d.data().verificationStatus === 'pending') pending++;
      });
      setStats(prev => ({ ...prev, totalDoctors: snap.size, pendingDoctors: pending }));

      const pendingList = snap.docs
        .filter(d => d.data().verificationStatus === 'pending')
        .map(d => ({ id: d.id, ...d.data() }))
        .slice(0, 5);
      setPendingDoctors(pendingList);
    }));

    // Appointments
    unsubs.push(onSnapshot(collection(db, 'appointments'), (snap) => {
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      const tomorrow = new Date(today);
      tomorrow.setDate(tomorrow.getDate() + 1);

      let todayCount = 0, pendingCount = 0, revenue = 0;
      snap.docs.forEach(d => {
        const data = d.data();
        const apptDate = data.appointmentDate?.toDate?.();
        if (apptDate && apptDate >= today && apptDate < tomorrow) todayCount++;
        if (data.status === 'pending' || data.status === 'awaitingApproval') pendingCount++;
        if (data.status === 'completed') revenue += (data.fee || 0);
      });

      setStats(prev => ({
        ...prev,
        totalAppointments: snap.size,
        todayAppointments: todayCount,
        pendingAppointments: pendingCount,
        totalRevenue: revenue,
      }));

      const sorted = snap.docs
        .map(d => ({ id: d.id, ...d.data() }))
        .sort((a, b) => {
          const ta = a.createdAt?.toDate?.() || new Date(0);
          const tb = b.createdAt?.toDate?.() || new Date(0);
          return tb - ta;
        })
        .slice(0, 5);
      setRecentAppointments(sorted);
    }));

    // Users
    unsubs.push(onSnapshot(collection(db, 'users'), (snap) => {
      setStats(prev => ({ ...prev, totalUsers: snap.size }));
    }));

    // Reviews
    unsubs.push(onSnapshot(collection(db, 'reviews'), (snap) => {
      let pending = 0;
      snap.docs.forEach(d => { if (!d.data().isApproved) pending++; });
      setStats(prev => ({ ...prev, totalReviews: snap.size, pendingReviews: pending }));

      const sorted = snap.docs
        .map(d => ({ id: d.id, ...d.data() }))
        .sort((a, b) => {
          const ta = a.createdAt?.toDate?.() || new Date(0);
          const tb = b.createdAt?.toDate?.() || new Date(0);
          return tb - ta;
        })
        .slice(0, 3);
      setRecentReviews(sorted);
      setLoading(false);
    }));

    return () => unsubs.forEach(u => u());
  }, []);

  const formatCurrency = (num) => {
    if (num >= 1000000) return `Rs ${(num / 1000000).toFixed(1)}M`;
    if (num >= 1000) return `Rs ${(num / 1000).toFixed(1)}K`;
    return `Rs ${num}`;
  };

  const formatDate = (timestamp) => {
    if (!timestamp) return 'N/A';
    const date = timestamp.toDate ? timestamp.toDate() : new Date(timestamp);
    return date.toLocaleDateString('en-PK', { day: 'numeric', month: 'short', year: 'numeric' });
  };

  const getStatusColor = (status) => {
    const colors = {
      pending: '#f2994a', awaitingApproval: '#1976d2', confirmed: '#2196f3',
      completed: '#4caf50', cancelled: '#f44336', rejected: '#d32f2f',
    };
    return colors[status] || '#999';
  };

  if (loading) {
    return <div className="loading-spinner"><div className="spinner" /></div>;
  }

  return (
    <div>
      {/* Stats Cards */}
      <div className="stats-grid">
        <div className="stat-card stat-purple">
          <div className="stat-card-icon"><Stethoscope size={22} color="white" /></div>
          <h3>{stats.totalDoctors}</h3>
          <p>Total Doctors</p>
          <div className="stat-subtitle">{stats.pendingDoctors} pending verification</div>
        </div>
        <div className="stat-card stat-green">
          <div className="stat-card-icon"><Calendar size={22} color="white" /></div>
          <h3>{stats.totalAppointments}</h3>
          <p>Appointments</p>
          <div className="stat-subtitle">{stats.todayAppointments} today</div>
        </div>
        <div className="stat-card stat-pink">
          <div className="stat-card-icon"><Users size={22} color="white" /></div>
          <h3>{stats.totalUsers}</h3>
          <p>Total Users</p>
          <div className="stat-subtitle">Registered patients</div>
        </div>
        <div className="stat-card stat-orange">
          <div className="stat-card-icon"><Wallet size={22} color="white" /></div>
          <h3>{formatCurrency(stats.totalRevenue)}</h3>
          <p>Revenue</p>
          <div className="stat-subtitle">From completed appointments</div>
        </div>
      </div>

      {/* Quick Stats Row */}
      <div className="stats-grid" style={{ gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))', marginBottom: 28 }}>
        <div className="card" style={{ display: 'flex', alignItems: 'center', gap: 16, padding: 20 }}>
          <div style={{ width: 44, height: 44, borderRadius: 12, background: '#fff3e0', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Clock size={20} color="#f2994a" />
          </div>
          <div>
            <div style={{ fontSize: 22, fontWeight: 700 }}>{stats.pendingAppointments}</div>
            <div style={{ fontSize: 12, color: '#8b8b8b' }}>Pending Appointments</div>
          </div>
        </div>
        <div className="card" style={{ display: 'flex', alignItems: 'center', gap: 16, padding: 20 }}>
          <div style={{ width: 44, height: 44, borderRadius: 12, background: '#e3f2fd', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <AlertCircle size={20} color="#1976d2" />
          </div>
          <div>
            <div style={{ fontSize: 22, fontWeight: 700 }}>{stats.pendingDoctors}</div>
            <div style={{ fontSize: 12, color: '#8b8b8b' }}>Pending Verifications</div>
          </div>
        </div>
        <div className="card" style={{ display: 'flex', alignItems: 'center', gap: 16, padding: 20 }}>
          <div style={{ width: 44, height: 44, borderRadius: 12, background: '#fff8e1', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Star size={20} color="#ffc107" />
          </div>
          <div>
            <div style={{ fontSize: 22, fontWeight: 700 }}>{stats.pendingReviews}</div>
            <div style={{ fontSize: 12, color: '#8b8b8b' }}>Pending Reviews</div>
          </div>
        </div>
      </div>

      {/* Two Column Layout */}
      <div className="grid-2" style={{ marginBottom: 28 }}>
        {/* Recent Appointments */}
        <div className="card">
          <div className="card-header">
            <h2>Recent Appointments</h2>
            <button className="btn btn-sm btn-outline" onClick={() => navigate('/appointments')}>
              View All <ArrowRight size={14} />
            </button>
          </div>
          {recentAppointments.length === 0 ? (
            <div className="empty-state">
              <Calendar size={40} />
              <h3>No appointments yet</h3>
              <p>Appointments will appear here</p>
            </div>
          ) : (
            recentAppointments.map((appt) => (
              <div key={appt.id} style={{
                display: 'flex', alignItems: 'center', gap: 12, padding: '12px',
                background: '#fafafa', borderRadius: 12, marginBottom: 8
              }}>
                <div style={{
                  width: 40, height: 40, borderRadius: 10,
                  background: `${getStatusColor(appt.status)}20`,
                  display: 'flex', alignItems: 'center', justifyContent: 'center'
                }}>
                  <Calendar size={18} color={getStatusColor(appt.status)} />
                </div>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 13, fontWeight: 600 }}>{appt.patientName || 'Unknown'}</div>
                  <div style={{ fontSize: 11, color: '#8b8b8b' }}>Dr. {appt.doctorName || 'Unknown'} - {formatDate(appt.appointmentDate)}</div>
                </div>
                <span className={`status-badge status-${appt.status}`}>{appt.status}</span>
              </div>
            ))
          )}
        </div>

        {/* Pending Doctor Verifications */}
        <div className="card">
          <div className="card-header">
            <h2>Pending Verifications</h2>
            <span className="card-header-badge">{stats.pendingDoctors} pending</span>
          </div>
          {pendingDoctors.length === 0 ? (
            <div className="empty-state">
              <CheckCircle size={40} />
              <h3>All caught up!</h3>
              <p>No pending verifications</p>
            </div>
          ) : (
            pendingDoctors.map((doc) => (
              <div key={doc.id} style={{
                display: 'flex', alignItems: 'center', gap: 12, padding: '12px',
                background: '#fafafa', borderRadius: 12, marginBottom: 8,
                border: '1px solid #fff3e0'
              }}>
                <div className="avatar" style={{ borderRadius: 10 }}>
                  {doc.profileImage ? (
                    <img src={doc.profileImage} alt={doc.name} />
                  ) : (
                    (doc.name || 'D').charAt(0).toUpperCase()
                  )}
                </div>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 13, fontWeight: 600 }}>{doc.name}</div>
                  <div style={{ fontSize: 11, color: '#f2994a' }}>{doc.specialty}</div>
                </div>
                <button
                  className="btn btn-sm btn-outline"
                  onClick={() => navigate(`/doctors/${doc.id}`)}
                >
                  <Eye size={14} /> View
                </button>
              </div>
            ))
          )}
        </div>
      </div>

      {/* Recent Reviews */}
      <div className="card">
        <div className="card-header">
          <h2>Recent Reviews</h2>
          <button className="btn btn-sm btn-outline" onClick={() => navigate('/reviews')}>
            View All <ArrowRight size={14} />
          </button>
        </div>
        {recentReviews.length === 0 ? (
          <div className="empty-state">
            <Star size={40} />
            <h3>No reviews yet</h3>
            <p>Patient reviews will appear here</p>
          </div>
        ) : (
          <div className="grid-3" style={{ gap: 16 }}>
            {recentReviews.map((review) => (
              <div key={review.id} style={{
                padding: 16, background: '#fafafa', borderRadius: 12,
                border: `1px solid ${review.isApproved ? '#e8f5e9' : '#fff3e0'}`
              }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 8 }}>
                  <div className="avatar avatar-sm">
                    {(review.patientName || 'P').charAt(0).toUpperCase()}
                  </div>
                  <div>
                    <div style={{ fontSize: 13, fontWeight: 600 }}>{review.patientName || 'Anonymous'}</div>
                    <div style={{ fontSize: 11, color: '#8b8b8b' }}>Dr. {review.doctorName || 'Unknown'}</div>
                  </div>
                </div>
                <div className="stars" style={{ marginBottom: 6 }}>
                  {[1, 2, 3, 4, 5].map(i => (
                    <Star key={i} size={14} fill={i <= (review.rating || 0) ? '#ffc107' : 'none'} color={i <= (review.rating || 0) ? '#ffc107' : '#e0e0e0'} />
                  ))}
                </div>
                <p style={{ fontSize: 12, color: '#666', lineHeight: 1.5, marginBottom: 8 }}>
                  {(review.comment || '').substring(0, 100)}{review.comment?.length > 100 ? '...' : ''}
                </p>
                <span className={`status-badge ${review.isApproved ? 'status-approved' : 'status-pending'}`}>
                  {review.isApproved ? 'Approved' : 'Pending'}
                </span>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
