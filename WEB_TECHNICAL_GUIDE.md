# 🛠️ Doctor Clinic - Technical Implementation Guide

> **For Developers:** Step-by-step technical guide to build the web application

---

## 📁 Recommended Project Structure

```
doctorclinic-web/
├── apps/
│   ├── web/                      # Patient-facing website
│   │   ├── app/                  # Next.js app directory
│   │   │   ├── (auth)/
│   │   │   │   ├── login/
│   │   │   │   ├── register/
│   │   │   │   └── forgot-password/
│   │   │   ├── (main)/
│   │   │   │   ├── doctors/
│   │   │   │   ├── appointments/
│   │   │   │   └── profile/
│   │   │   ├── layout.tsx
│   │   │   └── page.tsx
│   │   ├── components/
│   │   │   ├── ui/               # shadcn/ui components
│   │   │   ├── forms/
│   │   │   ├── cards/
│   │   │   └── layouts/
│   │   ├── lib/
│   │   │   ├── api.ts
│   │   │   ├── auth.ts
│   │   │   └── utils.ts
│   │   └── styles/
│   │
│   ├── doctor/                   # Doctor portal
│   │   └── ... (similar structure)
│   │
│   └── admin/                    # Admin panel
│       └── ... (similar structure)
│
├── packages/
│   ├── ui/                       # Shared UI components
│   ├── config/                   # Shared config (tailwind, eslint)
│   └── types/                    # Shared TypeScript types
│
├── server/                       # Backend API
│   ├── src/
│   │   ├── config/
│   │   ├── controllers/
│   │   ├── middlewares/
│   │   ├── models/
│   │   ├── routes/
│   │   ├── services/
│   │   ├── utils/
│   │   └── index.ts
│   ├── prisma/
│   │   └── schema.prisma
│   └── package.json
│
├── docker-compose.yml
├── turbo.json                    # Turborepo config
└── package.json
```

---

## 🗄️ Prisma Schema (Database)

