import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { collection, onSnapshot, doc, updateDoc, deleteDoc, addDoc, Timestamp } from 'firebase/firestore';
import { db } from '../firebase';
import {
  Search, Plus, Eye, Edit, Trash2, Check, X, Filter,
  Stethoscope, Star, MapPin, Clock, Phone, Mail, Shield
} from 'lucide-react';

const SPECIALTIES = [
  'Cardiologist', 'Dermatologist', 'Neurologist', 'Pediatrician', 'Dentist',
  'Ophthalmologist', 'Orthopedic', 'ENT Specialist', 'Gynecologist',
  'General Physician', 'Psychiatrist', 'Urologist'
];

const DAYS = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

const emptyDoctor = {
  name: '', email: '', phone: '', specialty: 'General Physician', about: '',
  profileImage: '', experienceYears: 0, consultationFee: 0,
  isAvailable: true, availableDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
  startTime: '09:00', endTime: '17:00', hospitalName: '', hospitalAddress: '',
  qualifications: [], licenseNumber: '', isVerified: false,
  verificationStatus: 'approved', rejectionReason: '',
  licenseDocument: '', degreeImages: [], rating: 0, totalReviews: 0,
};

export default function Doctors() {
  const navigate = useNavigate();
  const [doctors, setDoctors] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [filter, setFilter] = useState('all');
  const [showModal, setShowModal] = useState(false);
  const [editDoctor, setEditDoctor] = useState(null);
  const [formData, setFormData] = useState({ ...emptyDoctor });
  const [qualInput, setQualInput] = useState('');
  const [toast, setToast] = useState(null);
  const [saving, setSaving] = useState(false);
  const [rejectModal, setRejectModal] = useState(null);
  const [rejectReason, setRejectReason] = useState('');

  useEffect(() => {
    const unsub = onSnapshot(collection(db, 'doctors'), (snap) => {
      const list = snap.docs.map(d => ({ id: d.id, ...d.data() }));
      list.sort((a, b) => {
        const ta = a.createdAt?.toDate?.() || new Date(0);
        const tb = b.createdAt?.toDate?.() || new Date(0);
        return tb - ta;
      });
      setDoctors(list);
      setLoading(false);
    });
    return () => unsub();
  }, []);

  const showToast = (msg, type = 'success') => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3000);
  };

  const filtered = doctors.filter(d => {
    const matchSearch = d.name?.toLowerCase().includes(search.toLowerCase()) ||
      d.specialty?.toLowerCase().includes(search.toLowerCase()) ||
      d.email?.toLowerCase().includes(search.toLowerCase());
    if (filter === 'all') return matchSearch;
    if (filter === 'pending') return matchSearch && d.verificationStatus === 'pending';
    if (filter === 'approved') return matchSearch && d.verificationStatus === 'approved';
    if (filter === 'rejected') return matchSearch && d.verificationStatus === 'rejected';
    if (filter === 'available') return matchSearch && d.isAvailable;
    return matchSearch;
  });

  const handleApprove = async (doctorId) => {
    try {
      await updateDoc(doc(db, 'doctors', doctorId), {
        isVerified: true, verificationStatus: 'approved', rejectionReason: ''
      });
      showToast('Doctor approved successfully');
    } catch (err) {
      showToast('Failed to approve doctor', 'error');
    }
  };

  const handleReject = async () => {
    if (!rejectModal) return;
    try {
      await updateDoc(doc(db, 'doctors', rejectModal), {
        isVerified: false, verificationStatus: 'rejected', rejectionReason: rejectReason
      });
      showToast('Doctor rejected');
      setRejectModal(null);
      setRejectReason('');
    } catch (err) {
      showToast('Failed to reject doctor', 'error');
    }
  };

  const handleDelete = async (doctorId) => {
    if (!window.confirm('Are you sure you want to delete this doctor?')) return;
    try {
      await deleteDoc(doc(db, 'doctors', doctorId));
      showToast('Doctor deleted');
    } catch (err) {
      showToast('Failed to delete doctor', 'error');
    }
  };

  const handleToggleAvailability = async (doctorId, current) => {
    try {
      await updateDoc(doc(db, 'doctors', doctorId), { isAvailable: !current });
      showToast(`Doctor ${!current ? 'enabled' : 'disabled'}`);
    } catch (err) {
      showToast('Failed to update', 'error');
    }
  };

  const openAddModal = () => {
    setEditDoctor(null);
    setFormData({ ...emptyDoctor });
    setQualInput('');
    setShowModal(true);
  };

  const openEditModal = (doctor) => {
    setEditDoctor(doctor);
    setFormData({
      name: doctor.name || '',
      email: doctor.email || '',
      phone: doctor.phone || '',
      specialty: doctor.specialty || 'General Physician',
      about: doctor.about || '',
      profileImage: doctor.profileImage || '',
      experienceYears: doctor.experienceYears || 0,
      consultationFee: doctor.consultationFee || 0,
      isAvailable: doctor.isAvailable !== false,
      availableDays: doctor.availableDays || [],
      startTime: doctor.startTime || '09:00',
      endTime: doctor.endTime || '17:00',
      hospitalName: doctor.hospitalName || '',
      hospitalAddress: doctor.hospitalAddress || '',
      qualifications: doctor.qualifications || [],
      licenseNumber: doctor.licenseNumber || '',
      isVerified: doctor.isVerified || false,
      verificationStatus: doctor.verificationStatus || 'pending',
      rejectionReason: doctor.rejectionReason || '',
      licenseDocument: doctor.licenseDocument || '',
      degreeImages: doctor.degreeImages || [],
      rating: doctor.rating || 0,
      totalReviews: doctor.totalReviews || 0,
    });
    setQualInput('');
    setShowModal(true);
  };

  const handleSave = async () => {
    if (!formData.name || !formData.email || !formData.specialty) {
      showToast('Please fill required fields (Name, Email, Specialty)', 'error');
      return;
    }
    setSaving(true);
    try {
      const data = {
        ...formData,
        experienceYears: Number(formData.experienceYears) || 0,
        consultationFee: Number(formData.consultationFee) || 0,
        rating: Number(formData.rating) || 0,
        totalReviews: Number(formData.totalReviews) || 0,
      };

      if (editDoctor) {
        await updateDoc(doc(db, 'doctors', editDoctor.id), data);
        showToast('Doctor updated successfully');
      } else {
        data.createdAt = Timestamp.now();
        data.isVerified = true;
        data.verificationStatus = 'approved';
        await addDoc(collection(db, 'doctors'), data);
        showToast('Doctor added successfully');
      }
      setShowModal(false);
    } catch (err) {
      console.error(err);
      showToast('Failed to save doctor', 'error');
    } finally {
      setSaving(false);
    }
  };

  const addQualification = () => {
    if (qualInput.trim()) {
      setFormData(prev => ({
        ...prev,
        qualifications: [...prev.qualifications, qualInput.trim()]
      }));
      setQualInput('');
    }
  };

  const removeQualification = (index) => {
    setFormData(prev => ({
      ...prev,
      qualifications: prev.qualifications.filter((_, i) => i !== index)
    }));
  };

  const toggleDay = (day) => {
    setFormData(prev => ({
      ...prev,
      availableDays: prev.availableDays.includes(day)
        ? prev.availableDays.filter(d => d !== day)
        : [...prev.availableDays, day]
    }));
  };

  if (loading) {
    return <div className="loading-spinner"><div className="spinner" /></div>;
  }

  return (
    <div>
      {/* Filters */}
      <div className="filters-bar">
        <div className="search-input">
          <Search size={16} color="#8b8b8b" />
          <input placeholder="Search doctors..." value={search} onChange={e => setSearch(e.target.value)} />
        </div>
        {['all', 'pending', 'approved', 'rejected', 'available'].map(f => (
          <button key={f} className={`filter-btn ${filter === f ? 'active' : ''}`} onClick={() => setFilter(f)}>
            {f.charAt(0).toUpperCase() + f.slice(1)} {f !== 'all' && `(${doctors.filter(d =>
              f === 'pending' ? d.verificationStatus === 'pending' :
              f === 'approved' ? d.verificationStatus === 'approved' :
              f === 'rejected' ? d.verificationStatus === 'rejected' :
              d.isAvailable
            ).length})`}
          </button>
        ))}
        <div style={{ flex: 1 }} />
        <button className="btn btn-primary" onClick={openAddModal}>
          <Plus size={16} /> Add Doctor
        </button>
      </div>

      {/* Table */}
      <div className="card">
        {filtered.length === 0 ? (
          <div className="empty-state">
            <Stethoscope size={48} />
            <h3>No doctors found</h3>
            <p>{search ? 'Try a different search term' : 'Add your first doctor'}</p>
          </div>
        ) : (
          <table className="data-table">
            <thead>
              <tr>
                <th>Doctor</th>
                <th>Specialty</th>
                <th>Hospital</th>
                <th>Fee</th>
                <th>Rating</th>
                <th>Status</th>
                <th>Verified</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map(doctor => (
                <tr key={doctor.id}>
                  <td>
                    <div className="info-row">
                      <div className="avatar">
                        {doctor.profileImage ? (
                          <img src={doctor.profileImage} alt={doctor.name} />
                        ) : (
                          (doctor.name || 'D').charAt(0).toUpperCase()
                        )}
                      </div>
                      <div className="info-row-text">
                        <h4>{doctor.name}</h4>
                        <p>{doctor.email}</p>
                      </div>
                    </div>
                  </td>
                  <td><span className="tag">{doctor.specialty}</span></td>
                  <td style={{ fontSize: 12, maxWidth: 150, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                    {doctor.hospitalName || '-'}
                  </td>
                  <td style={{ fontWeight: 600 }}>Rs {doctor.consultationFee || 0}</td>
                  <td>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
                      <Star size={14} fill="#ffc107" color="#ffc107" />
                      <span style={{ fontWeight: 600 }}>{(doctor.rating || 0).toFixed(1)}</span>
                      <span style={{ fontSize: 11, color: '#8b8b8b' }}>({doctor.totalReviews || 0})</span>
                    </div>
                  </td>
                  <td>
                    <button
                      className={`btn-icon ${doctor.isAvailable ? 'btn-success' : 'btn-danger'}`}
                      style={{ background: doctor.isAvailable ? '#e8f5e9' : '#ffebee', cursor: 'pointer' }}
                      onClick={() => handleToggleAvailability(doctor.id, doctor.isAvailable)}
                      title={doctor.isAvailable ? 'Available - Click to disable' : 'Unavailable - Click to enable'}
                    >
                      {doctor.isAvailable ? <Check size={14} color="#4caf50" /> : <X size={14} color="#f44336" />}
                    </button>
                  </td>
                  <td>
                    <span className={`status-badge status-${doctor.verificationStatus || 'pending'}`}>
                      {doctor.verificationStatus || 'pending'}
                    </span>
                  </td>
                  <td>
                    <div style={{ display: 'flex', gap: 6 }}>
                      <button className="btn-icon" style={{ background: '#e3f2fd' }} onClick={() => navigate(`/doctors/${doctor.id}`)} title="View">
                        <Eye size={14} color="#1976d2" />
                      </button>
                      <button className="btn-icon" style={{ background: '#f3e5f5' }} onClick={() => openEditModal(doctor)} title="Edit">
                        <Edit size={14} color="#7b1fa2" />
                      </button>
                      {doctor.verificationStatus === 'pending' && (
                        <>
                          <button className="btn-icon" style={{ background: '#e8f5e9' }} onClick={() => handleApprove(doctor.id)} title="Approve">
                            <Check size={14} color="#4caf50" />
                          </button>
                          <button className="btn-icon" style={{ background: '#fff3e0' }} onClick={() => { setRejectModal(doctor.id); setRejectReason(''); }} title="Reject">
                            <X size={14} color="#f2994a" />
                          </button>
                        </>
                      )}
                      <button className="btn-icon" style={{ background: '#ffebee' }} onClick={() => handleDelete(doctor.id)} title="Delete">
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

      {/* Add/Edit Modal */}
      {showModal && (
        <div className="modal-overlay" onClick={() => setShowModal(false)}>
          <div className="modal" onClick={e => e.stopPropagation()} style={{ maxWidth: 700 }}>
            <div className="modal-header">
              <h2>{editDoctor ? 'Edit Doctor' : 'Add New Doctor'}</h2>
              <button className="modal-close" onClick={() => setShowModal(false)}><X size={16} /></button>
            </div>

            <div className="form-row">
              <div className="form-group">
                <label>Full Name *</label>
                <input value={formData.name} onChange={e => setFormData({...formData, name: e.target.value})} placeholder="Dr. Ahmad Khan" />
              </div>
              <div className="form-group">
                <label>Email *</label>
                <input type="email" value={formData.email} onChange={e => setFormData({...formData, email: e.target.value})} placeholder="doctor@clinic.com" />
              </div>
            </div>

            <div className="form-row">
              <div className="form-group">
                <label>Phone</label>
                <input value={formData.phone} onChange={e => setFormData({...formData, phone: e.target.value})} placeholder="+92-300-1234567" />
              </div>
              <div className="form-group">
                <label>Specialty *</label>
                <select value={formData.specialty} onChange={e => setFormData({...formData, specialty: e.target.value})}>
                  {SPECIALTIES.map(s => <option key={s} value={s}>{s}</option>)}
                </select>
              </div>
            </div>

            <div className="form-group">
              <label>About</label>
              <textarea value={formData.about} onChange={e => setFormData({...formData, about: e.target.value})} placeholder="Brief description about the doctor..." rows={3} />
            </div>

            <div className="form-row">
              <div className="form-group">
                <label>Profile Image URL</label>
                <input value={formData.profileImage} onChange={e => setFormData({...formData, profileImage: e.target.value})} placeholder="https://..." />
              </div>
              <div className="form-group">
                <label>License Number</label>
                <input value={formData.licenseNumber} onChange={e => setFormData({...formData, licenseNumber: e.target.value})} placeholder="PMC-12345" />
              </div>
            </div>

            <div className="form-row">
              <div className="form-group">
                <label>Experience (Years)</label>
                <input type="number" value={formData.experienceYears} onChange={e => setFormData({...formData, experienceYears: e.target.value})} />
              </div>
              <div className="form-group">
                <label>Consultation Fee (PKR)</label>
                <input type="number" value={formData.consultationFee} onChange={e => setFormData({...formData, consultationFee: e.target.value})} />
              </div>
            </div>

            <div className="form-row">
              <div className="form-group">
                <label>Hospital Name</label>
                <input value={formData.hospitalName} onChange={e => setFormData({...formData, hospitalName: e.target.value})} placeholder="City Medical Center" />
              </div>
              <div className="form-group">
                <label>Hospital Address</label>
                <input value={formData.hospitalAddress} onChange={e => setFormData({...formData, hospitalAddress: e.target.value})} placeholder="123 Main Street, Lahore" />
              </div>
            </div>

            <div className="form-row">
              <div className="form-group">
                <label>Start Time</label>
                <input type="time" value={formData.startTime} onChange={e => setFormData({...formData, startTime: e.target.value})} />
              </div>
              <div className="form-group">
                <label>End Time</label>
                <input type="time" value={formData.endTime} onChange={e => setFormData({...formData, endTime: e.target.value})} />
              </div>
            </div>

            <div className="form-group">
              <label>Available Days</label>
              <div className="checkbox-group">
                {DAYS.map(day => (
                  <div
                    key={day}
                    className={`checkbox-label ${formData.availableDays.includes(day) ? 'checked' : ''}`}
                    onClick={() => toggleDay(day)}
                  >
                    {day}
                  </div>
                ))}
              </div>
            </div>

            <div className="form-group">
              <label>Qualifications</label>
              <div style={{ display: 'flex', gap: 8, marginBottom: 8 }}>
                <input
                  value={qualInput}
                  onChange={e => setQualInput(e.target.value)}
                  placeholder="e.g. MBBS, MD Cardiology"
                  onKeyPress={e => e.key === 'Enter' && (e.preventDefault(), addQualification())}
                  style={{ flex: 1 }}
                />
                <button className="btn btn-sm btn-outline" onClick={addQualification} type="button">Add</button>
              </div>
              <div className="tags">
                {formData.qualifications.map((q, i) => (
                  <span key={i} className="tag" style={{ cursor: 'pointer' }} onClick={() => removeQualification(i)}>
                    {q} <X size={12} style={{ marginLeft: 4 }} />
                  </span>
                ))}
              </div>
            </div>

            <div className="form-actions">
              <button className="btn btn-outline" onClick={() => setShowModal(false)}>Cancel</button>
              <button className="btn btn-primary" onClick={handleSave} disabled={saving}>
                {saving ? 'Saving...' : editDoctor ? 'Update Doctor' : 'Add Doctor'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Reject Modal */}
      {rejectModal && (
        <div className="modal-overlay" onClick={() => setRejectModal(null)}>
          <div className="modal" onClick={e => e.stopPropagation()} style={{ maxWidth: 450 }}>
            <div className="modal-header">
              <h2>Reject Doctor</h2>
              <button className="modal-close" onClick={() => setRejectModal(null)}><X size={16} /></button>
            </div>
            <div className="form-group">
              <label>Rejection Reason</label>
              <textarea
                value={rejectReason}
                onChange={e => setRejectReason(e.target.value)}
                placeholder="Enter reason for rejection..."
                rows={3}
              />
            </div>
            <div className="form-actions">
              <button className="btn btn-outline" onClick={() => setRejectModal(null)}>Cancel</button>
              <button className="btn btn-danger" onClick={handleReject}>Reject Doctor</button>
            </div>
          </div>
        </div>
      )}

      {/* Toast */}
      {toast && (
        <div className={`toast toast-${toast.type}`}>{toast.msg}</div>
      )}
    </div>
  );
}
