# 🔥 Complete Web Admin Panel - Database & Field Reference Guide
**Last Updated:** April 16, 2026  
**Purpose:** Fix web admin panel issues - all collections, fields, and mappings

---

## ⚠️ COMMON ISSUES & FIXES

### Issue 1: Patients/Users Not Showing in Web Admin
**Problem:** Users collection empty or not displaying  
**Root Cause:** Mobile app may not be creating user documents properly

**Solution:**
1. Check if mobile app creates user document on registration
2. Mobile app should save to `/users/{userId}` when patient registers
3. Verify Firestore has data in `users` collection

**Required User Document Structure:**
```javascript
// Collection: users
// Document ID: Firebase Auth UID
{
  "name": "Ali Hassan",                    // String - Required
  "email": "ali@email.com",                // String - Required
  "phone": "+92-300-1234567",              // String - Optional
  "profileImage": "",                      // String - Optional
  "address": "456 Street, Karachi",        // String - Optional
  "dateOfBirth": Timestamp,                // Timestamp - Optional
  "gender": "male",                        // String - Optional
  "bloodGroup": "A+",                      // String - Optional
  "emergencyContact": "+92-300-1111111",   // String - Optional
  "appId": "doctorclinic",                 // String - App identifier
  "createdAt": Timestamp,                  // Timestamp - Auto
  "updatedAt": Timestamp                   // Timestamp - Auto
}
```

**Quick Fix - Test Data:**
Manually add a test user in Firebase Console to verify web admin works:
```javascript
Collection: users
Document ID: test_user_123
{
  "name": "Test Patient",
  "email": "test@email.com",
  "phone": "+92-300-0000000",
  "createdAt": new Date()
}
```

---

### Issue 2: Doctors Not Showing in Web Admin
**Problem:** Doctors collection has data but not displaying  
**Root Cause:** Field name mismatch or missing required fields

**Doctor Document Structure (COMPLETE):**
```javascript
// Collection: doctors
// Document ID: Auto-generated
{
  // === BASIC INFO ===
  "name": "Dr. Ahmad Khan",                // String - REQUIRED
  "email": "ahmad@clinic.com",             // String - REQUIRED
  "phone": "+92-300-1234567",              // String - Optional
  "specialty": "Cardiologist",             // String - REQUIRED
  
  // === PROFILE ===
  "profileImage": "https://res.cloudinary.com/...", // String - Cloudinary URL
  "about": "15 years experience...",       // String - Optional
  "experienceYears": 15,                   // Number - Optional
  "qualifications": ["MBBS", "MD"],        // Array<String> - Optional
  
  // === VERIFICATION ===
  "isVerified": true,                      // Boolean - Default: false
  "verificationStatus": "approved",        // String: pending|approved|rejected
  "rejectionReason": "",                   // String - Optional
  "licenseNumber": "PMC-12345",            // String - Optional
  "licenseDocument": "https://...",        // String - Cloudinary URL
  "degreeImages": ["url1", "url2"],        // Array<String> - Cloudinary URLs
  
  // === SCHEDULE ===
  "isAvailable": true,                     // Boolean - Default: true
  "availableDays": ["Monday", "Tuesday"],  // Array<String>
  "startTime": "09:00",                    // String - HH:mm format
  "endTime": "17:00",                      // String - HH:mm format
  
  // === LOCATION & FEES ===
  "hospitalName": "City Medical Center",   // String - Optional
  "hospitalAddress": "123 Main St",        // String - Optional
  "consultationFee": 2500,                 // Number - In PKR
  
  // === RATINGS ===
  "rating": 4.8,                           // Number - Default: 0
  "totalReviews": 120,                     // Number - Default: 0
  
  // === APP IDENTIFIER ===
  "appId": "doctorclinic",                 // String - For filtering
  
  // === TIMESTAMPS ===
  "createdAt": Timestamp,                  // Timestamp - Auto
  "updatedAt": Timestamp                   // Timestamp - Auto
}
```