```prisma
// server/prisma/schema.prisma

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// ============== ENUMS ==============

enum UserRole {
  PATIENT
  DOCTOR
  ADMIN
}

enum Gender {
  MALE
  FEMALE
  OTHER
}

enum BloodGroup {
  A_POSITIVE
  A_NEGATIVE
  B_POSITIVE
  B_NEGATIVE
  O_POSITIVE
  O_NEGATIVE
  AB_POSITIVE
  AB_NEGATIVE
}

enum VerificationStatus {
  PENDING
  APPROVED
  REJECTED
}

enum AppointmentStatus {
  PENDING
  CONFIRMED
  COMPLETED
  CANCELLED
}

enum DayOfWeek {
  MONDAY
  TUESDAY
  WEDNESDAY
  THURSDAY
  FRIDAY
  SATURDAY
  SUNDAY
}

// ============== MODELS ==============

model User {
  id              String    @id @default(cuid())
  email           String    @unique
  passwordHash    String
  role            UserRole
  isEmailVerified Boolean   @default(false)
  isActive        Boolean   @default(true)
  lastLoginAt     DateTime?
  createdAt       DateTime  @default(now())
  updatedAt       DateTime  @updatedAt

  patient Patient?
  doctor  Doctor?
  admin   Admin?
  sessions Session[]
  notifications Notification[]

  @@index([email])
  @@index([role])
}

model Session {
  id           String   @id @default(cuid())
  userId       String
  refreshToken String   @unique
  userAgent    String?
  ipAddress    String?
  expiresAt    DateTime
  createdAt    DateTime @default(now())

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@index([userId])
}

model Patient {
  id               String      @id @default(cuid())
  userId           String      @unique
  name             String
  phone            String?
  profileImage     String?
  dateOfBirth      DateTime?
  gender           Gender?
  bloodGroup       BloodGroup?
  address          String?
  emergencyContact String?
  createdAt        DateTime    @default(now())
  updatedAt        DateTime    @updatedAt

  user         User          @relation(fields: [userId], references: [id], onDelete: Cascade)
  appointments Appointment[]
  reviews      Review[]

  @@index([userId])
}

model Doctor {
  id                 String             @id @default(cuid())
  userId             String             @unique
  name               String
  email              String
  phone              String
  specialty          String
  about              String             @db.Text
  profileImage       String?
  experienceYears    Int
  rating             Float              @default(0)
  totalReviews       Int                @default(0)
  consultationFee    Decimal            @db.Decimal(10, 2)
  isAvailable        Boolean            @default(true)
  startTime          String             // "HH:mm"
  endTime            String             // "HH:mm"
  hospitalName       String
  hospitalAddress    String
  hospitalLat        Float?
  hospitalLng        Float?
  qualifications     String[]
  licenseNumber      String             @unique
  licenseDocument    String?
  isVerified         Boolean            @default(false)
  verificationStatus VerificationStatus @default(PENDING)
  rejectionReason    String?
  createdAt          DateTime           @default(now())
  updatedAt          DateTime           @updatedAt

  user          User                @relation(fields: [userId], references: [id], onDelete: Cascade)
  availableDays DoctorAvailability[]
  appointments  Appointment[]
  reviews       Review[]

  @@index([userId])
  @@index([specialty])
  @@index([rating])
  @@index([verificationStatus])
}

model DoctorAvailability {
  id       String    @id @default(cuid())
  doctorId String
  day      DayOfWeek

  doctor Doctor @relation(fields: [doctorId], references: [id], onDelete: Cascade)

  @@unique([doctorId, day])
}

model Appointment {
  id              String            @id @default(cuid())
  doctorId        String
  patientId       String
  
  // Denormalized for quick access
  doctorName      String
  doctorImage     String?
  doctorSpecialty String
  patientName     String
  patientPhone    String?
  
  appointmentDate DateTime
  timeSlot        String            // "HH:mm"
  status          AppointmentStatus @default(PENDING)
  fee             Decimal           @db.Decimal(10, 2)
  notes           String?           @db.Text
  cancelReason    String?
  cancelledBy     String?           // "patient", "doctor", "admin"
  completedAt     DateTime?
  createdAt       DateTime          @default(now())
  updatedAt       DateTime          @updatedAt

  doctor  Doctor  @relation(fields: [doctorId], references: [id])
  patient Patient @relation(fields: [patientId], references: [id])
  review  Review?

  @@index([doctorId, appointmentDate])
  @@index([patientId, appointmentDate])
  @@index([status])
}

model Review {
  id            String   @id @default(cuid())
  doctorId      String
  patientId     String
  appointmentId String   @unique
  
  // Denormalized
  doctorName    String
  patientName   String
  patientImage  String?
  
  rating        Int      // 1-5
  comment       String   @db.Text
  isAnonymous   Boolean  @default(false)
  isApproved    Boolean  @default(false)
  rejectionReason String?
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt

  doctor      Doctor      @relation(fields: [doctorId], references: [id])
  patient     Patient     @relation(fields: [patientId], references: [id])
  appointment Appointment @relation(fields: [appointmentId], references: [id])

  @@index([doctorId, isApproved])
  @@index([patientId])
}

model Admin {
  id          String   @id @default(cuid())
  userId      String   @unique
  name        String
  permissions String[]
  createdAt   DateTime @default(now())

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)
}

model Notification {
  id        String   @id @default(cuid())
  userId    String
  type      String   // "appointment", "review", "verification", "system"
  title     String
  message   String
  data      Json?
  isRead    Boolean  @default(false)
  createdAt DateTime @default(now())

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@index([userId, isRead])
}

model PasswordReset {
  id        String   @id @default(cuid())
  email     String
  token     String   @unique
  expiresAt DateTime
  usedAt    DateTime?
  createdAt DateTime @default(now())

  @@index([email])
}
```

---

## 🔧 Backend API Code Examples

### Express.js Server Setup

```typescript
// server/src/index.ts
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import rateLimit from 'express-rate-limit';
import { PrismaClient } from '@prisma/client';

import authRoutes from './routes/auth.routes';
import doctorRoutes from './routes/doctor.routes';
import appointmentRoutes from './routes/appointment.routes';
import reviewRoutes from './routes/review.routes';
import adminRoutes from './routes/admin.routes';
import { errorHandler } from './middlewares/error.middleware';

const app = express();
export const prisma = new PrismaClient();

// Middlewares
app.use(helmet());
app.use(compression());
app.use(cors({
  origin: process.env.CORS_ORIGIN?.split(','),
  credentials: true
}));
app.use(express.json({ limit: '10mb' }));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100
});
app.use(limiter);

// Routes
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/doctors', doctorRoutes);
app.use('/api/v1/appointments', appointmentRoutes);
app.use('/api/v1/reviews', reviewRoutes);
app.use('/api/v1/admin', adminRoutes);

// Error handler
app.use(errorHandler);

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

### Authentication Controller

```typescript
// server/src/controllers/auth.controller.ts
import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { prisma } from '../index';
import { sendEmail } from '../services/email.service';

