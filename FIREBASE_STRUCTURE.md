# Firebase Database Structure - Doctor Clinic App

## Overview
This document describes the Firebase Firestore database structure for the Doctor Clinic application. Use this structure when building your Admin Panel.

---

## Collections

### 1. `doctors` Collection
Stores all doctor information.

```javascript
doctors/{doctorId}
{
  "name": "Dr. Ahmad Khan",              // String - Full name
  "email": "ahmad.khan@clinic.com",      // String - Email address
  "phone": "+92-300-1234567",            // String - Phone number
  "specialty": "Cardiologist",           // String - Medical specialty
  "about": "Dr. Ahmad Khan is a highly skilled cardiologist with 15 years of experience...",  // String - About text
  "imageUrl": "https://...",             // String - Profile image URL
  "experience": 15,                      // Number - Years of experience
  "rating": 4.9,                         // Number - Average rating (0-5)
  "totalReviews": 127,                   // Number - Total number of reviews
  "consultationFee": 2500,               // Number - Consultation fee in PKR
  "isAvailable": true,                   // Boolean - Currently accepting appointments
  "availableDays": [                     // Array<String> - Days available for appointments
    "Monday",
    "Tuesday", 
    "Wednesday",
    "Thursday",
    "Friday"
  ],
  "startTime": "09:00",                  // String - Daily start time (24hr format)
  "endTime": "17:00",                    // String - Daily end time (24hr format)
  "hospitalName": "City Medical Center", // String - Hospital/Clinic name
  "hospitalAddress": "123 Main Street, Lahore", // String - Hospital address
  "qualifications": [                    // Array<String> - Educational qualifications
    "MBBS",
    "MD - Cardiology",
    "Fellowship in Interventional Cardiology"
  ],
  "createdAt": Timestamp                 // Timestamp - When record was created
}
```

#### Specialties (suggested values):
- Cardiologist
- Dermatologist
- Neurologist
- Pediatrician
- Dentist
- Ophthalmologist
- Orthopedic
- ENT Specialist
- Gynecologist
- General Physician
- Psychiatrist
- Urologist

---

### 2. `appointments` Collection
Stores all appointment bookings.

```javascript
appointments/{appointmentId}
{
  "doctorId": "abc123",                  // String - Reference to doctor document
  "doctorName": "Dr. Ahmad Khan",        // String - Doctor's name (denormalized)
  "doctorImage": "https://...",          // String - Doctor's image URL (denormalized)
  "doctorSpecialty": "Cardiologist",     // String - Doctor's specialty (denormalized)
  "patientId": "user123",                // String - Firebase Auth UID of patient
  "patientName": "Ali Hassan",           // String - Patient's name
  "patientPhone": "+92-300-9876543",     // String - Patient's phone
  "appointmentDate": Timestamp,          // Timestamp - Date of appointment
  "timeSlot": "10:00",                   // String - Time slot (HH:mm format)
  "status": "pending",                   // String - Status: pending, confirmed, completed, cancelled
  "fee": 2500,                           // Number - Consultation fee
  "notes": "Chest pain for 2 days",      // String (optional) - Patient notes
  "cancelReason": "",                    // String (optional) - Reason if cancelled
  "createdAt": Timestamp                 // Timestamp - When booking was made
}
```

#### Appointment Status Values:
- `pending` - Awaiting confirmation from admin/doctor
- `confirmed` - Appointment confirmed
- `completed` - Appointment completed
- `cancelled` - Appointment cancelled

---

### 3. `users` Collection (Optional - for extended user profiles)

```javascript
users/{userId}  // userId = Firebase Auth UID
{
  "name": "Ali Hassan",
  "email": "ali.hassan@email.com",
  "phone": "+92-300-9876543",
  "photoUrl": "https://...",
  "dateOfBirth": Timestamp,
  "gender": "male",
  "address": "456 Street, Karachi",
  "bloodGroup": "A+",
  "emergencyContact": "+92-300-1111111",
  "createdAt": Timestamp
}
```

---

## Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Doctors - Read by anyone, write by admin only
    match /doctors/{doctorId} {
      allow read: if true;
      allow write: if request.auth != null && 
                   get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Appointments - Users can read/write their own appointments
    match /appointments/{appointmentId} {
      allow read: if request.auth != null && 
                  (resource.data.patientId == request.auth.uid || 
                   get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.role == 'admin');
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
                   (resource.data.patientId == request.auth.uid || 
                    get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Users - Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Admins collection
    match /admins/{adminId} {
      allow read: if request.auth != null && request.auth.uid == adminId;
      allow write: if false; // Only manually added via Firebase Console
    }
  }
}
```

---

## Admin Panel Features to Implement

### Dashboard
- Total doctors count
- Total appointments (today/week/month)
- Pending appointments
- Revenue statistics

### Doctor Management
- Add new doctor (all fields from doctors collection)
- Edit existing doctor
- Toggle availability
- Upload doctor image
- Delete doctor

### Appointment Management
- View all appointments (filter by date, status, doctor)
- Confirm pending appointments
- Mark as completed
- Cancel appointments
- View appointment details

### User Management (Optional)
- View registered users
- View user appointment history

---

## Sample Data for Testing

### Add this doctor via Firebase Console or Admin Panel:

```json
{
  "name": "Dr. Ahmad Khan",
  "email": "ahmad.khan@clinic.com",
  "phone": "+92-300-1234567",
  "specialty": "Cardiologist",
  "about": "Dr. Ahmad Khan is a renowned cardiologist with over 15 years of experience in treating heart conditions. He specializes in interventional cardiology and has performed over 5000 successful procedures.",
  "imageUrl": "https://randomuser.me/api/portraits/men/32.jpg",
  "experience": 15,
  "rating": 4.9,
  "totalReviews": 127,
  "consultationFee": 2500,
  "isAvailable": true,
  "availableDays": ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"],
  "startTime": "09:00",
  "endTime": "17:00",
  "hospitalName": "City Medical Center",
  "hospitalAddress": "123 Main Boulevard, Gulberg III, Lahore",
  "qualifications": ["MBBS - King Edward Medical University", "MD - Cardiology", "Fellowship - USA"],
  "createdAt": "2024-01-15T10:00:00Z"
}
```

---

## Indexes Required

Create these composite indexes in Firebase Console:

1. **appointments** collection:
   - `patientId` (Ascending) + `appointmentDate` (Descending)
   - `doctorId` (Ascending) + `appointmentDate` (Ascending) + `status` (Ascending)

2. **doctors** collection:
   - `specialty` (Ascending) + `rating` (Descending)

---

## Notes for Admin Panel Development

1. **Authentication**: Use Firebase Admin SDK for admin authentication
2. **Image Upload**: Use Firebase Storage for doctor images
3. **Real-time Updates**: Use Firestore listeners for real-time appointment updates
4. **Pagination**: Implement pagination for large lists (limit: 20-50 items per page)
5. **Search**: Implement search by doctor name using Firestore queries or Algolia

---

## Tech Stack Recommendation for Admin Panel

- **Framework**: React.js / Next.js / Angular
- **UI Library**: Ant Design / Material-UI / Tailwind CSS
- **Firebase SDK**: firebase-admin (Node.js) or firebase (Web)
- **State Management**: Redux / Zustand / Context API
- **Charts**: Chart.js / Recharts for dashboard analytics