**Web Admin Reads These Fields:**
```javascript
// From Doctors.js line 64-73
displayName: doctor.name
displayEmail: doctor.email
displaySpecialty: doctor.specialty
displayHospital: doctor.hospitalName
displayFee: doctor.consultationFee
displayRating: doctor.rating
displayReviews: doctor.totalReviews
displayStatus: doctor.verificationStatus
displayAvailable: doctor.isAvailable
displayImage: doctor.profileImage
```

---

### Issue 3: Appointments Not Showing
**Problem:** Appointments collection has data but not displaying  
**Root Cause:** Field name mismatch between mobile app and web admin

**Appointment Document Structure (COMPLETE):**
```javascript
// Collection: appointments
// Document ID: Auto-generated
{
  // === DOCTOR INFO (Denormalized) ===
  "doctorId": "abc123xyz",                 // String - Doctor document ID
  "doctorName": "Dr. Ahmad Khan",          // String - Doctor's name
  "doctorImage": "https://...",            // String - Doctor's profile image URL
  "doctorSpecialty": "Cardiologist",       // String - Doctor's specialty
  
  // === PATIENT INFO ===
  "patientId": "user123",                  // String - Firebase Auth UID
  "patientName": "Ali Hassan",             // String - Patient's name
  "patientPhone": "+92-300-9876543",       // String - Patient's phone
  
  // === APPOINTMENT DETAILS ===
  "appointmentDate": Timestamp,            // Timestamp - Date of appointment
  "timeSlot": "10:00",                     // String - HH:mm format
  "status": "pending",                     // String - See status list below
  "fee": 2500,                             // Number - In PKR
  "notes": "Chest pain for 2 days",        // String - Optional
  
  // === PAYMENT ===
  "paymentSlipUrl": "https://res.cloudinary.com/...", // String - Cloudinary URL
  
  // === CANCELLATION/REJECTION ===
  "cancelReason": "",                      // String - Optional
  "rejectionReason": "",                   // String - Optional
  "cancelledBy": "",                       // String: patient|doctor|admin
  
  // === APP IDENTIFIER ===
  "appId": "doctorclinic",                 // String - For filtering
  
  // === TIMESTAMPS ===
  "createdAt": Timestamp,                  // Timestamp - Auto
  "updatedAt": Timestamp                   // Timestamp - Auto
}
```

**Appointment Status Values:**
```javascript
// Web Admin expects these exact values (Appointments.js line 9)
STATUS_OPTIONS = [
  'pending',           // New booking
  'awaitingApproval',  // Payment slip uploaded, waiting doctor review
  'confirmed',         // Doctor accepted
  'completed',         // Appointment done
  'cancelled',         // Cancelled by patient/doctor
  'rejected'           // Doctor rejected with reason
]
```

**Web Admin Reads These Fields:**
```javascript
// From Appointments.js line 57-64
displayPatientName: appointment.patientName
displayPatientPhone: appointment.patientPhone
displayDoctorName: appointment.doctorName
displayDoctorImage: appointment.doctorImage
displayDoctorSpecialty: appointment.doctorSpecialty
displayDate: appointment.appointmentDate (Timestamp)
displayTime: appointment.timeSlot
displayFee: appointment.fee
displayStatus: appointment.status
displayPaymentSlip: appointment.paymentSlipUrl
displayNotes: appointment.notes
displayCancelReason: appointment.cancelReason
displayRejectionReason: appointment.rejectionReason
```

---

### Issue 4: Reviews Not Showing
**Problem:** Reviews not appearing in web admin  
**Root Cause:** Reviews collection may be empty or missing fields