export class AuthController {
  
  // Patient Registration
  async registerPatient(req: Request, res: Response) {
    try {
      const { email, password, name, phone } = req.body;

      // Check if email exists
      const existingUser = await prisma.user.findUnique({
        where: { email }
      });

      if (existingUser) {
        return res.status(400).json({
          success: false,
          error: { code: 'EMAIL_EXISTS', message: 'Email already registered' }
        });
      }

      // Hash password
      const passwordHash = await bcrypt.hash(password, 12);

      // Create user and patient in transaction
      const result = await prisma.$transaction(async (tx) => {
        const user = await tx.user.create({
          data: {
            email,
            passwordHash,
            role: 'PATIENT'
          }
        });

        const patient = await tx.patient.create({
          data: {
            userId: user.id,
            name,
            phone
          }
        });

        return { user, patient };
      });

      // Generate verification token
      const verificationToken = jwt.sign(
        { userId: result.user.id },
        process.env.JWT_SECRET!,
        { expiresIn: '24h' }
      );

      // Send verification email
      await sendEmail({
        to: email,
        subject: 'Verify your email - Doctor Clinic',
        template: 'email-verification',
        data: {
          name,
          verificationLink: `${process.env.APP_URL}/verify-email?token=${verificationToken}`
        }
      });

      res.status(201).json({
        success: true,
        message: 'Registration successful. Please check your email to verify.',
        data: {
          userId: result.user.id,
          email: result.user.email
        }
      });

    } catch (error) {
      console.error('Registration error:', error);
      res.status(500).json({
        success: false,
        error: { code: 'SERVER_ERROR', message: 'Registration failed' }
      });
    }
  }

  // Login
  async login(req: Request, res: Response) {
    try {
      const { email, password } = req.body;

      const user = await prisma.user.findUnique({
        where: { email },
        include: {
          patient: true,
          doctor: true,
          admin: true
        }
      });

      if (!user) {
        return res.status(401).json({
          success: false,
          error: { code: 'INVALID_CREDENTIALS', message: 'Invalid email or password' }
        });
      }

      // Check password
      const isValidPassword = await bcrypt.compare(password, user.passwordHash);
      if (!isValidPassword) {
        return res.status(401).json({
          success: false,
          error: { code: 'INVALID_CREDENTIALS', message: 'Invalid email or password' }
        });
      }

      // Check email verification
      if (!user.isEmailVerified) {
        return res.status(403).json({
          success: false,
          error: { code: 'EMAIL_NOT_VERIFIED', message: 'Please verify your email first' }
        });
      }

      // Check account status
      if (!user.isActive) {
        return res.status(403).json({
          success: false,
          error: { code: 'ACCOUNT_SUSPENDED', message: 'Your account has been suspended' }
        });
      }

      // For doctors, check verification status
      if (user.role === 'DOCTOR' && user.doctor?.verificationStatus !== 'APPROVED') {
        return res.status(403).json({
          success: false,
          error: { 
            code: 'DOCTOR_NOT_VERIFIED', 
            message: 'Your profile is pending verification by admin',
            verificationStatus: user.doctor?.verificationStatus
          }
        });
      }

      // Generate tokens
      const accessToken = jwt.sign(
        { userId: user.id, role: user.role },
        process.env.JWT_SECRET!,
        { expiresIn: '15m' }
      );

      const refreshToken = jwt.sign(
        { userId: user.id },
        process.env.JWT_REFRESH_SECRET!,
        { expiresIn: '7d' }
      );

      // Save session
      await prisma.session.create({
        data: {
          userId: user.id,
          refreshToken,
          userAgent: req.headers['user-agent'],
          ipAddress: req.ip,
          expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
        }
      });

      // Update last login
      await prisma.user.update({
        where: { id: user.id },
        data: { lastLoginAt: new Date() }
      });

      // Get profile data
      let profile = null;
      if (user.role === 'PATIENT') profile = user.patient;
      if (user.role === 'DOCTOR') profile = user.doctor;
      if (user.role === 'ADMIN') profile = user.admin;

      res.json({
        success: true,
        data: {
          accessToken,
          refreshToken,
          user: {
            id: user.id,
            email: user.email,
            role: user.role,
            profile
          }
        }
      });

    } catch (error) {
      console.error('Login error:', error);
      res.status(500).json({
        success: false,
        error: { code: 'SERVER_ERROR', message: 'Login failed' }
      });
    }
  }
}
```

### Doctor Controller

```typescript
// server/src/controllers/doctor.controller.ts
import { Request, Response } from 'express';
import { prisma } from '../index';

