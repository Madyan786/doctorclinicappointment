# Doctor Clinic - Web Admin Panel - Complete Documentation

## Table of Contents
1. [Overview](#overview)
2. [Tech Stack](#tech-stack)
3. [Project Structure](#project-structure)
4. [Firebase Setup](#firebase-setup)
5. [Installation & Running](#installation--running)
6. [Firebase Collections (Complete Data Schema)](#firebase-collections)
7. [Pages & Features](#pages--features)
8. [Admin Authentication](#admin-authentication)
9. [API Reference (Firestore Operations)](#api-reference)
10. [Deployment](#deployment)
11. [Mobile App Connection](#mobile-app-connection)

---

## 1. Overview

The Doctor Clinic Web Admin Panel is a **React.js** web application that connects to the **same Firebase backend** as the Flutter mobile app. It provides a full management interface for:

- **Dashboard** - Real-time statistics & overview
- **Doctor Management** - Add, edit, verify, approve/reject doctors
- **Appointment Management** - View, filter, update status, confirm/reject
- **User Management** - View all registered patients & their history
- **Review Management** - Approve, disapprove, delete patient reviews
- **Settings** - Admin profile & password change

Any changes made in the admin panel reflect **instantly** in the mobile app (real-time via Firebase).

---

## 2. Tech Stack

| Technology | Purpose |
|---|---|
| **React 18** | Frontend framework |
| **React Router v6** | Client-side routing |
| **Firebase v10** | Backend (Firestore, Auth, Storage) |
| **Lucide React** | Modern icon library |
| **CSS3** | Custom styling (no external UI library) |

---

## 3. Project Structure

```
web-admin/
├── public/
│   └── index.html                 # HTML entry point
├── src/
│   ├── index.js                   # React entry point
│   ├── index.css                  # Global styles (all CSS)
│   ├── App.js                     # Main app with routing & auth
│   ├── firebase.js                # Firebase configuration
│   ├── components/
│   │   └── Layout.js              # Sidebar + Topbar + Layout wrapper
│   └── pages/
│       ├── Login.js               # Admin login page
│       ├── Dashboard.js           # Dashboard with stats & overview
│       ├── Doctors.js             # Doctor list, add, edit, approve/reject
│       ├── DoctorDetail.js        # Individual doctor profile & details
│       ├── Appointments.js        # Appointment management
│       ├── Users.js               # Patient/user management
│       ├── Reviews.js             # Review moderation
│       └── Settings.js            # Admin settings & password
├── package.json                   # Dependencies & scripts
├── README.md                      # Quick start guide
└── ADMIN_PANEL_DOCUMENTATION.md   # This file (full documentation)
```

---

## 4. Firebase Setup

### Step 1: Add Web App to Firebase
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Open your existing project (same as mobile app)
3. Click **Settings (gear icon)** → **Project Settings**
4. Scroll to **"Your apps"** → Click **"Add app"** → Select **Web `</>`**
5. Register app name: `doctorclinic-web`
6. Copy the Firebase config object

### Step 2: Create `.env` File
Create a `.env` file in `web-admin/` folder:

```env
REACT_APP_FIREBASE_API_KEY=AIzaSy...your-key
REACT_APP_FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
REACT_APP_FIREBASE_PROJECT_ID=your-project-id
REACT_APP_FIREBASE_STORAGE_BUCKET=your-project.appspot.com
REACT_APP_FIREBASE_MESSAGING_SENDER_ID=123456789
REACT_APP_FIREBASE_APP_ID=1:123456789:web:abc123
```

### Step 3: Create Admin Account in Firebase
1. **Firebase Auth**: Create a user with email/password (e.g., `admin@doctorclinic.com`)
2. **Firestore**: Create an `admins` collection → Add a document with:
   - **Document ID** = the Firebase Auth UID of the admin user
   - Fields:
     ```json
     {
       "name": "Admin",
       "email": "admin@doctorclinic.com",
       "role": "admin",
       "createdAt": "<Timestamp>"
     }
     ```

---

## 5. Installation & Running

```bash
# Navigate to web-admin folder
cd web-admin

# Install dependencies
npm install

# Start development server
npm start
```

The app will open at `http://localhost:3000`

### Build for Production
```bash
npm run build
```

---

## 6. Firebase Collections (Complete Data Schema)

### 6.1 `doctors` Collection

```javascript
doctors/{doctorId}
{
  // Basic Info
  "name": "Dr. Ahmad Khan",              // String - Full name
  "email": "ahmad.khan@clinic.com",      // String - Email
  "phone": "+92-300-1234567",            // String - Phone number
  "specialty": "Cardiologist",           // String - Medical specialty
  "about": "Brief description...",       // String - About text
  "profileImage": "https://...",         // String - Profile image URL

  // Professional
  "experienceYears": 15,                 // Number - Years of experience
  "rating": 4.9,                         // Number - Average rating (0-5)
  "totalReviews": 127,                   // Number - Total approved reviews
  "consultationFee": 2500,              // Number - Fee in PKR

  // Availability
  "isAvailable": true,                   // Boolean - Currently accepting appointments
  "availableDays": [                     // Array<String> - Working days
    "Monday", "Tuesday", "Wednesday", "Thursday", "Friday"
  ],
  "startTime": "09:00",                 // String - Start time (HH:mm)
  "endTime": "17:00",                   // String - End time (HH:mm)

  // Hospital
  "hospitalName": "City Medical Center", // String - Hospital name
  "hospitalAddress": "123 Main St",      // String - Hospital address

  // Qualifications
  "qualifications": [                    // Array<String> - Degrees
    "MBBS", "MD - Cardiology", "Fellowship"
  ],

  // Verification (Admin manages this)
  "isVerified": false,                   // Boolean - Is doctor verified
  "verificationStatus": "pending",       // String - "pending" | "approved" | "rejected"
  "licenseNumber": "PMC-12345",         // String - Medical license number
  "rejectionReason": "",                 // String - Reason if rejected

  // Documents
  "licenseDocument": "https://...",      // String - License document image URL
  "degreeImages": ["https://..."],       // Array<String> - Degree certificate URLs

  // System
  "createdAt": Timestamp,               // Timestamp - Registration date
  "appId": "doctorclinic"               // String - App identifier
}
```

**Specialty Values:**
- Cardiologist, Dermatologist, Neurologist, Pediatrician, Dentist
- Ophthalmologist, Orthopedic, ENT Specialist, Gynecologist
- General Physician, Psychiatrist, Urologist

**Verification Status Flow:**
```
Doctor Registers → "pending" → Admin Approves → "approved" (isVerified = true)
                              → Admin Rejects → "rejected" (isVerified = false)
```

---

### 6.2 `appointments` Collection

```javascript
appointments/{appointmentId}
{
  // Doctor Info (denormalized)
  "doctorId": "abc123",                  // String - Reference to doctor
  "doctorName": "Dr. Ahmad Khan",        // String - Doctor name
  "doctorImage": "https://...",          // String - Doctor image URL
  "doctorSpecialty": "Cardiologist",     // String - Doctor specialty

  // Patient Info
  "patientId": "user123",               // String - Firebase Auth UID
  "patientName": "Ali Hassan",          // String - Patient name
  "patientPhone": "+92-300-9876543",    // String - Patient phone

  // Appointment Details
  "appointmentDate": Timestamp,          // Timestamp - Appointment date
  "timeSlot": "10:00",                  // String - Time slot (HH:mm)
  "fee": 2500,                          // Number - Consultation fee
  "notes": "Chest pain for 2 days",     // String (optional) - Patient notes

  // Status
  "status": "pending",                   // String - Current status
  "cancelReason": "",                    // String (optional) - If cancelled
  "rejectionReason": "",                 // String (optional) - If rejected by admin
  "paymentSlipUrl": "https://...",      // String (optional) - Payment proof image

  // System
  "createdAt": Timestamp,               // Timestamp - Booking date
  "appId": "doctorclinic"               // String - App identifier
}
```

**Appointment Status Values:**
| Status | Description |
|---|---|
| `pending` | Newly created, awaiting action |
| `awaitingApproval` | Payment submitted, awaiting admin approval |
| `confirmed` | Approved by admin/doctor |
| `completed` | Appointment finished |
| `cancelled` | Cancelled by patient |
| `rejected` | Rejected by admin/doctor |

---

### 6.3 `users` Collection

```javascript
users/{userId}  // userId = Firebase Auth UID
{
  "name": "Ali Hassan",                  // String - Full name
  "email": "ali.hassan@email.com",       // String - Email
  "phone": "+92-300-9876543",            // String - Phone
  "profileImage": "https://...",         // String - Profile image URL
  "gender": "male",                      // String (optional)
  "dateOfBirth": Timestamp,              // Timestamp (optional)
  "address": "456 Street, Karachi",      // String (optional)
  "bloodGroup": "A+",                    // String (optional)
  "emergencyContact": "+92-300-1111111", // String (optional)
  "createdAt": Timestamp,               // Timestamp - Registration date
  "updatedAt": Timestamp                 // Timestamp (optional)
}
```

---

### 6.4 `reviews` Collection

```javascript
reviews/{reviewId}
{
  "doctorId": "abc123",                  // String - Reference to doctor
  "doctorName": "Dr. Ahmad Khan",        // String - Doctor name
  "patientId": "user123",               // String - Patient Auth UID
  "patientName": "Ali Hassan",          // String - Patient name
  "patientImage": "https://...",        // String - Patient image URL
  "rating": 4.5,                         // Number - Rating (1-5)
  "comment": "Great doctor...",          // String - Review text
  "isApproved": false,                   // Boolean - Admin approval status
  "createdAt": Timestamp                 // Timestamp - Review date
}
```

**Review Flow:**
```
Patient submits review → isApproved = false (Pending)
Admin approves → isApproved = true → Doctor rating recalculated
Admin disapproves → isApproved = false
Admin deletes → Review removed → Doctor rating recalculated
```

---

### 6.5 `admins` Collection

```javascript
admins/{adminId}  // adminId = Firebase Auth UID
{
  "name": "Admin User",                  // String - Admin name
  "email": "admin@doctorclinic.com",     // String - Admin email
  "role": "admin",                       // String - "admin" | "super_admin"
  "createdAt": Timestamp                 // Timestamp - Created date
}
```

---

## 7. Pages & Features

### 7.1 Login Page (`/login`)
- Email + Password login
- Validates against Firebase Auth
- Checks `admins` collection to verify admin access
- Shows error messages for invalid credentials
- Redirects to dashboard on success

### 7.2 Dashboard (`/`)
- **Stats Cards**: Total Doctors, Total Appointments, Total Users, Revenue
- **Quick Stats**: Pending Appointments, Pending Verifications, Pending Reviews
- **Recent Appointments**: Last 5 appointments with status
- **Pending Doctor Verifications**: Doctors awaiting approval
- **Recent Reviews**: Latest 3 reviews with approval status
- All data is **real-time** (uses Firestore `onSnapshot`)

### 7.3 Doctors Page (`/doctors`)
- **Search**: By name, specialty, email
- **Filters**: All, Pending, Approved, Rejected, Available
- **Table**: Shows doctor info, specialty, hospital, fee, rating, status, verification
- **Actions**:
  - View detail page
  - Edit doctor (modal with all fields)
  - Approve doctor (set verified)
  - Reject doctor (with reason)
  - Toggle availability
  - Delete doctor
- **Add Doctor**: Modal form with all fields (name, email, phone, specialty, about, image, qualifications, schedule, hospital, license)

### 7.4 Doctor Detail (`/doctors/:id`)
- **Header**: Photo, name, specialty, rating, experience, badges
- **Personal Info**: Email, phone, license, fee, hours, join date
- **Professional Details**: Hospital, address, available days, qualifications, about
- **Documents**: License document, degree images (with image preview modal)
- **Appointments**: Table of all doctor's appointments
- **Reviews**: All reviews for this doctor
- **Actions**: Approve, Reject (with reason), Toggle Availability

### 7.5 Appointments Page (`/appointments`)
- **Stats Bar**: Pending, Confirmed, Completed, Cancelled/Rejected counts
- **Search**: By patient name, doctor name, phone
- **Filters**: All, Pending, AwaitingApproval, Confirmed, Completed, Cancelled, Rejected
- **Table**: Patient, Doctor, Date, Time, Fee, Status, Payment slip, Actions
- **Status Change**: Click status badge → dropdown to change status
- **Actions**:
  - View full detail (modal)
  - Confirm appointment
  - Reject appointment (with reason)
  - Mark as completed
  - View payment slip (image modal)

### 7.6 Users Page (`/users`)
- **Stats**: Total Patients, New This Month
- **Search**: By name, email, phone
- **Table**: User info, email, phone, joined date
- **Detail Modal**:
  - Profile info (name, email, phone, gender, DOB, blood group, address, emergency contact)
  - Appointment History (all appointments for this user)

### 7.7 Reviews Page (`/reviews`)
- **Stats**: Total Reviews, Approved, Pending, Average Rating
- **Search**: By patient, doctor, comment
- **Filters**: All, Pending, Approved
- **Table**: Patient, Doctor, Rating (stars), Comment, Date, Status
- **Actions**:
  - View full detail (modal)
  - Approve review → recalculates doctor rating
  - Disapprove review → recalculates doctor rating
  - Delete review → recalculates doctor rating
- **Doctor Rating Recalculation**: Automatically updates doctor's `rating` and `totalReviews` fields when reviews are approved/disapproved/deleted

### 7.8 Settings Page (`/settings`)
- **Admin Profile**: Name, email, role, admin ID
- **Change Password**: Current password → New password with validation
- **App Info**: Version, framework, backend details

---

## 8. Admin Authentication

### How It Works
1. Admin enters email/password on login page
2. Firebase Auth validates credentials (`signInWithEmailAndPassword`)
3. App checks `admins/{uid}` document exists in Firestore
4. If admin document exists → allow access
5. If not → deny access ("You are not an admin")
6. Auth state persists across page refreshes (`onAuthStateChanged`)

### Creating Admin Account
```
Step 1: Create user in Firebase Auth (email + password)
Step 2: Copy the user's UID
Step 3: In Firestore → admins collection → create document with ID = UID
Step 4: Add fields: name, email, role ("admin"), createdAt
```

### Default Login
- **Email**: admin@doctorclinic.com
- **Password**: admin123
(You must create this in Firebase first)

---

## 9. API Reference (Firestore Operations)

### Dashboard Queries
```javascript
// Real-time listeners for all collections
onSnapshot(collection(db, 'doctors'), callback)
onSnapshot(collection(db, 'appointments'), callback)
onSnapshot(collection(db, 'users'), callback)
onSnapshot(collection(db, 'reviews'), callback)
```

### Doctor Operations
```javascript
// Get all doctors (real-time)
onSnapshot(collection(db, 'doctors'), callback)

// Add doctor
addDoc(collection(db, 'doctors'), { ...doctorData, createdAt: Timestamp.now() })

// Update doctor
updateDoc(doc(db, 'doctors', doctorId), { field: value })

// Approve doctor
updateDoc(doc(db, 'doctors', doctorId), {
  isVerified: true,
  verificationStatus: 'approved',
  rejectionReason: ''
})

// Reject doctor
updateDoc(doc(db, 'doctors', doctorId), {
  isVerified: false,
  verificationStatus: 'rejected',
  rejectionReason: 'Incomplete documents'
})

// Toggle availability
updateDoc(doc(db, 'doctors', doctorId), { isAvailable: !currentValue })

// Delete doctor
deleteDoc(doc(db, 'doctors', doctorId))
```

### Appointment Operations
```javascript
// Get all appointments (real-time)
onSnapshot(collection(db, 'appointments'), callback)

// Update status
updateDoc(doc(db, 'appointments', appointmentId), { status: 'confirmed' })

// Reject with reason
updateDoc(doc(db, 'appointments', appointmentId), {
  status: 'rejected',
  rejectionReason: 'Doctor unavailable'
})

// Get doctor's appointments
query(collection(db, 'appointments'), where('doctorId', '==', doctorId))

// Get patient's appointments
query(collection(db, 'appointments'), where('patientId', '==', patientId))
```

### Review Operations
```javascript
// Get all reviews (real-time)
onSnapshot(collection(db, 'reviews'), callback)

// Approve review
updateDoc(doc(db, 'reviews', reviewId), { isApproved: true })

// Disapprove review
updateDoc(doc(db, 'reviews', reviewId), { isApproved: false })

// Delete review
deleteDoc(doc(db, 'reviews', reviewId))

// Recalculate doctor rating (after review changes)
// Filter approved reviews for doctor → calculate average → update doctor document
updateDoc(doc(db, 'doctors', doctorId), {
  rating: calculatedAverage,
  totalReviews: approvedReviewsCount
})
```

### Auth Operations
```javascript
// Login
signInWithEmailAndPassword(auth, email, password)

// Logout
signOut(auth)

// Check admin status
getDoc(doc(db, 'admins', user.uid))

// Change password
reauthenticateWithCredential(user, credential)
updatePassword(user, newPassword)
```

---

## 10. Deployment

### Firebase Hosting
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Init hosting
firebase init hosting
# Select your project, set build dir to "build"

# Build & Deploy
npm run build
firebase deploy --only hosting
```

### Netlify
```bash
npm run build
# Upload build/ folder to Netlify
# Or connect GitHub repo for auto-deploy
```

### Environment Variables
Make sure to set these environment variables in your hosting platform:
- `REACT_APP_FIREBASE_API_KEY`
- `REACT_APP_FIREBASE_AUTH_DOMAIN`
- `REACT_APP_FIREBASE_PROJECT_ID`
- `REACT_APP_FIREBASE_STORAGE_BUCKET`
- `REACT_APP_FIREBASE_MESSAGING_SENDER_ID`
- `REACT_APP_FIREBASE_APP_ID`

---

## 11. Mobile App Connection

The web admin panel connects to the **exact same Firebase project** as the Flutter mobile app.

| Component | Technology |
|---|---|
| Mobile App | Flutter (Android & iOS) |
| Web Admin Panel | React.js |
| Database | Cloud Firestore (shared) |
| Authentication | Firebase Auth (shared) |
| File Storage | Firebase Storage (shared) |

### Real-time Sync
- Admin approves a doctor → Mobile app shows doctor as verified instantly
- Admin changes appointment status → Patient sees update in real-time
- Admin approves review → Review appears on doctor's profile in mobile app

### Collections Used by Both
| Collection | Mobile App | Admin Panel |
|---|---|---|
| `doctors` | Read (browse doctors) | Read + Write (manage) |
| `appointments` | Read + Create (book) | Read + Update (manage) |
| `users` | Read + Write (own profile) | Read only (view) |
| `reviews` | Read + Create (submit) | Read + Write (moderate) |
| `admins` | Not used | Read (auth check) |

---

## 12. Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Doctors - Anyone can read, only admin can write
    match /doctors/{doctorId} {
      allow read: if true;
      allow write: if request.auth != null &&
        get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.role == 'admin';
    }

    // Appointments - Users read/write own, admin reads/writes all
    match /appointments/{appointmentId} {
      allow read: if request.auth != null &&
        (resource.data.patientId == request.auth.uid ||
         get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.role == 'admin');
      allow create: if request.auth != null;
      allow update: if request.auth != null &&
        (resource.data.patientId == request.auth.uid ||
         get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.role == 'admin');
    }

    // Users - Own data only
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Reviews - Anyone can read, authenticated can create, admin can manage
    match /reviews/{reviewId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null &&
        get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.role == 'admin';
    }

    // Admins - Only own document readable
    match /admins/{adminId} {
      allow read: if request.auth != null && request.auth.uid == adminId;
      allow write: if false; // Manual only via Firebase Console
    }
  }
}
```

---

## 13. Firestore Indexes Required

Create these composite indexes in Firebase Console → Firestore → Indexes:

1. **appointments** collection:
   - `patientId` (Ascending) + `appointmentDate` (Descending)
   - `doctorId` (Ascending) + `appointmentDate` (Descending)
   - `status` (Ascending) + `appointmentDate` (Descending)

2. **doctors** collection:
   - `verificationStatus` (Ascending) + `createdAt` (Descending)
   - `specialty` (Ascending) + `rating` (Descending)

3. **reviews** collection:
   - `doctorId` (Ascending) + `createdAt` (Descending)
   - `isApproved` (Ascending) + `createdAt` (Descending)

---

## 14. Sample Test Data

### Add Admin (Firebase Console)
```
Collection: admins
Document ID: <your-firebase-auth-uid>
Fields:
  name: "Admin"
  email: "admin@doctorclinic.com"
  role: "admin"
  createdAt: <server timestamp>
```

### Add Sample Doctor
```json
{
  "name": "Dr. Ahmad Khan",
  "email": "ahmad.khan@clinic.com",
  "phone": "+92-300-1234567",
  "specialty": "Cardiologist",
  "about": "Renowned cardiologist with 15+ years of experience.",
  "profileImage": "https://randomuser.me/api/portraits/men/32.jpg",
  "experienceYears": 15,
  "rating": 4.9,
  "totalReviews": 0,
  "consultationFee": 2500,
  "isAvailable": true,
  "availableDays": ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"],
  "startTime": "09:00",
  "endTime": "17:00",
  "hospitalName": "City Medical Center",
  "hospitalAddress": "123 Main Boulevard, Gulberg III, Lahore",
  "qualifications": ["MBBS - KEMU", "MD - Cardiology", "Fellowship - USA"],
  "isVerified": true,
  "verificationStatus": "approved",
  "licenseNumber": "PMC-12345",
  "rejectionReason": "",
  "licenseDocument": "",
  "degreeImages": [],
  "createdAt": "<timestamp>"
}
```

---

**End of Documentation**

*Doctor Clinic Admin Panel v1.0 - React + Firebase*