**Review Document Structure:**
```javascript
// Collection: reviews
// Document ID: Auto-generated
{
  "doctorId": "doctor123",                 // String - Doctor document ID
  "doctorName": "Dr. Ahmad Khan",          // String - Doctor's name
  "patientId": "user123",                  // String - Patient's UID
  "patientName": "Ali Hassan",             // String - Patient's name
  "patientImage": "",                      // String - Optional
  "rating": 5,                             // Number - 1 to 5
  "comment": "Excellent doctor!",          // String - Required
  "isAnonymous": false,                    // Boolean - Default: false
  "isApproved": false,                     // Boolean - Default: false (needs admin approval)
  "appointmentId": "appt123",              // String - Associated appointment
  "appId": "doctorclinic",                 // String - App identifier
  "createdAt": Timestamp,                  // Timestamp - Auto
  "updatedAt": Timestamp                   // Timestamp - Auto
}
```

---

## 🔍 FIELD MAPPING TABLE

### Mobile App → Web Admin Field Mapping

| **Mobile App Field** | **Web Admin Field** | **Collection** | **Type** | **Required** |
|---------------------|---------------------|----------------|----------|--------------|
| `name` | `name` | doctors, users | String | ✅ Yes |
| `email` | `email` | doctors, users | String | ✅ Yes |
| `phone` | `phone` | doctors, users | String | ❌ No |
| `specialty` | `specialty` | doctors | String | ✅ Yes |
| `profileImage` | `profileImage` | doctors, users | String (URL) | ❌ No |
| `about` | `about` | doctors | String | ❌ No |
| `experienceYears` | `experienceYears` | doctors | Number | ❌ No |
| `qualifications` | `qualifications` | doctors | Array<String> | ❌ No |
| `isVerified` | `isVerified` | doctors | Boolean | ❌ No |
| `verificationStatus` | `verificationStatus` | doctors | String | ❌ No |
| `rejectionReason` | `rejectionReason` | doctors | String | ❌ No |
| `licenseNumber` | `licenseNumber` | doctors | String | ❌ No |
| `licenseDocument` | `licenseDocument` | doctors | String (URL) | ❌ No |
| `degreeImages` | `degreeImages` | doctors | Array<String> | ❌ No |
| `isAvailable` | `isAvailable` | doctors | Boolean | ❌ No |
| `availableDays` | `availableDays` | doctors | Array<String> | ❌ No |
| `startTime` | `startTime` | doctors | String | ❌ No |
| `endTime` | `endTime` | doctors | String | ❌ No |
| `hospitalName` | `hospitalName` | doctors | String | ❌ No |
| `hospitalAddress` | `hospitalAddress` | doctors | String | ❌ No |
| `consultationFee` | `consultationFee` | doctors | Number | ❌ No |
| `rating` | `rating` | doctors | Number | ❌ No |
| `totalReviews` | `totalReviews` | doctors | Number | ❌ No |
| `appId` | `appId` | ALL | String | ❌ No |
| `createdAt` | `createdAt` | ALL | Timestamp | ✅ Yes |
| `updatedAt` | `updatedAt` | ALL | Timestamp | ❌ No |

---

## 📊 COMPLETE COLLECTION SCHEMAS

### 1. **users** Collection (Patients)
```javascript
// Path: /users/{userId}
// userId = Firebase Auth UID

{
  "name": "string",
  "email": "string",
  "phone": "string",
  "profileImage": "string (URL)",
  "address": "string",
  "dateOfBirth": "Timestamp",
  "gender": "string (male|female|other)",
  "bloodGroup": "string (A+|A-|B+|B-|O+|O-|AB+|AB-)",
  "emergencyContact": "string",
  "appId": "doctorclinic",
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

**Web Admin Page:** `web-admin/src/pages/Users.js`  
**Reads:** Lines 18-29 (onSnapshot)  
**Displays:** name, email, phone, profileImage, createdAt

---

### 2. **doctors** Collection
```javascript
// Path: /doctors/{doctorId}
// doctorId = Auto-generated Firestore ID