export class DoctorController {

  // Get all doctors with filters
  async getDoctors(req: Request, res: Response) {
    try {
      const {
        page = 1,
        limit = 12,
        specialty,
        minRating,
        maxFee,
        minFee,
        search,
        sortBy = 'rating',
        sortOrder = 'desc',
        available
      } = req.query;

      const pageNum = parseInt(page as string);
      const limitNum = parseInt(limit as string);
      const skip = (pageNum - 1) * limitNum;

      // Build where clause
      const where: any = {
        isVerified: true,
        verificationStatus: 'APPROVED'
      };

      if (specialty && specialty !== 'All') {
        where.specialty = specialty;
      }

      if (minRating) {
        where.rating = { gte: parseFloat(minRating as string) };
      }

      if (minFee || maxFee) {
        where.consultationFee = {};
        if (minFee) where.consultationFee.gte = parseFloat(minFee as string);
        if (maxFee) where.consultationFee.lte = parseFloat(maxFee as string);
      }

      if (available === 'true') {
        where.isAvailable = true;
      }

      if (search) {
        where.OR = [
          { name: { contains: search as string, mode: 'insensitive' } },
          { specialty: { contains: search as string, mode: 'insensitive' } },
          { hospitalName: { contains: search as string, mode: 'insensitive' } }
        ];
      }

      // Build orderBy
      const orderBy: any = {};
      orderBy[sortBy as string] = sortOrder;

      // Get doctors
      const [doctors, total] = await Promise.all([
        prisma.doctor.findMany({
          where,
          orderBy,
          skip,
          take: limitNum,
          include: {
            availableDays: true
          }
        }),
        prisma.doctor.count({ where })
      ]);

      res.json({
        success: true,
        data: doctors,
        pagination: {
          page: pageNum,
          limit: limitNum,
          total,
          totalPages: Math.ceil(total / limitNum)
        }
      });

    } catch (error) {
      console.error('Get doctors error:', error);
      res.status(500).json({
        success: false,
        error: { code: 'SERVER_ERROR', message: 'Failed to fetch doctors' }
      });
    }
  }

  // Get doctor by ID
  async getDoctorById(req: Request, res: Response) {
    try {
      const { id } = req.params;

      const doctor = await prisma.doctor.findFirst({
        where: {
          id,
          isVerified: true,
          verificationStatus: 'APPROVED'
        },
        include: {
          availableDays: true,
          reviews: {
            where: { isApproved: true },
            orderBy: { createdAt: 'desc' },
            take: 10
          }
        }
      });

      if (!doctor) {
        return res.status(404).json({
          success: false,
          error: { code: 'NOT_FOUND', message: 'Doctor not found' }
        });
      }

      res.json({
        success: true,
        data: doctor
      });

    } catch (error) {
      console.error('Get doctor error:', error);
      res.status(500).json({
        success: false,
        error: { code: 'SERVER_ERROR', message: 'Failed to fetch doctor' }
      });
    }
  }

