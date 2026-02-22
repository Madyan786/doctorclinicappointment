import React, { useEffect, useState } from 'react';
import { collection, onSnapshot, doc, updateDoc, deleteDoc } from 'firebase/firestore';
import { db } from '../firebase';
import {
  Search, Star, Check, X, Trash2, Filter, Eye,
  ThumbsUp, ThumbsDown, MessageSquare, Clock
} from 'lucide-react';

export default function Reviews() {
  const [reviews, setReviews] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [filter, setFilter] = useState('all');
  const [toast, setToast] = useState(null);
  const [detailModal, setDetailModal] = useState(null);

  useEffect(() => {
    const unsub = onSnapshot(collection(db, 'reviews'), (snap) => {
      const list = snap.docs.map(d => ({ id: d.id, ...d.data() }));
      list.sort((a, b) => {
        const ta = a.createdAt?.toDate?.() || new Date(0);
        const tb = b.createdAt?.toDate?.() || new Date(0);
        return tb - ta;
      });
      setReviews(list);
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

  const filtered = reviews.filter(r => {
    const matchSearch =
      r.patientName?.toLowerCase().includes(search.toLowerCase()) ||
      r.doctorName?.toLowerCase().includes(search.toLowerCase()) ||
      r.comment?.toLowerCase().includes(search.toLowerCase());
    if (filter === 'all') return matchSearch;
    if (filter === 'pending') return matchSearch && !r.isApproved;
    if (filter === 'approved') return matchSearch && r.isApproved;
    return matchSearch;
  });

  const handleApprove = async (reviewId) => {
    try {
      await updateDoc(doc(db, 'reviews', reviewId), { isApproved: true });
      showToast('Review approved');
      await updateDoctorRating(reviewId, true);
    } catch (err) {
      showToast('Failed to approve', 'error');
    }
  };

  const handleDisapprove = async (reviewId) => {
    try {
      await updateDoc(doc(db, 'reviews', reviewId), { isApproved: false });
      showToast('Review disapproved');
      await updateDoctorRating(reviewId, false);
    } catch (err) {
      showToast('Failed to disapprove', 'error');
    }
  };

  const handleDelete = async (reviewId) => {
    if (!window.confirm('Are you sure you want to delete this review?')) return;
    try {
      const review = reviews.find(r => r.id === reviewId);
      await deleteDoc(doc(db, 'reviews', reviewId));
      showToast('Review deleted');
      if (review) {
        // Recalculate doctor rating after deletion
        setTimeout(() => recalcDoctorRating(review.doctorId), 500);
      }
    } catch (err) {
      showToast('Failed to delete', 'error');
    }
  };

  const updateDoctorRating = async (reviewId, isApproved) => {
    try {
      const review = reviews.find(r => r.id === reviewId);
      if (!review) return;
      await recalcDoctorRating(review.doctorId);
    } catch (err) {
      console.error('Error updating doctor rating:', err);
    }
  };

  const recalcDoctorRating = async (doctorId) => {
    try {
      // Get current reviews state (after local update)
      const approvedReviews = reviews.filter(r => r.doctorId === doctorId && r.isApproved);
      if (approvedReviews.length === 0) {
        await updateDoc(doc(db, 'doctors', doctorId), { rating: 0, totalReviews: 0 });
      } else {
        const total = approvedReviews.reduce((sum, r) => sum + (r.rating || 0), 0);
        const avg = parseFloat((total / approvedReviews.length).toFixed(1));
        await updateDoc(doc(db, 'doctors', doctorId), {
          rating: avg,
          totalReviews: approvedReviews.length
        });
      }
    } catch (err) {
      console.error('Error recalculating rating:', err);
    }
  };

  const getFilterCounts = () => ({
    all: reviews.length,
    pending: reviews.filter(r => !r.isApproved).length,
    approved: reviews.filter(r => r.isApproved).length,
  });

  const counts = getFilterCounts();

  const avgRating = reviews.length > 0
    ? (reviews.reduce((s, r) => s + (r.rating || 0), 0) / reviews.length).toFixed(1)
    : '0.0';

  if (loading) {
    return <div className="loading-spinner"><div className="spinner" /></div>;
  }

  return (
    <div>
      {/* Stats */}
      <div className="stats-grid" style={{ gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))', marginBottom: 20 }}>
        <div className="stat-card stat-orange" style={{ padding: 20 }}>
          <div className="stat-card-icon"><Star size={20} color="white" /></div>
          <h3>{reviews.length}</h3>
          <p>Total Reviews</p>
        </div>
        <div className="stat-card stat-green" style={{ padding: 20 }}>
          <div className="stat-card-icon"><ThumbsUp size={20} color="white" /></div>
          <h3>{counts.approved}</h3>
          <p>Approved</p>
        </div>
        <div className="stat-card stat-pink" style={{ padding: 20 }}>
          <div className="stat-card-icon"><Clock size={20} color="white" /></div>
          <h3>{counts.pending}</h3>
          <p>Pending</p>
        </div>
        <div className="stat-card stat-purple" style={{ padding: 20 }}>
          <div className="stat-card-icon"><Star size={20} color="white" /></div>
          <h3>{avgRating}</h3>
          <p>Avg Rating</p>
        </div>
      </div>

      {/* Filters */}
      <div className="filters-bar">
        <div className="search-input">
          <Search size={16} color="#8b8b8b" />
          <input placeholder="Search by patient, doctor or comment..." value={search} onChange={e => setSearch(e.target.value)} style={{ width: 280 }} />
        </div>
        {['all', 'pending', 'approved'].map(f => (
          <button key={f} className={`filter-btn ${filter === f ? 'active' : ''}`} onClick={() => setFilter(f)}>
            {f.charAt(0).toUpperCase() + f.slice(1)} ({counts[f] || 0})
          </button>
        ))}
      </div>

      {/* Table */}
      <div className="card">
        {filtered.length === 0 ? (
          <div className="empty-state">
            <Star size={48} />
            <h3>No reviews found</h3>
            <p>{search ? 'Try a different search' : 'No reviews in this category'}</p>
          </div>
        ) : (
          <table className="data-table">
            <thead>
              <tr>
                <th>Patient</th>
                <th>Doctor</th>
                <th>Rating</th>
                <th>Comment</th>
                <th>Date</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map(review => (
                <tr key={review.id}>
                  <td>
                    <div className="info-row">
                      <div className="avatar avatar-sm" style={{ background: '#e3f2fd', color: '#1976d2' }}>
                        {review.patientImage ? (
                          <img src={review.patientImage} alt="" />
                        ) : (
                          (review.patientName || 'P').charAt(0).toUpperCase()
                        )}
                      </div>
                      <div className="info-row-text">
                        <h4>{review.patientName || 'Anonymous'}</h4>
                      </div>
                    </div>
                  </td>
                  <td style={{ fontSize: 13, fontWeight: 500 }}>{review.doctorName || 'Unknown'}</td>
                  <td>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
                      <div className="stars">
                        {[1, 2, 3, 4, 5].map(i => (
                          <Star
                            key={i}
                            size={13}
                            fill={i <= (review.rating || 0) ? '#ffc107' : 'none'}
                            color={i <= (review.rating || 0) ? '#ffc107' : '#e0e0e0'}
                          />
                        ))}
                      </div>
                      <span style={{ fontSize: 12, fontWeight: 600, marginLeft: 4 }}>
                        {(review.rating || 0).toFixed(1)}
                      </span>
                    </div>
                  </td>
                  <td style={{ fontSize: 12, maxWidth: 250, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', color: '#555' }}>
                    {review.comment || '-'}
                  </td>
                  <td style={{ whiteSpace: 'nowrap', fontSize: 12 }}>{formatDate(review.createdAt)}</td>
                  <td>
                    <span className={`status-badge ${review.isApproved ? 'status-approved' : 'status-pending'}`}>
                      {review.isApproved ? 'Approved' : 'Pending'}
                    </span>
                  </td>
                  <td>
                    <div style={{ display: 'flex', gap: 6 }}>
                      <button className="btn-icon" style={{ background: '#e3f2fd' }} onClick={() => setDetailModal(review)} title="View">
                        <Eye size={14} color="#1976d2" />
                      </button>
                      {!review.isApproved ? (
                        <button className="btn-icon" style={{ background: '#e8f5e9' }} onClick={() => handleApprove(review.id)} title="Approve">
                          <Check size={14} color="#4caf50" />
                        </button>
                      ) : (
                        <button className="btn-icon" style={{ background: '#fff3e0' }} onClick={() => handleDisapprove(review.id)} title="Disapprove">
                          <ThumbsDown size={14} color="#f2994a" />
                        </button>
                      )}
                      <button className="btn-icon" style={{ background: '#ffebee' }} onClick={() => handleDelete(review.id)} title="Delete">
                        <Trash2 size={14} color="#f44336" />
                      </button>
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
          <div className="modal" onClick={e => e.stopPropagation()} style={{ maxWidth: 500 }}>
            <div className="modal-header">
              <h2>Review Details</h2>
              <button className="modal-close" onClick={() => setDetailModal(null)}><X size={16} /></button>
            </div>

            <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 20 }}>
              <div className="avatar">
                {detailModal.patientImage ? (
                  <img src={detailModal.patientImage} alt="" />
                ) : (
                  (detailModal.patientName || 'P').charAt(0).toUpperCase()
                )}
              </div>
              <div>
                <div style={{ fontSize: 16, fontWeight: 700 }}>{detailModal.patientName || 'Anonymous'}</div>
                <div style={{ fontSize: 13, color: '#8b8b8b' }}>Review for Dr. {detailModal.doctorName || 'Unknown'}</div>
              </div>
            </div>

            <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 16 }}>
              <div className="stars">
                {[1, 2, 3, 4, 5].map(i => (
                  <Star
                    key={i}
                    size={20}
                    fill={i <= (detailModal.rating || 0) ? '#ffc107' : 'none'}
                    color={i <= (detailModal.rating || 0) ? '#ffc107' : '#e0e0e0'}
                  />
                ))}
              </div>
              <span style={{ fontSize: 18, fontWeight: 700 }}>{(detailModal.rating || 0).toFixed(1)}</span>
            </div>

            <div style={{ background: '#f9f9f9', padding: 16, borderRadius: 12, marginBottom: 16 }}>
              <p style={{ fontSize: 14, lineHeight: 1.7, color: '#333' }}>
                {detailModal.comment || 'No comment provided.'}
              </p>
            </div>

            <div className="detail-grid" style={{ marginBottom: 20 }}>
              <div className="detail-field">
                <label>Date</label>
                <span>{formatDate(detailModal.createdAt)}</span>
              </div>
              <div className="detail-field">
                <label>Status</label>
                <span className={`status-badge ${detailModal.isApproved ? 'status-approved' : 'status-pending'}`}>
                  {detailModal.isApproved ? 'Approved' : 'Pending'}
                </span>
              </div>
            </div>

            <div className="form-actions">
              {!detailModal.isApproved ? (
                <button className="btn btn-success" onClick={() => { handleApprove(detailModal.id); setDetailModal(null); }}>
                  <Check size={16} /> Approve
                </button>
              ) : (
                <button className="btn btn-outline" onClick={() => { handleDisapprove(detailModal.id); setDetailModal(null); }}>
                  <ThumbsDown size={16} /> Disapprove
                </button>
              )}
              <button className="btn btn-danger" onClick={() => { handleDelete(detailModal.id); setDetailModal(null); }}>
                <Trash2 size={16} /> Delete
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Toast */}
      {toast && <div className={`toast toast-${toast.type}`}>{toast.msg}</div>}
    </div>
  );
}