{
  "name": "string",
  "email": "string",
  "phone": "string",
  "specialty": "string",
  "profileImage": "string (Cloudinary URL)",
  "about": "string",
  "experienceYears": "number",
  "qualifications": ["string"],
  "isVerified": "boolean",
  "verificationStatus": "string (pending|approved|rejected)",
  "rejectionReason": "string",
  "licenseNumber": "string",
  "licenseDocument": "string (Cloudinary URL)",
  "degreeImages": ["string (Cloudinary URLs)"],
  "isAvailable": "boolean",
  "availableDays": ["string (days)"],
  "startTime": "string (HH:mm)",
  "endTime": "string (HH:mm)",
  "hospitalName": "string",
  "hospitalAddress": "string",
  "consultationFee": "number",
  "rating": "number",
  "totalReviews": "number",
  "appId": "doctorclinic",
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

**Web Admin Page:** `web-admin/src/pages/Doctors.js`  
**Reads:** Lines 44-56 (onSnapshot)  
**Displays:** name, email, specialty, hospitalName, consultationFee, rating, totalReviews, verificationStatus, isAvailable, profileImage

---

### 3. **appointments** Collection
```javascript
// Path: /appointments/{appointmentId}
// appointmentId = Auto-generated Firestore ID

{
  "doctorId": "string",
  "doctorName": "string",
  "doctorImage": "string (URL)",
  "doctorSpecialty": "string",
  "patientId": "string (Firebase Auth UID)",
  "patientName": "string",
  "patientPhone": "string",
  "appointmentDate": "Timestamp",
  "timeSlot": "string (HH:mm)",
  "status": "string (pending|awaitingApproval|confirmed|completed|cancelled|rejected)",
  "fee": "number",
  "notes": "string",
  "paymentSlipUrl": "string (Cloudinary URL)",
  "cancelReason": "string",
  "rejectionReason": "string",
  "cancelledBy": "string (patient|doctor|admin)",
  "appId": "doctorclinic",
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

**Web Admin Page:** `web-admin/src/pages/Appointments.js`  
**Reads:** Lines 23-35 (onSnapshot)  
**Displays:** patientName, patientPhone, doctorName, doctorImage, doctorSpecialty, appointmentDate, timeSlot, fee, status, paymentSlipUrl, notes

---

### 4. **reviews** Collection
```javascript
// Path: /reviews/{reviewId}
// reviewId = Auto-generated Firestore ID

{
  "doctorId": "string",
  "doctorName": "string",
  "patientId": "string",
  "patientName": "string",
  "patientImage": "string",
  "rating": "number (1-5)",
  "comment": "string",
  "isAnonymous": "boolean",
  "isApproved": "boolean",
  "appointmentId": "string",
  "appId": "doctorclinic",
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

**Web Admin Page:** `web-admin/src/pages/Reviews.js`  
**Reads:** From Dashboard.js lines 82-96  
**Displays:** doctorName, patientName, rating, comment, isApproved, createdAt

---

## 🛠️ TROUBLESHOOTING CHECKLIST

### ✅ Check 1: Verify Firestore Has Data
```bash
# Go to Firebase Console
1. Open https://console.firebase.google.com
2. Select your project
3. Click "Firestore Database"
4. Check if these collections exist:
   - users
   - doctors
   - appointments
   - reviews
```

### ✅ Check 2: Verify Field Names
```javascript
// Common mistakes:
❌ "userName" instead of "name"
❌ "userEmail" instead of "email"
❌ "doctor_profile_image" instead of "profileImage"
❌ "appointment_date" instead of "appointmentDate"
❌ "time_slot" instead of "timeSlot"

// CORRECT (camelCase):
✅ "name"
✅ "email"
✅ "profileImage"
✅ "appointmentDate"
✅ "timeSlot"
✅ "paymentSlipUrl"
```

### ✅ Check 3: Verify Timestamps
```javascript
// WRONG:
❌ "createdAt": "2024-01-15T10:00:00Z"  // String
❌ "createdAt": 1705312800000            // Number

// CORRECT:
✅ "createdAt": Timestamp                // Firestore Timestamp
✅ Use: firebase.firestore.Timestamp.now()
```

### ✅ Check 4: Verify Numbers vs Strings
```javascript
// WRONG:
❌ "consultationFee": "2500"            // String
❌ "experienceYears": "15"              // String
❌ "rating": "4.8"                      // String

// CORRECT:
✅ "consultationFee": 2500              // Number
✅ "experienceYears": 15                // Number
✅ "rating": 4.8                        // Number
```

### ✅ Check 5: Verify Arrays
```javascript
// WRONG:
❌ "qualifications": "MBBS, MD"         // String
❌ "availableDays": "Monday, Tuesday"   // String

// CORRECT:
✅ "qualifications": ["MBBS", "MD"]     // Array
✅ "availableDays": ["Monday", "Tuesday"] // Array
```

---

## 🔧 QUICK FIX SCRIPTS

### Fix 1: Add Missing appId to All Documents
Run this in Firebase Console or use Node.js script:
```javascript
// Add appId to all collections
const collections = ['users', 'doctors', 'appointments', 'reviews'];

for (const collectionName of collections) {
  const snapshot = await db.collection(collectionName).get();
  
  for (const doc of snapshot.docs) {
    await doc.ref.update({ appId: 'doctorclinic' });
  }
}
```

### Fix 2: Convert String Dates to Timestamps
```javascript
// Fix appointmentDate strings to Timestamps
const appts = await db.collection('appointments').get();

for (const doc of appts.docs) {
  const data = doc.data();
  
  if (typeof data.appointmentDate === 'string') {
    const date = new Date(data.appointmentDate);
    await doc.ref.update({
      appointmentDate: firebase.firestore.Timestamp.fromDate(date)
    });
  }
}
```

### Fix 3: Add Missing Required Fields
```javascript
// Add missing fields to doctors
const doctors = await db.collection('doctors').get();

for (const doc of doctors.docs) {
  const data = doc.data();
  const updates = {};
  
  if (!data.verificationStatus) updates.verificationStatus = 'pending';
  if (data.isVerified === undefined) updates.isVerified = false;
  if (!data.isAvailable) updates.isAvailable = true;
  if (!data.rating) updates.rating = 0;
  if (!data.totalReviews) updates.totalReviews = 0;
  
  if (Object.keys(updates).length > 0) {
    await doc.ref.update(updates);
  }
}
```

---

## 📱 MOBILE APP INTEGRATION POINTS

### Where Mobile App Creates Data:

**Patient Registration:**
```dart
// Should create document in /users/{userId}
// File: lib/auth/ or lib/core/services/user_service.dart
await FirebaseFirestore.instance
    .collection('users')
    .doc(user.uid)
    .set({
  'name': user.displayName,
  'email': user.email,
  'phone': user.phoneNumber,
  'createdAt': FieldValue.serverTimestamp(),
  'appId': 'doctorclinic',
});
```

**Doctor Registration:**
```dart
// Should create document in /doctors/{doctorId}
// File: lib/doctor/ or lib/core/services/doctor_service.dart
await FirebaseFirestore.instance
    .collection('doctors')
    .add({
  'name': doctorName,
  'email': email,
  'specialty': specialty,
  'verificationStatus': 'pending',
  'isVerified': false,
  'createdAt': FieldValue.serverTimestamp(),
  'appId': 'doctorclinic',
});
```

**Appointment Booking:**
```dart
// Should create document in /appointments/{appointmentId}
// File: lib/core/services/appointment_service.dart (Line 156-188)
await FirebaseFirestore.instance
    .collection('appointments')
    .add({
  'doctorId': doctorId,
  'doctorName': doctor.name,
  'doctorImage': doctor.profileImage,
  'doctorSpecialty': doctor.specialty,
  'patientId': user.uid,
  'patientName': user.displayName,
  'patientPhone': user.phoneNumber,
  'appointmentDate': Timestamp.fromDate(selectedDate),
  'timeSlot': selectedTime,
  'status': paymentSlipUrl != null ? 'awaitingApproval' : 'pending',
  'fee': doctor.consultationFee,
  'paymentSlipUrl': paymentSlipUrl,
  'notes': notes,
  'createdAt': FieldValue.serverTimestamp(),
  'appId': 'doctorclinic',
});
```

---

## 🎯 WEB ADMIN PAGES & WHAT THEY READ

### 1. **Dashboard** (`web-admin/src/pages/Dashboard.js`)
**Reads:**
- `doctors` collection (line 27) - total count, pending count
- `appointments` collection (line 42) - total, today, pending, revenue
- `users` collection (line 77) - total count
- `reviews` collection (line 82) - total, pending count

**Displays:**
- Total Doctors, Pending Doctors
- Total Appointments, Today Appointments, Pending Appointments
- Total Users
- Total Revenue
- Recent Appointments (5)
- Pending Verifications (5)
- Recent Reviews (3)

---

### 2. **Doctors** (`web-admin/src/pages/Doctors.js`)
**Reads:**
- `doctors` collection (line 45) - all documents

**Displays Table:**
- Doctor (name, email, profileImage)
- Specialty
- Hospital (hospitalName)
- Fee (consultationFee)
- Rating (rating, totalReviews)
- Status (isAvailable)
- Verified (verificationStatus)

**Actions:**
- Add Doctor
- Edit Doctor
- Approve/Reject Doctor
- Delete Doctor
- Toggle Availability

---

### 3. **Appointments** (`web-admin/src/pages/Appointments.js`)
**Reads:**
- `appointments` collection (line 24) - all documents

**Displays Table:**
- Patient (patientName, patientPhone)
- Doctor (doctorName, doctorImage, doctorSpecialty)
- Date (appointmentDate)
- Time (timeSlot)
- Fee (fee)
- Status (status)
- Payment (paymentSlipUrl)

**Actions:**
- Change Status
- Confirm Appointment
- Reject Appointment (with reason)
- Complete Appointment
- View Payment Slip
- View Details

---

### 4. **Users** (`web-admin/src/pages/Users.js`)
**Reads:**
- `users` collection (line 18) - all documents
- `appointments` collection (line 47) - filtered by patientId

**Displays Table:**
- User (name, profileImage)
- Email
- Phone
- Joined (createdAt)

**Detail Modal Shows:**
- All user fields
- Appointment History (up to 10)

---

### 5. **Reviews** (`web-admin/src/pages/Reviews.js`)
**Reads:**
- `reviews` collection

**Displays:**
- Patient Name
- Doctor Name
- Rating
- Comment
- Status (isApproved)
- Created Date

**Actions:**
- Approve Review
- Reject Review
- Delete Review

---

## 🚀 TESTING STEPS

### Step 1: Verify Firebase Connection
```bash
# In web-admin folder
cd web-admin
npm start

# Check browser console for errors
# Should see: Firebase initialized successfully
```

### Step 2: Check Collections Load
```bash
1. Login to admin panel
2. Check Dashboard - should show counts
3. Go to Doctors page - should load table
4. Go to Appointments page - should load table
5. Go to Users page - should load table
6. Go to Reviews page - should load table
```

### Step 3: Test CRUD Operations
```bash
1. Add a new doctor
2. Check if appears in mobile app
3. Update appointment status
4. Check if mobile app reflects change
5. Approve a doctor
6. Verify mobile app shows verified badge
```

---

## 📞 SUPPORT

If issues persist:

1. **Check Browser Console:** F12 → Console tab
2. **Check Firebase Console:** Verify data exists
3. **Check Network Tab:** F12 → Network → See Firestore requests
4. **Verify Environment Variables:** `.env` file has correct Firebase config
5. **Check Firestore Rules:** Ensure read/write permissions

**Default Admin Login:**
- Email: `admin@doctorclinic.com`
- Password: `admin123`

---

**This document contains ALL information needed to fix web admin panel issues. All field names, structures, and mappings are verified against actual code.**