  // Get available time slots
  async getAvailableSlots(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const { date } = req.query;

      if (!date) {
        return res.status(400).json({
          success: false,
          error: { code: 'VALIDATION_ERROR', message: 'Date is required' }
        });
      }

      const doctor = await prisma.doctor.findUnique({
        where: { id },
        include: { availableDays: true }
      });

      if (!doctor) {
        return res.status(404).json({
          success: false,
          error: { code: 'NOT_FOUND', message: 'Doctor not found' }
        });
      }

      // Check if doctor is available on this day
      const appointmentDate = new Date(date as string);
      const dayName = appointmentDate.toLocaleDateString('en-US', { weekday: 'long' }).toUpperCase();
      
      const isAvailableDay = doctor.availableDays.some(d => d.day === dayName);
      if (!isAvailableDay) {
        return res.json({
          success: true,
          data: { slots: [], message: 'Doctor not available on this day' }
        });
      }

      // Generate all slots
      const slots = this.generateTimeSlots(doctor.startTime, doctor.endTime);

      // Get booked slots
      const startOfDay = new Date(appointmentDate);
      startOfDay.setHours(0, 0, 0, 0);
      const endOfDay = new Date(appointmentDate);
      endOfDay.setHours(23, 59, 59, 999);

      const bookedAppointments = await prisma.appointment.findMany({
        where: {
          doctorId: id,
          appointmentDate: {
            gte: startOfDay,
            lte: endOfDay
          },
          status: { in: ['PENDING', 'CONFIRMED'] }
        },
        select: { timeSlot: true }
      });

      const bookedSlots = bookedAppointments.map(a => a.timeSlot);

      // Mark available/booked
      const slotsWithStatus = slots.map(slot => ({
        time: slot,
        available: !bookedSlots.includes(slot)
      }));

      res.json({
        success: true,
        data: { slots: slotsWithStatus }
      });

    } catch (error) {
      console.error('Get slots error:', error);
      res.status(500).json({
        success: false,
        error: { code: 'SERVER_ERROR', message: 'Failed to fetch slots' }
      });
    }
  }

  private generateTimeSlots(startTime: string, endTime: string): string[] {
    const slots: string[] = [];
    const [startHour, startMin] = startTime.split(':').map(Number);
    const [endHour, endMin] = endTime.split(':').map(Number);

    let currentHour = startHour;
    let currentMin = startMin;

    while (currentHour < endHour || (currentHour === endHour && currentMin < endMin)) {
      slots.push(
        `${currentHour.toString().padStart(2, '0')}:${currentMin.toString().padStart(2, '0')}`
      );

      currentMin += 30;
      if (currentMin >= 60) {
        currentMin = 0;
        currentHour++;
      }
    }

    return slots;
  }
}
```

### Appointment Controller

```typescript
// server/src/controllers/appointment.controller.ts
import { Request, Response } from 'express';
import { prisma } from '../index';
import { sendEmail } from '../services/email.service';

export class AppointmentController {

  // Book appointment
  async bookAppointment(req: Request, res: Response) {
    try {
      const { doctorId, appointmentDate, timeSlot, notes } = req.body;
      const patientId = req.user!.patientId;

      // Get doctor details
      const doctor = await prisma.doctor.findUnique({
        where: { id: doctorId }
      });

      if (!doctor || !doctor.isVerified) {
        return res.status(404).json({
          success: false,
          error: { code: 'NOT_FOUND', message: 'Doctor not found' }
        });
      }

      if (!doctor.isAvailable) {
        return res.status(400).json({
          success: false,
          error: { code: 'NOT_AVAILABLE', message: 'Doctor is not available' }
        });
      }

      // Check if slot is available
      const existingAppointment = await prisma.appointment.findFirst({
        where: {
          doctorId,
          appointmentDate: new Date(appointmentDate),
          timeSlot,
          status: { in: ['PENDING', 'CONFIRMED'] }
        }
      });

      if (existingAppointment) {
        return res.status(400).json({
          success: false,
          error: { code: 'SLOT_BOOKED', message: 'This time slot is already booked' }
        });
      }

      // Get patient details
      const patient = await prisma.patient.findUnique({
        where: { id: patientId }
      });

      // Create appointment
      const appointment = await prisma.appointment.create({
        data: {
          doctorId,
          patientId,
          doctorName: doctor.name,
          doctorImage: doctor.profileImage,
          doctorSpecialty: doctor.specialty,
          patientName: patient!.name,
          patientPhone: patient!.phone,
          appointmentDate: new Date(appointmentDate),
          timeSlot,
          fee: doctor.consultationFee,
          notes
        }
      });

      // Send confirmation emails
      await sendEmail({
        to: patient!.name, // Get email from user table
        subject: 'Appointment Booked - Doctor Clinic',
        template: 'appointment-booked-patient',
        data: {
          patientName: patient!.name,
          doctorName: doctor.name,
          date: appointmentDate,
          time: timeSlot,
          fee: doctor.consultationFee
        }
      });

      // Create notification for doctor
      await prisma.notification.create({
        data: {
          userId: doctor.userId,
          type: 'appointment',
          title: 'New Appointment',
          message: `${patient!.name} has booked an appointment for ${appointmentDate}`,
          data: { appointmentId: appointment.id }
        }
      });

      res.status(201).json({
        success: true,
        message: 'Appointment booked successfully',
        data: appointment
      });

    } catch (error) {
      console.error('Book appointment error:', error);
      res.status(500).json({
        success: false,
        error: { code: 'SERVER_ERROR', message: 'Failed to book appointment' }
      });
    }
  }

