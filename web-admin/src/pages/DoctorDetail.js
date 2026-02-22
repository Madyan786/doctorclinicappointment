import React, { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { doc, onSnapshot, updateDoc, collection, query, where } from 'firebase/firestore';
import { db } from '../firebase';
import {
  ArrowLeft, Star, MapPin, Clock, Phone, Mail, Shield, Award,
  Check, X, Calendar, FileText, Image, Edit, Eye
} from 'lucide-react';

export default function DoctorDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [doctor, setDoctor] = useState(null);
  const [appointments, setAppointments] = useState([]);
  const [reviews, setReviews] = useState([]);
  const [loading, setLoading] = useState(true);
  const [toast, setToast] = useState(null);
  const [rejectModal, setRejectModal] = useState(false);
  const [rejectReason, setRejectReason] = useState('');
  const [imageModal, setImageModal] = useState(null);

  useEffect(() => {
    const unsub = onSnapshot(doc(db, 'doctors', id), (snap) => {
      if (snap.exists()) {
        setDoctor({ id: snap.id, ...snap.data() });
      }
      setLoading(false);
    });

    const apptsUnsub = onSnapshot(
      query(collection(db, 'appointments'), where('doctorId', '==', id)),
      (snap) => {
        const list = snap.docs.map(d => ({ id: d.id, ...d.data() }));
        list.sort((a, b) => {
          const ta = a.appointmentDate?.toDate?.() || new Date(0);
          const tb = b.appointmentDate?.toDate?.() || new Date(0);
          return tb - ta;
        });
        setAppointments(list);
      }
    );

    const reviewsUnsub = onSnapshot(
      query(collection(db, 'reviews'), where('doctorId', '==', id)),
      (snap) => {
        const list = snap.docs.map(d => ({ id: d.id, ...d.data() }));
        list.sort((a, b) => {
          const ta = a.createdAt?.toDate?.() || new Date(0);
          const tb = b.createdAt?.toDate?.() || new Date(0);
          return tb - ta;
        });
        setReviews(list);
      }
    );

    return () => { unsub(); apptsUnsub(); reviewsUnsub(); };
  }, [id]);

  const showToast = (msg, type = 'success') => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3000);
  };

  const handleApprove = async () => {
    try {
      await updateDoc(doc(db, 'doctors', id), {
        isVerified: true, verificationStatus: 'approved', rejectionReason: ''
      });
      showToast('Doctor approved successfully');
    } catch (err) {
      showToast('Failed to approve', 'error');
    }
  };

  const handleReject = async () => {
    try {
      await updateDoc(doc(db, 'doctors', id), {
        isVerified: false, verificationStatus: 'rejected', rejectionReason: rejectReason
      });
      showToast('Doctor rejected');
      setRejectModal(false);
      setRejectReason('');
    } catch (err) {
      showToast('Failed to reject', 'error');
    }
  };

  const handleToggleAvailability = async () => {
    try {
      await updateDoc(doc(db, 'doctors', id), { isAvailable: !doctor.isAvailable });
      showToast(`Doctor ${!doctor.isAvailable ? 'enabled' : 'disabled'}`);
    } catch (err) {
      showToast('Failed to update', 'error');
    }
  };

  const formatDate = (timestamp) => {
    if (!timestamp) return 'N/A';
    const date = timestamp.toDate ? timestamp.toDate() : new Date(timestamp);
    return date.toLocaleDateString('en-PK', { day: 'numeric', month: 'short', year: 'numeric' });
  };

  if (loading) {
    return <div className="loading-spinner"><div className="spinner" /></div>;
  }

  if (!doctor) {
    return (
      <div className="empty-state">
        <h3>Doctor not found</h3>
        <button className="btn btn-outline" onClick={() => navigate('/doctors')}>
          <ArrowLeft size={16} /> Back to Doctors
        </button>
      </div>
    );
  }

  return (
    <div>
      <button className="back-btn" onClick={() => navigate('/doctors')}>
        <ArrowLeft size={16} /> Back to Doctors
      </button>

      {/* Header */}
      <div className="card" style={{ marginBottom: 20 }}>
        <div className="detail-header">
          <div className="detail-avatar">
            {doctor.profileImage ? (
              <img src={doctor.profileImage} alt={doctor.name} />
            ) : (
              (doctor.name || 'D').charAt(0).toUpperCase()
            )}
          </div>
          <div className="detail-info" style={{ flex: 1 }}>
            <h1>{doctor.name}</h1>
            <p>{doctor.specialty}</p>
            <div className="detail-meta">
              <div className="detail-meta-item">
                <Star size={12} fill="#ffc107" color="#ffc107" />
                {(doctor.rating || 0).toFixed(1)} ({doctor.totalReviews || 0} reviews)
              </div>
              <div className="detail-meta-item">
                <Award size={12} /> {doctor.experienceYears || 0} years exp
              </div>
              <div className="detail-meta-item">
                <MapPin size={12} /> {doctor.hospitalName || 'N/A'}
              </div>
              <span className={`status-badge status-${doctor.verificationStatus || 'pending'}`}>
                {doctor.verificationStatus || 'pending'}
              </span>
              <span className={`status-badge ${doctor.isAvailable ? 'status-completed' : 'status-cancelled'}`}>
                {doctor.isAvailable ? 'Available' : 'Unavailable'}
              </span>
            </div>
          </div>
          <div style={{ display: 'flex', gap: 8 }}>
            {doctor.verificationStatus === 'pending' && (
              <>
                <button className="btn btn-success" onClick={handleApprove}>
                  <Check size={16} /> Approve
                </button>
                <button className="btn btn-danger" onClick={() => setRejectModal(true)}>
                  <X size={16} /> Reject
                </button>
              </>
            )}
            <button className="btn btn-outline" onClick={handleToggleAvailability}>
              {doctor.isAvailable ? 'Disable' : 'Enable'}
            </button>
          </div>
        </div>

        {doctor.verificationStatus === 'rejected' && doctor.rejectionReason && (
          <div style={{ background: '#ffebee', padding: '12px 16px', borderRadius: 10, marginTop: 12, fontSize: 13, color: '#d32f2f' }}>
            <strong>Rejection Reason:</strong> {doctor.rejectionReason}
          </div>
        )}
      </div>

      {/* Details Grid */}
      <div className="grid-2" style={{ marginBottom: 20 }}>
        <div className="card">
          <h3 style={{ fontSize: 16, fontWeight: 700, marginBottom: 16 }}>Personal Information</h3>
          <div className="detail-grid">
            <div className="detail-field">
              <label>Email</label>
              <span><Mail size={12} style={{ marginRight: 6 }} />{doctor.email || 'N/A'}</span>
            </div>
            <div className="detail-field">
              <label>Phone</label>
              <span><Phone size={12} style={{ marginRight: 6 }} />{doctor.phone || 'N/A'}</span>
            </div>
            <div className="detail-field">
              <label>License Number</label>
              <span><Shield size={12} style={{ marginRight: 6 }} />{doctor.licenseNumber || 'N/A'}</span>
            </div>
            <div className="detail-field">
              <label>Consultation Fee</label>
              <span style={{ fontWeight: 600, color: '#4caf50' }}>Rs {doctor.consultationFee || 0}</span>
            </div>
            <div className="detail-field">
              <label>Working Hours</label>
              <span><Clock size={12} style={{ marginRight: 6 }} />{doctor.startTime || '09:00'} - {doctor.endTime || '17:00'}</span>
            </div>
            <div className="detail-field">
              <label>Joined</label>
              <span>{formatDate(doctor.createdAt)}</span>
            </div>
          </div>
        </div>

        <div className="card">
          <h3 style={{ fontSize: 16, fontWeight: 700, marginBottom: 16 }}>Professional Details</h3>
          <div style={{ marginBottom: 16 }}>
            <label style={{ fontSize: 11, textTransform: 'uppercase', letterSpacing: 0.5, color: '#8b8b8b', fontWeight: 600, display: 'block', marginBottom: 6 }}>Hospital</label>
            <div style={{ fontSize: 14, fontWeight: 500 }}>{doctor.hospitalName || 'N/A'}</div>
            <div style={{ fontSize: 12, color: '#8b8b8b' }}>{doctor.hospitalAddress || ''}</div>
          </div>
          <div style={{ marginBottom: 16 }}>
            <label style={{ fontSize: 11, textTransform: 'uppercase', letterSpacing: 0.5, color: '#8b8b8b', fontWeight: 600, display: 'block', marginBottom: 6 }}>Available Days</label>
            <div className="tags">
              {(doctor.availableDays || []).map((day, i) => (
                <span key={i} className="tag">{day}</span>
              ))}
              {(!doctor.availableDays || doctor.availableDays.length === 0) && <span style={{ fontSize: 13, color: '#8b8b8b' }}>Not set</span>}
            </div>
          </div>
          <div style={{ marginBottom: 16 }}>
            <label style={{ fontSize: 11, textTransform: 'uppercase', letterSpacing: 0.5, color: '#8b8b8b', fontWeight: 600, display: 'block', marginBottom: 6 }}>Qualifications</label>
            <div className="tags">
              {(doctor.qualifications || []).map((q, i) => (
                <span key={i} className="tag" style={{ background: '#e8f5e9', color: '#2e7d32' }}>{q}</span>
              ))}
              {(!doctor.qualifications || doctor.qualifications.length === 0) && <span style={{ fontSize: 13, color: '#8b8b8b' }}>Not set</span>}
            </div>
          </div>
          <div>
            <label style={{ fontSize: 11, textTransform: 'uppercase', letterSpacing: 0.5, color: '#8b8b8b', fontWeight: 600, display: 'block', marginBottom: 6 }}>About</label>
            <p style={{ fontSize: 13, color: '#555', lineHeight: 1.6 }}>{doctor.about || 'No description provided.'}</p>
          </div>
        </div>
      </div>

      {/* Documents */}
      {(doctor.licenseDocument || (doctor.degreeImages && doctor.degreeImages.length > 0)) && (
        <div className="card" style={{ marginBottom: 20 }}>
          <h3 style={{ fontSize: 16, fontWeight: 700, marginBottom: 16 }}>
            <FileText size={18} style={{ marginRight: 8, verticalAlign: 'middle' }} />
            Documents
          </h3>
          <div className="doc-images">
            {doctor.licenseDocument && (
              <div className="doc-image" onClick={() => setImageModal(doctor.licenseDocument)}>
                <img src={doctor.licenseDocument} alt="License" />
              </div>
            )}
            {(doctor.degreeImages || []).map((img, i) => (
              <div key={i} className="doc-image" onClick={() => setImageModal(img)}>
                <img src={img} alt={`Degree ${i + 1}`} />
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Appointments */}
      <div className="card" style={{ marginBottom: 20 }}>
        <div className="card-header">
          <h2>Appointments ({appointments.length})</h2>
        </div>
        {appointments.length === 0 ? (
          <div className="empty-state" style={{ padding: 30 }}>
            <Calendar size={32} />
            <p>No appointments for this doctor</p>
          </div>
        ) : (
          <table className="data-table">
            <thead>
              <tr>
                <th>Patient</th>
                <th>Date</th>
                <th>Time</th>
                <th>Fee</th>
                <th>Status</th>
                <th>Notes</th>
              </tr>
            </thead>
            <tbody>
              {appointments.slice(0, 10).map(appt => (
                <tr key={appt.id}>
                  <td>
                    <div style={{ fontWeight: 600, fontSize: 13 }}>{appt.patientName || 'Unknown'}</div>
                    <div style={{ fontSize: 11, color: '#8b8b8b' }}>{appt.patientPhone || ''}</div>
                  </td>
                  <td>{formatDate(appt.appointmentDate)}</td>
                  <td>{appt.timeSlot || 'N/A'}</td>
                  <td style={{ fontWeight: 600 }}>Rs {appt.fee || 0}</td>
                  <td><span className={`status-badge status-${appt.status}`}>{appt.status}</span></td>
                  <td style={{ fontSize: 12, maxWidth: 150, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                    {appt.notes || '-'}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      {/* Reviews */}
      <div className="card">
        <div className="card-header">
          <h2>Reviews ({reviews.length})</h2>
        </div>
        {reviews.length === 0 ? (
          <div className="empty-state" style={{ padding: 30 }}>
            <Star size={32} />
            <p>No reviews for this doctor</p>
          </div>
        ) : (
          reviews.slice(0, 10).map(review => (
            <div key={review.id} style={{
              padding: 16, background: '#fafafa', borderRadius: 12, marginBottom: 8,
              border: `1px solid ${review.isApproved ? '#e8f5e9' : '#fff3e0'}`
            }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 8 }}>
                <div className="avatar avatar-sm">{(review.patientName || 'P').charAt(0).toUpperCase()}</div>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 13, fontWeight: 600 }}>{review.patientName}</div>
                  <div style={{ fontSize: 11, color: '#8b8b8b' }}>{formatDate(review.createdAt)}</div>
                </div>
                <div className="stars">
                  {[1,2,3,4,5].map(i => (
                    <Star key={i} size={14} fill={i <= review.rating ? '#ffc107' : 'none'} color={i <= review.rating ? '#ffc107' : '#e0e0e0'} />
                  ))}
                </div>
                <span className={`status-badge ${review.isApproved ? 'status-approved' : 'status-pending'}`}>
                  {review.isApproved ? 'Approved' : 'Pending'}
                </span>
              </div>
              <p style={{ fontSize: 13, color: '#555', lineHeight: 1.5 }}>{review.comment}</p>
            </div>
          ))
        )}
      </div>

      {/* Reject Modal */}
      {rejectModal && (
        <div className="modal-overlay" onClick={() => setRejectModal(false)}>
          <div className="modal" onClick={e => e.stopPropagation()} style={{ maxWidth: 450 }}>
            <div className="modal-header">
              <h2>Reject Doctor</h2>
              <button className="modal-close" onClick={() => setRejectModal(false)}><X size={16} /></button>
            </div>
            <div className="form-group">
              <label>Rejection Reason</label>
              <textarea value={rejectReason} onChange={e => setRejectReason(e.target.value)} placeholder="Enter reason..." rows={3} />
            </div>
            <div className="form-actions">
              <button className="btn btn-outline" onClick={() => setRejectModal(false)}>Cancel</button>
              <button className="btn btn-danger" onClick={handleReject}>Reject</button>
            </div>
          </div>
        </div>
      )}

      {/* Image Preview Modal */}
      {imageModal && (
        <div className="modal-overlay" onClick={() => setImageModal(null)}>
          <div style={{ maxWidth: '90vw', maxHeight: '90vh' }} onClick={e => e.stopPropagation()}>
            <img src={imageModal} alt="Document" style={{ maxWidth: '100%', maxHeight: '85vh', borderRadius: 16 }} />
          </div>
        </div>
      )}

      {/* Toast */}
      {toast && <div className={`toast toast-${toast.type}`}>{toast.msg}</div>}
    </div>
  );
}
