# Doctor Clinic - Web Admin Panel

A React-based admin panel for managing Doctor Clinic app data.

## 🔧 Firebase Configuration

### Step 1: Get Firebase Config
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project (same as mobile app)
3. Click ⚙️ Settings → Project Settings
4. Scroll down to "Your apps" → Click "Add app" → Select Web `</>`
5. Register app name: `doctorclinic-web`
6. Copy the Firebase config object

### Step 2: Create `.env` file
Create a `.env` file in this folder with your Firebase config:

```env
REACT_APP_FIREBASE_API_KEY=your-api-key
REACT_APP_FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
REACT_APP_FIREBASE_PROJECT_ID=your-project-id
REACT_APP_FIREBASE_STORAGE_BUCKET=your-project.appspot.com
REACT_APP_FIREBASE_MESSAGING_SENDER_ID=your-sender-id
REACT_APP_FIREBASE_APP_ID=your-app-id
```

## 📦 Installation

```bash
cd web-admin
npm install
npm start
```

## 🗄️ Firebase Collections Structure

### doctors
```javascript
{
  id: string,
  name: string,
  email: string,
  phone: string,
  specialty: string,
  about: string,
  profileImage: string,
  experienceYears: number,
  rating: number,
  totalReviews: number,
  consultationFee: number,
  isAvailable: boolean,
  isVerified: boolean,
  verificationStatus: 'pending' | 'approved' | 'rejected',
  rejectionReason: string,
  availableDays: string[],
  startTime: string,
  endTime: string,
  hospitalName: string,
  hospitalAddress: string,
  qualifications: string[],
  licenseNumber: string,
  licenseDocument: string,
  degreeImages: string[],
  createdAt: Timestamp
}
```

### appointments
```javascript
{
  id: string,
  doctorId: string,
  doctorName: string,
  doctorImage: string,
  doctorSpecialty: string,
  patientId: string,
  patientName: string,
  patientPhone: string,
  appointmentDate: Timestamp,
  timeSlot: string,
  status: 'pending' | 'confirmed' | 'completed' | 'cancelled',
  fee: number,
  notes: string,
  cancelReason: string,
  createdAt: Timestamp
}
```

### users
```javascript
{
  id: string,
  name: string,
  email: string,
  phone: string,
  address: string,
  profileImage: string,
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

### reviews
```javascript
{
  id: string,
  doctorId: string,
  doctorName: string,
  patientId: string,
  patientName: string,
  rating: number,
  comment: string,
  isApproved: boolean,
  createdAt: Timestamp
}
```

### admins
```javascript
{
  email: string,
  password: string,
  name: string,
  role: 'admin'
}
```

## 🔐 Admin Login

Default credentials:
- **Email:** admin@doctorclinic.com
- **Password:** admin123

## 🎯 Features

### Dashboard
- Total doctors, appointments, users, revenue
- Today's appointments count
- Pending doctor verifications
- Recent appointments & reviews

### Doctor Management
- View all doctors
- Approve/Reject doctor registrations
- View doctor details & documents
- Filter by verification status

### Appointment Management
- View all appointments
- Filter by status (pending, confirmed, completed, cancelled)
- Search by patient/doctor name
- Update appointment status

### User Management
- View all registered patients
- Search users

### Review Management
- Approve/Reject reviews
- Filter pending reviews

## 🔗 API Reference

### Firestore Queries

```javascript
// Get all doctors
const doctors = await getDocs(collection(db, 'doctors'));

// Get pending doctors
const pending = await getDocs(
  query(collection(db, 'doctors'), where('verificationStatus', '==', 'pending'))
);

// Get today's appointments
const today = new Date();
today.setHours(0, 0, 0, 0);
const tomorrow = new Date(today);
tomorrow.setDate(tomorrow.getDate() + 1);

const todayAppts = await getDocs(
  query(
    collection(db, 'appointments'),
    where('appointmentDate', '>=', today),
    where('appointmentDate', '<', tomorrow)
  )
);

// Update appointment status
await updateDoc(doc(db, 'appointments', appointmentId), {
  status: 'confirmed'
});

// Approve doctor
await updateDoc(doc(db, 'doctors', doctorId), {
  isVerified: true,
  verificationStatus: 'approved',
  rejectionReason: ''
});
```

## 📱 Mobile App Connection

The web admin panel connects to the same Firebase backend as the mobile app.
Any changes made in web will reflect in mobile app in real-time.

### Same Firebase Project
- Mobile App: Flutter
- Web Admin: React
- Database: Cloud Firestore
- Auth: Firebase Authentication
- Storage: Firebase Storage

## 🚀 Deployment

### Deploy to Firebase Hosting
```bash
npm run build
firebase deploy --only hosting
```

### Deploy to Netlify
```bash
npm run build
# Upload build folder to Netlify
```

## 📝 License

MIT License