  // Get user appointments
  async getAppointments(req: Request, res: Response) {
    try {
      const { status, page = 1, limit = 10 } = req.query;
      const userId = req.user!.id;
      const userRole = req.user!.role;

      const pageNum = parseInt(page as string);
      const limitNum = parseInt(limit as string);

      let where: any = {};

      if (userRole === 'PATIENT') {
        const patient = await prisma.patient.findUnique({
          where: { userId }
        });
        where.patientId = patient!.id;
      } else if (userRole === 'DOCTOR') {
        const doctor = await prisma.doctor.findUnique({
          where: { userId }
        });
        where.doctorId = doctor!.id;
      }

      if (status) {
        where.status = status;
      }

      const [appointments, total] = await Promise.all([
        prisma.appointment.findMany({
          where,
          orderBy: { appointmentDate: 'desc' },
          skip: (pageNum - 1) * limitNum,
          take: limitNum
        }),
        prisma.appointment.count({ where })
      ]);

      res.json({
        success: true,
        data: appointments,
        pagination: {
          page: pageNum,
          limit: limitNum,
          total,
          totalPages: Math.ceil(total / limitNum)
        }
      });

    } catch (error) {
      console.error('Get appointments error:', error);
      res.status(500).json({
        success: false,
        error: { code: 'SERVER_ERROR', message: 'Failed to fetch appointments' }
      });
    }
  }

  // Cancel appointment
  async cancelAppointment(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const { reason } = req.body;
      const userId = req.user!.id;
      const userRole = req.user!.role;

      const appointment = await prisma.appointment.findUnique({
        where: { id },
        include: {
          doctor: true,
          patient: true
        }
      });

      if (!appointment) {
        return res.status(404).json({
          success: false,
          error: { code: 'NOT_FOUND', message: 'Appointment not found' }
        });
      }

      // Check authorization
      let canCancel = false;
      let cancelledBy = '';

      if (userRole === 'PATIENT') {
        const patient = await prisma.patient.findUnique({ where: { userId } });
        canCancel = appointment.patientId === patient!.id;
        cancelledBy = 'patient';
      } else if (userRole === 'DOCTOR') {
        const doctor = await prisma.doctor.findUnique({ where: { userId } });
        canCancel = appointment.doctorId === doctor!.id;
        cancelledBy = 'doctor';
      } else if (userRole === 'ADMIN') {
        canCancel = true;
        cancelledBy = 'admin';
      }

      if (!canCancel) {
        return res.status(403).json({
          success: false,
          error: { code: 'FORBIDDEN', message: 'Not authorized to cancel' }
        });
      }

      // Check if can be cancelled
      if (!['PENDING', 'CONFIRMED'].includes(appointment.status)) {
        return res.status(400).json({
          success: false,
          error: { code: 'CANNOT_CANCEL', message: 'Cannot cancel this appointment' }
        });
      }

      // Update appointment
      await prisma.appointment.update({
        where: { id },
        data: {
          status: 'CANCELLED',
          cancelReason: reason,
          cancelledBy
        }
      });

      res.json({
        success: true,
        message: 'Appointment cancelled successfully'
      });

    } catch (error) {
      console.error('Cancel appointment error:', error);
      res.status(500).json({
        success: false,
        error: { code: 'SERVER_ERROR', message: 'Failed to cancel appointment' }
      });
    }
  }
}
```

---

## 🎨 Frontend Code Examples

### Next.js Page - Doctor Listing

```tsx
// apps/web/app/doctors/page.tsx
'use client';

import { useState, useEffect } from 'react';
import { useSearchParams } from 'next/navigation';
import { DoctorCard } from '@/components/cards/DoctorCard';
import { DoctorFilters } from '@/components/filters/DoctorFilters';
import { Skeleton } from '@/components/ui/skeleton';
import { api } from '@/lib/api';

interface Doctor {
  id: string;
  name: string;
  specialty: string;
  profileImage: string;
  rating: number;
  totalReviews: number;
  experienceYears: number;
  consultationFee: number;
  hospitalName: string;
  isAvailable: boolean;
}

