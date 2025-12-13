# 🌐 Doctor Clinic - Web Integration Guide

Complete documentation to connect your website with the same Firebase backend used by the mobile app.

## ⚠️ IMPORTANT: App Filtering

**If you have multiple apps using the same Firebase project**, all data is now filtered by `appId` field.

- **App ID:** `doctorclinic`
- All documents (doctors, appointments, users, reviews) now include `appId: 'doctorclinic'`
- Admin panel automatically filters to show only this app's data
- Legacy data without `appId` is also included

### Filter Query Example:
```javascript
// Only get this app's data
const appointments = await getDocs(
  query(collection(db, 'appointments'), where('appId', '==', 'doctorclinic'))
);

// Or filter client-side (recommended to avoid index requirements)
const allDocs = await getDocs(collection(db, 'appointments'));
const filtered = allDocs.docs.filter(doc => {
  const data = doc.data();
  return data.appId === 'doctorclinic' || data.appId === null;
});
```

---

## 📋 Table of Contents
1. [Firebase Setup](#firebase-setup)
2. [Collections & Data Structure](#collections--data-structure)
3. [Authentication](#authentication)
4. [CRUD Operations](#crud-operations)
5. [Real-time Listeners](#real-time-listeners)
6. [File Upload](#file-upload)
7. [Sample Code](#sample-code)

---

## 🔥 Firebase Setup

### Step 1: Get Firebase Web Config

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Open your project: **doctorclinic**
3. Click ⚙️ **Settings** → **Project Settings**
4. Scroll to **"Your apps"** section
5. Click **"Add app"** → Select **Web** `</>`
6. App nickname: `doctorclinic-web`
7. Copy the config:

```javascript
const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_PROJECT.firebaseapp.com",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_PROJECT.appspot.com",
  messagingSenderId: "YOUR_SENDER_ID",
  appId: "YOUR_APP_ID"
};
```

### Step 2: Install Firebase SDK

**For React/Next.js:**
```bash
npm install firebase
```

**For HTML/Vanilla JS (CDN):**
```html
<script type="module">
  import { initializeApp } from "https://www.gstatic.com/firebasejs/10.7.0/firebase-app.js";
  import { getFirestore } from "https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js";
  import { getAuth } from "https://www.gstatic.com/firebasejs/10.7.0/firebase-auth.js";
  import { getStorage } from "https://www.gstatic.com/firebasejs/10.7.0/firebase-storage.js";
</script>
```

### Step 3: Initialize Firebase

```javascript
// firebase.js
import { initializeApp } from 'firebase/app';
import { getFirestore } from 'firebase/firestore';
import { getAuth } from 'firebase/auth';
import { getStorage } from 'firebase/storage';

const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_PROJECT.firebaseapp.com",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_PROJECT.appspot.com",
  messagingSenderId: "YOUR_SENDER_ID",
  appId: "YOUR_APP_ID"
};

const app = initializeApp(firebaseConfig);
export const db = getFirestore(app);
export const auth = getAuth(app);
export const storage = getStorage(app);
```

---

## 🗄️ Collections & Data Structure

### 1. `doctors` Collection

```javascript
// Path: /doctors/{doctorId}
{
  // Basic Info
  "name": "Dr. Ahmad Khan",
  "email": "ahmad@clinic.com",
  "phone": "+92-300-1234567",
  "specialty": "Cardiologist",
  "about": "15 years experience...",
  
  // Profile
  "profileImage": "https://storage.googleapis.com/...",
  "experienceYears": 15,
  "rating": 4.8,
  "totalReviews": 120,
  
  // Verification
  "isVerified": true,
  "verificationStatus": "approved",  // pending | approved | rejected
  "rejectionReason": "",
  "licenseNumber": "PMC-12345",
  "licenseDocument": "https://storage.url...",
  "degreeImages": ["url1", "url2"],
  
  // Schedule
  "isAvailable": true,
  "availableDays": ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"],
  "startTime": "09:00",
  "endTime": "17:00",
  
  // Location & Fees
  "hospitalName": "City Medical Center",
  "hospitalAddress": "123 Main Street, Lahore",
  "consultationFee": 2500,
  
  // Qualifications
  "qualifications": ["MBBS", "MD Cardiology", "Fellowship USA"],
  
  // App Identifier
  "appId": "doctorclinic",
  
  // Timestamps
  "createdAt": Timestamp
}
```

**Specialties Available:**
- Cardiologist, Dermatologist, Neurologist, Pediatrician
- Dentist, Ophthalmologist, Orthopedic, ENT Specialist
- Gynecologist, General Physician, Psychiatrist, Urologist

---

### 2. `appointments` Collection

```javascript
// Path: /appointments/{appointmentId}
{
  // Doctor Info (denormalized)
  "doctorId": "abc123",
  "doctorName": "Dr. Ahmad Khan",
  "doctorImage": "https://...",
  "doctorSpecialty": "Cardiologist",
  
  // Patient Info
  "patientId": "user123",      // Firebase Auth UID
  "patientName": "Ali Hassan",
  "patientPhone": "+92-300-9876543",
  
  // Appointment Details
  "appointmentDate": Timestamp,  // Date of appointment
  "timeSlot": "10:00",          // HH:mm format
  "status": "pending",          // pending | confirmed | completed | cancelled
  "fee": 2500,
  "notes": "Chest pain for 2 days",
  "cancelReason": "",
  
  // App Identifier
  "appId": "doctorclinic",
  
  // Timestamps
  "createdAt": Timestamp
}
```

**Status Values:**
| Status | Description |
|--------|-------------|
| `pending` | New booking, awaiting confirmation |
| `confirmed` | Confirmed by doctor/admin |
| `completed` | Appointment completed |
| `cancelled` | Cancelled by patient/doctor |

---

### 3. `users` Collection

```javascript
// Path: /users/{userId}  (userId = Firebase Auth UID)
{
  "name": "Ali Hassan",
  "email": "ali@email.com",
  "phone": "+92-300-9876543",
  "address": "456 Street, Karachi",
  "profileImage": "",
  "appId": "doctorclinic",
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

---

### 4. `reviews` Collection

```javascript
// Path: /reviews/{reviewId}
{
  "doctorId": "doctor123",
  "doctorName": "Dr. Ahmad Khan",
  "patientId": "user123",
  "patientName": "Ali Hassan",
  "rating": 5,              // 1-5 stars
  "comment": "Excellent doctor!",
  "isApproved": true,
  "appId": "doctorclinic",
  "createdAt": Timestamp
}
```

---

### 5. `admins` Collection

```javascript
// Path: /admins/{adminId}
{
  "email": "admin@doctorclinic.com",
  "password": "admin123",    // Note: In production, use Firebase Auth
  "name": "Admin",
  "role": "admin"
}
```

---

## 🔐 Authentication

### Admin Login (Simple - matches mobile app)

```javascript
import { collection, query, where, getDocs } from 'firebase/firestore';
import { db } from './firebase';

async function adminLogin(email, password) {
  // Check hardcoded admin
  if (email === 'admin@doctorclinic.com' && password === 'admin123') {
    localStorage.setItem('userType', 'admin');
    return { success: true };
  }
  
  // Check Firestore admins collection
  const q = query(collection(db, 'admins'), where('email', '==', email));
  const snapshot = await getDocs(q);
  
  if (!snapshot.empty) {
    const admin = snapshot.docs[0].data();
    if (admin.password === password) {
      localStorage.setItem('userType', 'admin');
      localStorage.setItem('adminId', snapshot.docs[0].id);
      return { success: true };
    }
  }
  
  return { success: false, error: 'Invalid credentials' };
}
```

### Patient Login (Firebase Auth)

```javascript
import { signInWithEmailAndPassword } from 'firebase/auth';
import { auth } from './firebase';

async function patientLogin(email, password) {
  try {
    const userCredential = await signInWithEmailAndPassword(auth, email, password);
    
    if (userCredential.user.emailVerified) {
      localStorage.setItem('userType', 'patient');
      return { success: true, user: userCredential.user };
    } else {
      return { success: false, error: 'Please verify your email first' };
    }
  } catch (error) {
    return { success: false, error: error.message };
  }
}
```

### Doctor Login

```javascript
import { signInWithEmailAndPassword } from 'firebase/auth';
import { collection, query, where, getDocs } from 'firebase/firestore';
import { auth, db } from './firebase';

async function doctorLogin(email, password) {
  try {
    await signInWithEmailAndPassword(auth, email, password);
    
    // Check if user is a doctor
    const q = query(collection(db, 'doctors'), where('email', '==', email));
    const snapshot = await getDocs(q);
    
    if (!snapshot.empty) {
      const doctor = { id: snapshot.docs[0].id, ...snapshot.docs[0].data() };
      
      if (doctor.verificationStatus === 'approved') {
        localStorage.setItem('userType', 'doctor');
        localStorage.setItem('doctorId', doctor.id);
        return { success: true, doctor };
      } else if (doctor.verificationStatus === 'pending') {
        return { success: false, error: 'Your account is pending verification' };
      } else {
        return { success: false, error: 'Your application was rejected' };
      }
    }
    
    return { success: false, error: 'No doctor account found' };
  } catch (error) {
    return { success: false, error: error.message };
  }
}
```

### Logout

```javascript
import { signOut } from 'firebase/auth';
import { auth } from './firebase';

async function logout() {
  await signOut(auth);
  localStorage.removeItem('userType');
  localStorage.removeItem('adminId');
  localStorage.removeItem('doctorId');
}
```

---

## 📝 CRUD Operations

### GET - Fetch Data

```javascript
import { collection, doc, getDoc, getDocs, query, where, orderBy, limit } from 'firebase/firestore';
import { db } from './firebase';

// Get all doctors
async function getAllDoctors() {
  const snapshot = await getDocs(collection(db, 'doctors'));
  return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
}

// Get single doctor
async function getDoctor(doctorId) {
  const docRef = doc(db, 'doctors', doctorId);
  const docSnap = await getDoc(docRef);
  return docSnap.exists() ? { id: docSnap.id, ...docSnap.data() } : null;
}

// Get approved doctors only
async function getApprovedDoctors() {
  const q = query(
    collection(db, 'doctors'),
    where('verificationStatus', '==', 'approved'),
    where('isAvailable', '==', true)
  );
  const snapshot = await getDocs(q);
  return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
}

// Get pending doctors
async function getPendingDoctors() {
  const q = query(
    collection(db, 'doctors'),
    where('verificationStatus', '==', 'pending')
  );
  const snapshot = await getDocs(q);
  return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
}

// Get appointments by status
async function getAppointmentsByStatus(status) {
  const q = query(
    collection(db, 'appointments'),
    where('status', '==', status)
  );
  const snapshot = await getDocs(q);
  return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
}

// Get doctor's appointments
async function getDoctorAppointments(doctorId) {
  const q = query(
    collection(db, 'appointments'),
    where('doctorId', '==', doctorId)
  );
  const snapshot = await getDocs(q);
  return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
}

// Get patient's appointments
async function getPatientAppointments(patientId) {
  const q = query(
    collection(db, 'appointments'),
    where('patientId', '==', patientId)
  );
  const snapshot = await getDocs(q);
  return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
}

// Get all users
async function getAllUsers() {
  const snapshot = await getDocs(collection(db, 'users'));
  return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
}

// Get all reviews
async function getAllReviews() {
  const snapshot = await getDocs(collection(db, 'reviews'));
  return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
}

// Get doctor reviews
async function getDoctorReviews(doctorId) {
  const q = query(
    collection(db, 'reviews'),
    where('doctorId', '==', doctorId),
    where('isApproved', '==', true)
  );
  const snapshot = await getDocs(q);
  return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
}
```

### CREATE - Add Data

```javascript
import { collection, addDoc, serverTimestamp } from 'firebase/firestore';
import { db } from './firebase';

// Create appointment
async function createAppointment(appointmentData) {
  const docRef = await addDoc(collection(db, 'appointments'), {
    ...appointmentData,
    status: 'pending',
    createdAt: serverTimestamp()
  });
  return docRef.id;
}

// Create review
async function createReview(reviewData) {
  const docRef = await addDoc(collection(db, 'reviews'), {
    ...reviewData,
    isApproved: false,
    createdAt: serverTimestamp()
  });
  return docRef.id;
}

// Create user profile
async function createUserProfile(userId, userData) {
  await setDoc(doc(db, 'users', userId), {
    ...userData,
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp()
  });
}
```

### UPDATE - Modify Data

```javascript
import { doc, updateDoc, serverTimestamp } from 'firebase/firestore';
import { db } from './firebase';

// Update appointment status
async function updateAppointmentStatus(appointmentId, status, cancelReason = '') {
  await updateDoc(doc(db, 'appointments', appointmentId), {
    status,
    cancelReason
  });
}

// Approve doctor
async function approveDoctor(doctorId) {
  await updateDoc(doc(db, 'doctors', doctorId), {
    isVerified: true,
    verificationStatus: 'approved',
    rejectionReason: ''
  });
}

// Reject doctor
async function rejectDoctor(doctorId, reason) {
  await updateDoc(doc(db, 'doctors', doctorId), {
    isVerified: false,
    verificationStatus: 'rejected',
    rejectionReason: reason
  });
}

// Update doctor profile
async function updateDoctorProfile(doctorId, data) {
  await updateDoc(doc(db, 'doctors', doctorId), {
    ...data,
    updatedAt: serverTimestamp()
  });
}

// Update user profile
async function updateUserProfile(userId, data) {
  await updateDoc(doc(db, 'users', userId), {
    ...data,
    updatedAt: serverTimestamp()
  });
}

// Approve review
async function approveReview(reviewId) {
  await updateDoc(doc(db, 'reviews', reviewId), {
    isApproved: true
  });
}

// Toggle doctor availability
async function toggleDoctorAvailability(doctorId, isAvailable) {
  await updateDoc(doc(db, 'doctors', doctorId), {
    isAvailable
  });
}
```

### DELETE - Remove Data

```javascript
import { doc, deleteDoc } from 'firebase/firestore';
import { db } from './firebase';

// Delete doctor
async function deleteDoctor(doctorId) {
  await deleteDoc(doc(db, 'doctors', doctorId));
}

// Delete appointment
async function deleteAppointment(appointmentId) {
  await deleteDoc(doc(db, 'appointments', appointmentId));
}

// Delete review
async function deleteReview(reviewId) {
  await deleteDoc(doc(db, 'reviews', reviewId));
}
```

---

## 🔄 Real-time Listeners

```javascript
import { collection, query, where, onSnapshot } from 'firebase/firestore';
import { db } from './firebase';

// Listen to all appointments (real-time)
function listenToAppointments(callback) {
  return onSnapshot(collection(db, 'appointments'), (snapshot) => {
    const appointments = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    callback(appointments);
  });
}

// Listen to pending doctors (real-time)
function listenToPendingDoctors(callback) {
  const q = query(
    collection(db, 'doctors'),
    where('verificationStatus', '==', 'pending')
  );
  
  return onSnapshot(q, (snapshot) => {
    const doctors = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    callback(doctors);
  });
}

// Usage in React:
useEffect(() => {
  const unsubscribe = listenToAppointments((appointments) => {
    setAppointments(appointments);
  });
  
  return () => unsubscribe(); // Cleanup
}, []);
```

---

## 📤 File Upload (Firebase Storage)

```javascript
import { ref, uploadBytes, getDownloadURL } from 'firebase/storage';
import { storage } from './firebase';

// Upload profile image
async function uploadProfileImage(file, userId) {
  const storageRef = ref(storage, `profiles/${userId}/${file.name}`);
  await uploadBytes(storageRef, file);
  const url = await getDownloadURL(storageRef);
  return url;
}

// Upload doctor document
async function uploadDoctorDocument(file, doctorId, type) {
  const storageRef = ref(storage, `doctors/${doctorId}/${type}/${file.name}`);
  await uploadBytes(storageRef, file);
  const url = await getDownloadURL(storageRef);
  return url;
}
```

---

## 📊 Dashboard Statistics

```javascript
import { collection, query, where, getDocs } from 'firebase/firestore';
import { db } from './firebase';

async function getDashboardStats() {
  // Get all collections
  const [doctors, appointments, users, reviews] = await Promise.all([
    getDocs(collection(db, 'doctors')),
    getDocs(collection(db, 'appointments')),
    getDocs(collection(db, 'users')),
    getDocs(collection(db, 'reviews'))
  ]);
  
  // Calculate stats
  let totalDoctors = 0;
  let pendingDoctors = 0;
  let totalAppointments = 0;
  let todayAppointments = 0;
  let pendingAppointments = 0;
  let totalRevenue = 0;
  
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  
  doctors.docs.forEach(doc => {
    totalDoctors++;
    if (doc.data().verificationStatus === 'pending') pendingDoctors++;
  });
  
  appointments.docs.forEach(doc => {
    const data = doc.data();
    totalAppointments++;
    
    if (data.status === 'pending') pendingAppointments++;
    if (data.status === 'completed') totalRevenue += data.fee || 0;
    
    const apptDate = data.appointmentDate?.toDate();
    if (apptDate && apptDate >= today && apptDate < new Date(today.getTime() + 86400000)) {
      todayAppointments++;
    }
  });
  
  return {
    totalDoctors,
    pendingDoctors,
    totalAppointments,
    todayAppointments,
    pendingAppointments,
    totalUsers: users.docs.length,
    totalReviews: reviews.docs.length,
    totalRevenue
  };
}
```

---

## 🛡️ Session Persistence

```javascript
// Check session on page load
function checkSession() {
  const userType = localStorage.getItem('userType');
  
  if (userType === 'admin') {
    return { type: 'admin', redirect: '/admin/dashboard' };
  } else if (userType === 'doctor') {
    const doctorId = localStorage.getItem('doctorId');
    return { type: 'doctor', doctorId, redirect: '/doctor/dashboard' };
  } else if (userType === 'patient') {
    return { type: 'patient', redirect: '/home' };
  }
  
  return { type: null, redirect: '/login' };
}
```

---

## 🎨 Sample React Components

### Login Component
```jsx
import { useState } from 'react';

function AdminLogin() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  
  const handleLogin = async (e) => {
    e.preventDefault();
    setLoading(true);
    
    const result = await adminLogin(email, password);
    
    if (result.success) {
      window.location.href = '/admin/dashboard';
    } else {
      alert(result.error);
    }
    
    setLoading(false);
  };
  
  return (
    <form onSubmit={handleLogin}>
      <input
        type="email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        placeholder="Email"
        required
      />
      <input
        type="password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        placeholder="Password"
        required
      />
      <button type="submit" disabled={loading}>
        {loading ? 'Loading...' : 'Login'}
      </button>
    </form>
  );
}
```

### Doctors List Component
```jsx
import { useState, useEffect } from 'react';

function DoctorsList() {
  const [doctors, setDoctors] = useState([]);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    const unsubscribe = listenToPendingDoctors((docs) => {
      setDoctors(docs);
      setLoading(false);
    });
    
    return () => unsubscribe();
  }, []);
  
  const handleApprove = async (doctorId) => {
    await approveDoctor(doctorId);
  };
  
  const handleReject = async (doctorId) => {
    const reason = prompt('Enter rejection reason:');
    if (reason) {
      await rejectDoctor(doctorId, reason);
    }
  };
  
  if (loading) return <p>Loading...</p>;
  
  return (
    <div>
      <h2>Pending Doctors ({doctors.length})</h2>
      {doctors.map(doctor => (
        <div key={doctor.id}>
          <h3>{doctor.name}</h3>
          <p>{doctor.specialty}</p>
          <p>{doctor.email}</p>
          <button onClick={() => handleApprove(doctor.id)}>Approve</button>
          <button onClick={() => handleReject(doctor.id)}>Reject</button>
        </div>
      ))}
    </div>
  );
}
```

---

## ✅ Quick Start Checklist

- [ ] Create Firebase Web App in Console
- [ ] Copy Firebase config
- [ ] Install Firebase SDK (`npm install firebase`)
- [ ] Create `firebase.js` with config
- [ ] Import and use `db`, `auth`, `storage`
- [ ] Implement login/logout
- [ ] Fetch data from collections
- [ ] Add real-time listeners
- [ ] Test CRUD operations

---

## 📞 Support

If you need help:
1. Check Firebase Console for errors
2. Enable Firestore in Firebase Console
3. Check Security Rules allow read/write
4. Check browser console for errors

**Default Admin Login:**
- Email: `admin@doctorclinic.com`
- Password: `admin123`
