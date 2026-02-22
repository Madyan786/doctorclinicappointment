import React, { useEffect, useState } from 'react';
import { collection, onSnapshot, doc, updateDoc } from 'firebase/firestore';
import { db } from '../firebase';
import {
  Search, Calendar, Clock, Check, X, Eye, Filter,
  ChevronDown, Phone, FileText, Image
} from 'lucide-react';

const STATUS_OPTIONS = ['pending', 'awaitingApproval', 'confirmed', 'completed', 'cancelled', 'rejected'];

export default function Appointments() {
  const [appointments, setAppointments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [filter, setFilter] = useState('all');
  const [toast, setToast] = useState(null);
  const [detailModal, setDetailModal] = useState(null);
  const [statusDropdown, setStatusDropdown] = useState(null);
  const [rejectModal, setRejectModal] = useState(null);
  const [rejectReason, setRejectReason] = useState('');
  const [imageModal, setImageModal] = useState(null);

  useEffect(() => {
    const unsub = onSnapshot(collection(db, 'appointments'), (snap) => {
      const list = snap.docs.map(d => ({ id: d.id, ...d.data() }));
      list.sort((a, b) => {
        const ta = a.appointmentDate?.toDate?.() || new Date(0);
        const tb = b.appointmentDate?.toDate?.() || new Date(0);
        return tb - ta;
      });
      setAppointments(list);
      setLoading(false);
    });
    return () => unsub();
  }, []);

  const showToast = (msg, type = 'success') => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3000);
  };

  const formatDate = (timestamp) => {
    if (!timestamp) return 'N/A';
    const date = timestamp.toDate ? timestamp.toDate() : new Date(timestamp);
    return date.toLocaleDateString('en-PK', { day: 'numeric', month: 'short', year: 'numeric' });
  };

  const formatDateTime = (timestamp) => {
    if (!timestamp) return 'N/A';
    const date = timestamp.toDate ? timestamp.toDate() : new Date(timestamp);
    return date.toLocaleDateString('en-PK', {
      day: 'numeric', month: 'short', year: 'numeric',
      hour: '2-digit', minute: '2-digit'
    });
  };

  const filtered = appointments.filter(a => {
    const matchSearch =
      a.patientName?.toLowerCase().includes(search.toLowerCase()) ||
      a.doctorName?.toLowerCase().includes(search.toLowerCase()) ||
      a.patientPhone?.toLowerCase().includes(search.toLowerCase());
    if (filter === 'all') return matchSearch;
    return matchSearch && a.status === filter;
  });

  const handleStatusChange = async (appointmentId, newStatus) => {
    try {
      const updateData = { status: newStatus };
      await updateDoc(doc(db, 'appointments', appointmentId), updateData);
      showToast(`Status updated to ${newStatus}`);
      setStatusDropdown(null);
    } catch (err) {
      showToast('Failed to update status', 'error');
    }
  };

  const handleReject = async () => {
    if (!rejectModal) return;
    try {
      await updateDoc(doc(db, 'appointments', rejectModal), {
        status: 'rejected',
        rejectionReason: rejectReason
      });
      showToast('Appointment rejected');
      setRejectModal(null);
      setRejectReason('');
    } catch (err) {
      showToast('Failed to reject', 'error');
    }
  };

  const getStatusCounts = () => {
    const counts = { all: appointments.length };
    STATUS_OPTIONS.forEach(s => {
      counts[s] = appointments.filter(a => a.status === s).length;
    });
    return counts;
  };

  const counts = getStatusCounts();

  if (loading) {
    return <div className="loading-spinner"><div className="spinner" /></div>;
  }

  return (
    <div>
      {/* Filters */}
      <div className="filters-bar">
        <div className="search-input">
          <Search size={16} color="#8b8b8b" />
          <input placeholder="Search patient or doctor..." value={search} onChange={e => setSearch(e.target.value)} />
        </div>
        {['all', ...STATUS_OPTIONS].map(f => (
          <button key={f} className={`filter-btn ${filter === f ? 'active' : ''}`} onClick={() => setFilter(f)}>
            {f === 'awaitingApproval' ? 'Awaiting' : f.charAt(0).toUpperCase() + f.slice(1)}
            {' '}({counts[f] || 0})
          </button>
        ))}
      </div>

      {/* Stats Row */}
      <div className="stats-grid" style={{ gridTemplateColumns: 'repeat(auto-fit, minmax(160px, 1fr))', marginBottom: 20 }}>
        <div className="stat-card stat-orange" style={{ padding: 16 }}>
          <h3 style={{ fontSize: 22 }}>{counts.pending || 0}</h3>
          <p style={{ fontSize: 12 }}>Pending</p>
        </div>
        <div className="stat-card stat-blue" style={{ padding: 16 }}>
          <h3 style={{ fontSize: 22 }}>{counts.confirmed || 0}</h3>
          <p style={{ fontSize: 12 }}>Confirmed</p>
        </div>
        <div className="stat-card stat-green" style={{ padding: 16 }}>
          <h3 style={{ fontSize: 22 }}>{counts.completed || 0}</h3>
          <p style={{ fontSize: 12 }}>Completed</p>
        </div>
        <div className="stat-card stat-red" style={{ padding: 16 }}>
          <h3 style={{ fontSize: 22 }}>{(counts.cancelled || 0) + (counts.rejected || 0)}</h3>
          <p style={{ fontSize: 12 }}>Cancelled/Rejected</p>
        </div>
      </div>

      {/* Table */}
      <div className="card">
        {filtered.length === 0 ? (
          <div className="empty-state">
            <Calendar size={48} />
            <h3>No appointments found</h3>
            <p>{search ? 'Try a different search term' : 'No appointments in this category'}</p>
          </div>
        ) : (
          <table className="data-table">
            <thead>
              <tr>
                <th>Patient</th>
                <th>Doctor</th>
                <th>Date</th>
                <th>Time</th>
                <th>Fee</th>
                <th>Status</th>
                <th>Payment</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map(appt => (
                <tr key={appt.id}>
                  <td>
                    <div className="info-row">
                      <div className="avatar avatar-sm" style={{ background: '#e3f2fd', color: '#1976d2' }}>
                        {(appt.patientName || 'P').charAt(0).toUpperCase()}
                      </div>
                      <div className="info-row-text">
                        <h4>{appt.patientName || 'Unknown'}</h4>
                        <p>{appt.patientPhone || ''}</p>
                      </div>
                    </div>
                  </td>
                  <td>
                    <div className="info-row">
                      <div className="avatar avatar-sm">
                        {appt.doctorImage ? (
                          <img src={appt.doctorImage} alt="" />
                        ) : (
                          (appt.doctorName || 'D').charAt(0).toUpperCase()
                        )}
                      </div>
                      <div className="info-row-text">
                        <h4>{appt.doctorName || 'Unknown'}</h4>
                        <p>{appt.doctorSpecialty || ''}</p>
                      </div>
                    </div>
                  </td>
                  <td style={{ whiteSpace: 'nowrap' }}>{formatDate(appt.appointmentDate)}</td>
                  <td>{appt.timeSlot || 'N/A'}</td>
                  <td style={{ fontWeight: 600 }}>Rs {appt.fee || 0}</td>
                  <td>
                    <div style={{ position: 'relative' }}>
                      <span
                        className={`status-badge status-${appt.status}`}
                        style={{ cursor: 'pointer' }}
                        onClick={() => setStatusDropdown(statusDropdown === appt.id ? null : appt.id)}
                      >
                        {appt.status === 'awaitingApproval' ? 'Awaiting' : appt.status}
                        <ChevronDown size={10} style={{ marginLeft: 4 }} />
                      </span>
                      {statusDropdown === appt.id && (
                        <div style={{
                          position: 'absolute', top: '100%', left: 0, zIndex: 20,
                          background: 'white', borderRadius: 10, boxShadow: '0 8px 30px rgba(0,0,0,0.12)',
                          border: '1px solid #e0e0e0', padding: 4, minWidth: 150, marginTop: 4
                        }}>
                          {STATUS_OPTIONS.filter(s => s !== appt.status).map(s => (
                            <div
                              key={s}
                              style={{
                                padding: '8px 12px', fontSize: 12, cursor: 'pointer',
                                borderRadius: 6, transition: 'background 0.15s'
                              }}
                              onMouseEnter={e => e.target.style.background = '#f5f5f5'}
                              onMouseLeave={e => e.target.style.background = 'transparent'}
                              onClick={() => {
                                if (s === 'rejected') {
                                  setRejectModal(appt.id);
                                  setRejectReason('');
                                  setStatusDropdown(null);
                                } else {
                                  handleStatusChange(appt.id, s);
                                }
                              }}
                            >
                              <span className={`status-badge status-${s}`} style={{ fontSize: 11 }}>
                                {s === 'awaitingApproval' ? 'Awaiting Approval' : s}
                              </span>
                            </div>
                          ))}
                        </div>
                      )}
                    </div>
                  </td>
                  <td>
                    {appt.paymentSlipUrl ? (
                      <button
                        className="btn-icon"
                        style={{ background: '#e8f5e9' }}
                        onClick={() => setImageModal(appt.paymentSlipUrl)}
                        title="View Payment Slip"
                      >
                        <Image size={14} color="#4caf50" />
                      </button>
                    ) : (
                      <span style={{ fontSize: 11, color: '#8b8b8b' }}>No slip</span>
                    )}
                  </td>
                  <td>
                    <div style={{ display: 'flex', gap: 6 }}>
                      <button className="btn-icon" style={{ background: '#e3f2fd' }} onClick={() => setDetailModal(appt)} title="View Details">
                        <Eye size={14} color="#1976d2" />
                      </button>
                      {(appt.status === 'pending' || appt.status === 'awaitingApproval') && (
                        <>
                          <button className="btn-icon" style={{ background: '#e8f5e9' }} onClick={() => handleStatusChange(appt.id, 'confirmed')} title="Confirm">
                            <Check size={14} color="#4caf50" />
                          </button>
                          <button className="btn-icon" style={{ background: '#ffebee' }} onClick={() => { setRejectModal(appt.id); setRejectReason(''); }} title="Reject">
                            <X size={14} color="#f44336" />
                          </button>
                        </>
                      )}
                      {appt.status === 'confirmed' && (
                        <button className="btn-icon" style={{ background: '#e8f5e9' }} onClick={() => handleStatusChange(appt.id, 'completed')} title="Complete">
                          <Check size={14} color="#4caf50" />
                        </button>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      {/* Detail Modal */}
      {detailModal && (
        <div className="modal-overlay" onClick={() => setDetailModal(null)}>
          <div className="modal" onClick={e => e.stopPropagation()}>
            <div className="modal-header">
              <h2>Appointment Details</h2>
              <button className="modal-close" onClick={() => setDetailModal(null)}><X size={16} /></button>
            </div>

            <div className="detail-grid" style={{ marginBottom: 16 }}>
              <div className="detail-field">
                <label>Patient Name</label>
                <span>{detailModal.patientName || 'Unknown'}</span>
              </div>
              <div className="detail-field">
                <label>Patient Phone</label>
                <span>{detailModal.patientPhone || 'N/A'}</span>
              </div>
              <div className="detail-field">
                <label>Doctor</label>
                <span>{detailModal.doctorName || 'Unknown'}</span>
              </div>
              <div className="detail-field">
                <label>Specialty</label>
                <span>{detailModal.doctorSpecialty || 'N/A'}</span>
              </div>
              <div className="detail-field">
                <label>Appointment Date</label>
                <span>{formatDate(detailModal.appointmentDate)}</span>
              </div>
              <div className="detail-field">
                <label>Time Slot</label>
                <span>{detailModal.timeSlot || 'N/A'}</span>
              </div>
              <div className="detail-field">
                <label>Fee</label>
                <span style={{ fontWeight: 600, color: '#4caf50' }}>Rs {detailModal.fee || 0}</span>
              </div>
              <div className="detail-field">
                <label>Status</label>
                <span className={`status-badge status-${detailModal.status}`}>{detailModal.status}</span>
              </div>
              <div className="detail-field" style={{ gridColumn: '1 / -1' }}>
                <label>Patient Notes</label>
                <span>{detailModal.notes || 'No notes provided'}</span>
              </div>
              {detailModal.cancelReason && (
                <div className="detail-field" style={{ gridColumn: '1 / -1' }}>
                  <label>Cancel Reason</label>
                  <span style={{ color: '#f44336' }}>{detailModal.cancelReason}</span>
                </div>
              )}
              {detailModal.rejectionReason && (
                <div className="detail-field" style={{ gridColumn: '1 / -1' }}>
                  <label>Rejection Reason</label>
                  <span style={{ color: '#d32f2f' }}>{detailModal.rejectionReason}</span>
                </div>
              )}
              <div className="detail-field">
                <label>Booked On</label>
                <span>{formatDateTime(detailModal.createdAt)}</span>
              </div>
            </div>

            {detailModal.paymentSlipUrl && (
              <div style={{ marginBottom: 16 }}>
                <label style={{ fontSize: 11, textTransform: 'uppercase', letterSpacing: 0.5, color: '#8b8b8b', fontWeight: 600, display: 'block', marginBottom: 8 }}>Payment Slip</label>
                <img
                  src={detailModal.paymentSlipUrl}
                  alt="Payment Slip"
                  className="payment-slip-img"
                  onClick={() => setImageModal(detailModal.paymentSlipUrl)}
                />
              </div>
            )}
          </div>
        </div>
      )}

      {/* Reject Modal */}
      {rejectModal && (
        <div className="modal-overlay" onClick={() => setRejectModal(null)}>
          <div className="modal" onClick={e => e.stopPropagation()} style={{ maxWidth: 450 }}>
            <div className="modal-header">
              <h2>Reject Appointment</h2>
              <button className="modal-close" onClick={() => setRejectModal(null)}><X size={16} /></button>
            </div>
            <div className="form-group">
              <label>Rejection Reason</label>
              <textarea value={rejectReason} onChange={e => setRejectReason(e.target.value)} placeholder="Enter reason for rejection..." rows={3} />
            </div>
            <div className="form-actions">
              <button className="btn btn-outline" onClick={() => setRejectModal(null)}>Cancel</button>
              <button className="btn btn-danger" onClick={handleReject}>Reject</button>
            </div>
          </div>
        </div>
      )}

      {/* Image Modal */}
      {imageModal && (
        <div className="modal-overlay" onClick={() => setImageModal(null)}>
          <div style={{ maxWidth: '90vw', maxHeight: '90vh' }} onClick={e => e.stopPropagation()}>
            <img src={imageModal} alt="Full view" style={{ maxWidth: '100%', maxHeight: '85vh', borderRadius: 16 }} />
          </div>
        </div>
      )}

      {/* Toast */}
      {toast && <div className={`toast toast-${toast.type}`}>{toast.msg}</div>}
    </div>
  );
}