export default function DoctorsPage() {
  const searchParams = useSearchParams();
  const [doctors, setDoctors] = useState<Doctor[]>([]);
  const [loading, setLoading] = useState(true);
  const [pagination, setPagination] = useState({
    page: 1,
    total: 0,
    totalPages: 0
  });

  const [filters, setFilters] = useState({
    specialty: searchParams.get('specialty') || '',
    minRating: searchParams.get('minRating') || '',
    minFee: searchParams.get('minFee') || '',
    maxFee: searchParams.get('maxFee') || '',
    search: searchParams.get('search') || '',
    sortBy: 'rating',
    sortOrder: 'desc'
  });

  useEffect(() => {
    fetchDoctors();
  }, [filters, pagination.page]);

  const fetchDoctors = async () => {
    try {
      setLoading(true);
      const params = new URLSearchParams({
        page: pagination.page.toString(),
        limit: '12',
        ...Object.fromEntries(
          Object.entries(filters).filter(([_, v]) => v)
        )
      });

      const response = await api.get(`/doctors?${params}`);
      setDoctors(response.data.data);
      setPagination(prev => ({
        ...prev,
        total: response.data.pagination.total,
        totalPages: response.data.pagination.totalPages
      }));
    } catch (error) {
      console.error('Failed to fetch doctors:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="container mx-auto px-4 py-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-8">
          Find Doctors
        </h1>

        <div className="flex flex-col lg:flex-row gap-8">
          {/* Filters Sidebar */}
          <aside className="w-full lg:w-64 flex-shrink-0">
            <DoctorFilters
              filters={filters}
              onChange={setFilters}
            />
          </aside>

          {/* Doctor Grid */}
          <main className="flex-1">
            {/* Search & Sort Header */}
            <div className="flex items-center justify-between mb-6">
              <p className="text-gray-600">
                {loading ? 'Loading...' : `${pagination.total} doctors found`}
              </p>
              <select
                value={`${filters.sortBy}-${filters.sortOrder}`}
                onChange={(e) => {
                  const [sortBy, sortOrder] = e.target.value.split('-');
                  setFilters(prev => ({ ...prev, sortBy, sortOrder }));
                }}
                className="border rounded-lg px-4 py-2"
              >
                <option value="rating-desc">Rating: High to Low</option>
                <option value="rating-asc">Rating: Low to High</option>
                <option value="consultationFee-asc">Fee: Low to High</option>
                <option value="consultationFee-desc">Fee: High to Low</option>
                <option value="experienceYears-desc">Experience: High to Low</option>
              </select>
            </div>

            {/* Doctor Cards Grid */}
            {loading ? (
              <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
                {[...Array(6)].map((_, i) => (
                  <Skeleton key={i} className="h-80 rounded-xl" />
                ))}
              </div>
            ) : doctors.length === 0 ? (
              <div className="text-center py-16">
                <p className="text-gray-500 text-lg">No doctors found</p>
                <button
                  onClick={() => setFilters({
                    specialty: '',
                    minRating: '',
                    minFee: '',
                    maxFee: '',
                    search: '',
                    sortBy: 'rating',
                    sortOrder: 'desc'
                  })}
                  className="mt-4 text-primary hover:underline"
                >
                  Clear filters
                </button>
              </div>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
                {doctors.map(doctor => (
                  <DoctorCard key={doctor.id} doctor={doctor} />
                ))}
              </div>
            )}

            {/* Pagination */}
            {pagination.totalPages > 1 && (
              <div className="flex justify-center gap-2 mt-8">
                <button
                  onClick={() => setPagination(p => ({ ...p, page: p.page - 1 }))}
                  disabled={pagination.page === 1}
                  className="px-4 py-2 border rounded-lg disabled:opacity-50"
                >
                  Previous
                </button>
                <span className="px-4 py-2">
                  Page {pagination.page} of {pagination.totalPages}
                </span>
                <button
                  onClick={() => setPagination(p => ({ ...p, page: p.page + 1 }))}
                  disabled={pagination.page === pagination.totalPages}
                  className="px-4 py-2 border rounded-lg disabled:opacity-50"
                >
                  Next
                </button>
              </div>
            )}
          </main>
        </div>
      </div>
    </div>
  );
}
```

### Doctor Card Component

```tsx
// apps/web/components/cards/DoctorCard.tsx
import Link from 'next/link';
import Image from 'next/image';
import { Star, MapPin, Clock, BadgeCheck } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { formatCurrency } from '@/lib/utils';

interface DoctorCardProps {
  doctor: {
    id: string;
    name: string;
    specialty: string;
    profileImage: string;
    rating: number;
    totalReviews: number;
    experienceYears: number;
    consultationFee: number;
    hospitalName: string;
    isAvailable: boolean;
  };
}

export function DoctorCard({ doctor }: DoctorCardProps) {
  return (
    <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden hover:shadow-lg transition-shadow duration-300">
      {/* Doctor Image */}
      <div className="relative h-48 bg-gray-100">
        {doctor.profileImage ? (
          <Image
            src={doctor.profileImage}
            alt={doctor.name}
            fill
            className="object-cover"
          />
        ) : (
          <div className="w-full h-full flex items-center justify-center bg-primary/10">
            <span className="text-4xl text-primary">
              {doctor.name.charAt(0)}
            </span>
          </div>
        )}
        
        {/* Availability Badge */}
        <Badge
          className={`absolute top-3 right-3 ${
            doctor.isAvailable 
              ? 'bg-green-500' 
              : 'bg-gray-500'
          }`}
        >
          {doctor.isAvailable ? 'Available' : 'Unavailable'}
        </Badge>
      </div>

      {/* Doctor Info */}
      <div className="p-5">
        <div className="flex items-start justify-between mb-2">
          <div>
            <h3 className="font-semibold text-lg text-gray-900 flex items-center gap-1">
              {doctor.name}
              <BadgeCheck className="w-4 h-4 text-blue-500" />
            </h3>
            <p className="text-sm text-primary font-medium">
              {doctor.specialty}
            </p>
          </div>
        </div>

        {/* Rating */}
        <div className="flex items-center gap-2 mb-3">
          <div className="flex items-center gap-1 bg-yellow-50 px-2 py-1 rounded">
            <Star className="w-4 h-4 text-yellow-500 fill-yellow-500" />
            <span className="font-semibold text-sm">{doctor.rating.toFixed(1)}</span>
          </div>
          <span className="text-sm text-gray-500">
            ({doctor.totalReviews} reviews)
          </span>
        </div>

        {/* Details */}
        <div className="space-y-2 mb-4">
          <div className="flex items-center gap-2 text-sm text-gray-600">
            <Clock className="w-4 h-4" />
            <span>{doctor.experienceYears} years experience</span>
          </div>
          <div className="flex items-center gap-2 text-sm text-gray-600">
            <MapPin className="w-4 h-4" />
            <span className="truncate">{doctor.hospitalName}</span>
          </div>
        </div>

        {/* Footer */}
        <div className="flex items-center justify-between pt-4 border-t">
          <div>
            <span className="text-xl font-bold text-primary">
              {formatCurrency(doctor.consultationFee)}
            </span>
            <span className="text-sm text-gray-500"> /visit</span>
          </div>
          <Link href={`/doctors/${doctor.id}`}>
            <Button>
              Book Now
            </Button>
          </Link>
        </div>
      </div>
    </div>
  );
}
```

---

## 🚀 Deployment Commands

### Development
```bash
# Install dependencies
npm install

# Run database migrations
npx prisma migrate dev

# Seed database
npx prisma db seed

# Start development server
npm run dev
```

### Production Build
```bash
# Build all apps
npm run build

# Run production server
npm start
```

### Docker Deployment
```bash
# Build images
docker-compose build

# Start services
docker-compose up -d

# View logs
docker-compose logs -f
```

---

## 📝 Environment Variables Checklist

```
✅ DATABASE_URL
✅ REDIS_URL
✅ JWT_SECRET
✅ JWT_REFRESH_SECRET
✅ FIREBASE_CONFIG (for existing mobile app compatibility)
✅ SENDGRID_API_KEY
✅ AWS_ACCESS_KEY_ID
✅ AWS_SECRET_ACCESS_KEY
✅ AWS_S3_BUCKET
✅ GOOGLE_MAPS_API_KEY
✅ CORS_ORIGIN
✅ APP_URL
✅ API_URL
```

---

*This technical guide provides a solid foundation. Actual implementation may require adjustments based on specific requirements and chosen tech stack.*
