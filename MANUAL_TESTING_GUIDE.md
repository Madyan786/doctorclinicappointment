# 🧪 MANUAL TESTING GUIDE - BRUTAL FUNCTIONALITY CHECK

## 📱 PRE-REQUISITES
- [ ] Flutter SDK installed
- [ ] Firebase configured
- [ ] Cloudinary account setup
- [ ] At least 2 devices/emulators (Patient + Doctor)
- [ ] Notification permissions enabled

---

## 🚀 QUICK START

```bash
# 1. Clean and get dependencies
flutter clean
flutter pub get

# 2. Run on first device (Patient)
flutter run -d device1

# 3. Run on second device (Doctor)
flutter run -d device2
```

---

## ✅ TEST SUITE 1: PATIENT APPOINTMENT BOOKING

### **Test 1.1: Basic Booking Flow**
**Device:** Patient App

**Steps:**
1. ✅ Login as patient
2. ✅ Navigate to Home tab
3. ✅ Search for a doctor
4. ✅ Click on doctor card
5. ✅ Verify doctor details screen opens
6. ✅ Click "Book Appointment"
7. ✅ Select a future date
8. ✅ Select an available time slot
9. ✅ Add notes (optional)
10. ✅ Upload payment slip (camera/gallery)
11. ✅ Click "Confirm Booking"

**Expected Results:**
- [ ] Loading spinner shows during upload
- [ ] Upload completes successfully
- [ ] Booking processes (2-3 seconds)
- [ ] Success dialog appears
- [ ] Notification: "📝 Appointment Request Sent"
- [ ] Appointment appears in "Upcoming" tab
- [ ] Status shows "Awaiting Approval"

**Pass Criteria:** ✅ All expected results match

---

### **Test 1.2: Booking Without Payment Slip**
**Steps:**
1. Select date and time
2. DO NOT upload payment slip
3. Try to click "Confirm Booking"

**Expected:**
- [ ] Button is disabled
- [ ] Message: "Please upload payment slip"

**Pass Criteria:** ✅ Cannot book without payment

---

### **Test 1.3: Double Booking Prevention**
**Steps:**
1. Book appointment for Doctor A on Date X, Time Y
2. Try to book same Doctor A, same Date X, Time Y again

**Expected:**
- [ ] Error: "This time slot is already booked"
- [ ] Booking fails

**Pass Criteria:** ✅ Cannot double-book

---

### **Test 1.4: Booked Slots Display**
**Steps:**
1. Select a date that has existing bookings
2. Check time slots

**Expected:**
- [ ] Booked slots shown in red
- [ ] Booked slots are disabled
- [ ] Available slots are clickable

**Pass Criteria:** ✅ Visual distinction works

---

## ✅ TEST SUITE 2: DOCTOR NOTIFICATION & ACCEPTANCE

### **Test 2.1: Doctor Receives Notification**
**Device:** Doctor App (keep in background)

**Steps:**
1. Patient books appointment (from Test 1.1)
2. Watch doctor's device notification bar

**Expected:**
- [ ] Notification appears within 2-3 seconds
- [ ] Title: "🔔 New Appointment Request"
- [ ] Body contains patient name, date, time
- [ ] Notification has sound/vibration

**Pass Criteria:** ✅ Notification received instantly

---

### **Test 2.2: Doctor Views Appointment**
**Steps:**
1. Open doctor app
2. Go to "Appointments" tab
3. Click "Awaiting" tab

**Expected:**
- [ ] New appointment appears at top
- [ ] Patient name and phone visible
- [ ] Date, time, fee displayed
- [ ] Payment slip thumbnail visible
- [ ] "Accept" and "Reject" buttons visible

**Pass Criteria:** ✅ All details visible

---

### **Test 2.3: View Payment Slip**
**Steps:**
1. Tap on payment slip thumbnail

**Expected:**
- [ ] Dialog opens with full-size image
- [ ] Image loads from Cloudinary
- [ ] Close button works
- [ ] Image is clear and readable

**Pass Criteria:** ✅ Payment slip viewable

---

### **Test 2.4: Accept Appointment**
**Steps:**
1. Click "Accept" button

**Expected:**
- [ ] Loading dialog appears
- [ ] Processing takes 1-2 seconds
- [ ] Loading dialog closes
- [ ] Success message: "✅ Success - Appointment accepted! Patient has been notified."
- [ ] Appointment moves from "Awaiting" to "Confirmed" tab
- [ ] Background color changes to green/blue

**Pass Criteria:** ✅ Acceptance works smoothly

---

### **Test 2.5: Patient Receives Acceptance Notification**
**Device:** Patient App

**Steps:**
1. Wait for doctor to accept (from Test 2.4)

**Expected:**
- [ ] Notification appears: "✅ Appointment Confirmed!"
- [ ] Body contains doctor name, date, time
- [ ] Appointment status changes to "Confirmed"

**Pass Criteria:** ✅ Patient notified

---

### **Test 2.6: Reject Appointment**
**Steps:**
1. Book another appointment (Test 1.1)
2. Doctor clicks "Reject"
3. Dialog appears asking for reason
4. Enter reason: "Invalid payment slip"
5. Click "Reject"

**Expected:**
- [ ] Loading dialog appears
- [ ] Processing completes
- [ ] Success message: "❌ Rejected - Appointment rejected. Patient has been notified."
- [ ] Appointment moves to "Cancelled" tab
- [ ] Status shows "Rejected"

**Pass Criteria:** ✅ Rejection works

---

### **Test 2.7: Patient Receives Rejection with Reason**
**Device:** Patient App

**Expected:**
- [ ] Notification: "❌ Appointment Rejected"
- [ ] Body contains: "Reason: Invalid payment slip"
- [ ] Appointment status: "Rejected"
- [ ] Reason displayed in appointment card

**Pass Criteria:** ✅ Rejection reason visible

---

## ✅ TEST SUITE 3: REAL-TIME UPDATES

### **Test 3.1: Real-Time Status Update**
**Setup:** Open both apps side-by-side

**Steps:**
1. Patient books appointment
2. Doctor accepts immediately
3. Watch patient app without refreshing

**Expected:**
- [ ] Status updates automatically within 2 seconds
- [ ] No manual refresh needed
- [ ] UI transitions smoothly

**Pass Criteria:** ✅ Real-time sync works

---

### **Test 3.2: Multiple Appointments Stream**
**Steps:**
1. Patient books 3 appointments with different doctors
2. Doctor 1 accepts
3. Doctor 2 rejects
4. Doctor 3 doesn't respond

**Expected:**
- [ ] All 3 appear in patient's "Upcoming" tab
- [ ] Each has correct status
- [ ] Updates happen independently
- [ ] No UI glitches

**Pass Criteria:** ✅ Multiple streams work

---

### **Test 3.3: Doctor Dashboard Stats**
**Steps:**
1. Check doctor's home screen stats
2. Accept/reject appointments
3. Watch stats update

**Expected:**
- [ ] "Today" count updates
- [ ] "Pending" count updates
- [ ] "Done" count updates
- [ ] Stats update in real-time

**Pass Criteria:** ✅ Stats accurate

---

## ✅ TEST SUITE 4: DOCTOR HOME TAB ACTIONS

### **Test 4.1: Complete Appointment from Home**
**Steps:**
1. Go to Doctor Home tab
2. Find today's confirmed appointment
3. Click green checkmark (Complete)

**Expected:**
- [ ] Loading dialog shows
- [ ] Status updates to "Completed"
- [ ] Patient receives notification: "✅ Appointment Completed"
- [ ] Success message shows

**Pass Criteria:** ✅ Complete action works

---

### **Test 4.2: Cancel Appointment from Home**
**Steps:**
1. Find today's confirmed appointment
2. Click red X (Cancel)

**Expected:**
- [ ] Status updates to "Cancelled"
- [ ] Patient receives notification: "❌ Appointment Cancelled"
- [ ] Appointment moves to cancelled list

**Pass Criteria:** ✅ Cancel action works

---

## ✅ TEST SUITE 5: APPOINTMENT TAB FEATURES

### **Test 5.1: Tab Filtering**
**Device:** Doctor App

**Steps:**
1. Go to Appointments tab
2. Click each tab: All, Awaiting, Confirmed, Completed, Cancelled

**Expected:**
- [ ] Each tab shows correct appointments
- [ ] Filtering is instant
- [ ] Empty states show when no data
- [ ] Tab indicator animation smooth

**Pass Criteria:** ✅ All tabs work

---

### **Test 5.2: Pull to Refresh**
**Steps:**
1. Pull down on appointments list

**Expected:**
- [ ] Refresh indicator appears
- [ ] Data reloads
- [ ] Latest appointments show

**Pass Criteria:** ✅ Refresh works

---

### **Test 5.3: Tablet Responsive Layout**
**Steps:**
1. Run on tablet or resize window
2. Check appointment cards

**Expected:**
- [ ] Grid layout (2 columns)
- [ ] Cards properly spaced
- [ ] Text readable
- [ ] Buttons accessible

**Pass Criteria:** ✅ Responsive design

---

## ✅ TEST SUITE 6: ERROR HANDLING

### **Test 6.1: Network Disconnection**
**Steps:**
1. Turn off WiFi/data
2. Try to book appointment

**Expected:**
- [ ] Error message shown
- [ ] Loading stops
- [ ] App doesn't crash
- [ ] Can retry when online

**Pass Criteria:** ✅ Graceful degradation

---

### **Test 6.2: Large Image Upload**
**Steps:**
1. Take high-res photo (10MB+)
2. Upload as payment slip

**Expected:**
- [ ] Upload starts
- [ ] Shows progress
- [ ] Compresses if needed
- [ ] Uploads successfully or shows error

**Pass Criteria:** ✅ Handles large files

---

### **Test 6.3: Invalid Payment Slip**
**Steps:**
1. Upload corrupted image
2. Try to book

**Expected:**
- [ ] Upload fails
- [ ] Error message shown
- [ ] Can retry with different image

**Pass Criteria:** ✅ Error handled

---

## ✅ TEST SUITE 7: PERMISSION HANDLING

### **Test 7.1: First-Time Permission**
**Steps:**
1. Install fresh app
2. Book appointment
3. Watch permission dialog

**Expected:**
- [ ] Permission dialog appears ONCE
- [ ] Clear message
- [ ] If granted → notifications work
- [ ] If denied → graceful degradation

**Pass Criteria:** ✅ Permission flow correct

---

### **Test 7.2: No Permission Spam**
**Steps:**
1. Book 5 appointments in a row
2. Watch for permission dialogs

**Expected:**
- [ ] Dialog appears only on FIRST booking
- [ ] Subsequent bookings don't show dialog
- [ ] Notifications still work (if granted)

**Pass Criteria:** ✅ NO SPAM

---

### **Test 7.3: Permission Denied Recovery**
**Steps:**
1. Deny notification permission
2. Book appointment
3. Go to Settings → Enable permission
4. Book another appointment

**Expected:**
- [ ] First booking: works without notification
- [ ] After enabling: notifications work
- [ ] No crashes

**Pass Criteria:** ✅ Recovery works

---

## ✅ TEST SUITE 8: NOTIFICATION CONTENT VERIFICATION

### **Test 8.1: Patient Booking Notification**
**Expected Content:**
```
Title: 📝 Appointment Request Sent
Body: Your appointment request with Dr. [Name] is awaiting approval. The doctor will review your payment slip.
```

**Pass Criteria:** ✅ Matches exactly

---

### **Test 8.2: Doctor Request Notification**
**Expected Content:**
```
Title: 🔔 New Appointment Request
Body: [Patient Name] has requested an appointment for [MMM dd, yyyy] at [HH:mm]. Please review and accept/reject.
```

**Pass Criteria:** ✅ All details present

---

### **Test 8.3: Acceptance Notification**
**Expected Content:**
```
Title: ✅ Appointment Confirmed!
Body: Your appointment with Dr. [Name] on [Date] at [Time] has been confirmed.
```

**Pass Criteria:** ✅ Complete info

---

### **Test 8.4: Rejection Notification**
**Expected Content:**
```
Title: ❌ Appointment Rejected
Body: Your appointment with Dr. [Name] was rejected. Reason: [Reason]
```

**Pass Criteria:** ✅ Reason included

---

## ✅ TEST SUITE 9: CLOUDINARY INTEGRATION

### **Test 9.1: Payment Slip Upload**
**Steps:**
1. Upload payment slip
2. Check Cloudinary dashboard

**Expected:**
- [ ] Image appears in `payment_slips` folder
- [ ] Public ID format: `{userId}_{doctorId}_{timestamp}`
- [ ] Secure URL returned
- [ ] URL stored in Firestore

**Pass Criteria:** ✅ Upload successful

---

### **Test 9.2: Doctor Profile Image**
**Steps:**
1. Register as doctor with profile image
2. Check Firestore doctor document

**Expected:**
- [ ] `profileImage` field contains Cloudinary URL
- [ ] URL is accessible
- [ ] Image displays in app

**Pass Criteria:** ✅ Profile image works

---

### **Test 9.3: Document Uploads**
**Steps:**
1. Register doctor with license + degree images
2. Check Cloudinary

**Expected:**
- [ ] License in correct folder
- [ ] Degrees in correct folder
- [ ] All URLs stored in Firestore

**Pass Criteria:** ✅ Documents uploaded

---

## ✅ TEST SUITE 10: END-TO-END SCENARIOS

### **Scenario 1: Happy Path**
```
Patient books → Doctor notified → Doctor accepts → Patient notified → Appointment confirmed → Doctor completes → Patient notified
```

**Checklist:**
- [ ] All notifications received
- [ ] All status updates correct
- [ ] No errors
- [ ] Smooth UX

**Pass Criteria:** ✅ Complete flow works

---

### **Scenario 2: Rejection Path**
```
Patient books → Doctor notified → Doctor rejects with reason → Patient notified with reason → Patient books different doctor
```

**Checklist:**
- [ ] Rejection reason visible
- [ ] Patient can rebook
- [ ] No data loss

**Pass Criteria:** ✅ Rejection flow works

---

### **Scenario 3: Cancellation Path**
```
Patient books → Doctor accepts → Doctor cancels → Patient notified → Appointment cancelled
```

**Checklist:**
- [ ] Cancellation notification received
- [ ] Status updated
- [ ] Appointment in cancelled tab

**Pass Criteria:** ✅ Cancellation works

---

### **Scenario 4: Multiple Bookings**
```
Patient books 3 appointments with different doctors → All doctors notified → Each doctor acts independently → Patient receives 3 different notifications
```

**Checklist:**
- [ ] All 3 bookings succeed
- [ ] Each doctor gets their notification
- [ ] Patient gets individual updates
- [ ] No cross-contamination

**Pass Criteria:** ✅ Concurrent bookings work

---

## 📊 TEST RESULTS TEMPLATE

Copy this and fill after testing:

```
═══════════════════════════════════════
📊 MANUAL TEST RESULTS
═══════════════════════════════════════
Date: [DATE]
Tester: [NAME]
Devices: [DEVICE1, DEVICE2]

TEST SUITE 1: Patient Booking
  Test 1.1: [✅/❌]
  Test 1.2: [✅/❌]
  Test 1.3: [✅/❌]
  Test 1.4: [✅/❌]

TEST SUITE 2: Doctor Notifications
  Test 2.1: [✅/❌]
  Test 2.2: [✅/❌]
  Test 2.3: [✅/❌]
  Test 2.4: [✅/❌]
  Test 2.5: [✅/❌]
  Test 2.6: [✅/❌]
  Test 2.7: [✅/❌]

TEST SUITE 3: Real-Time Updates
  Test 3.1: [✅/❌]
  Test 3.2: [✅/❌]
  Test 3.3: [✅/❌]

[... continue for all suites ...]

═══════════════════════════════════════
OVERALL STATUS: [✅ PASS / ❌ FAIL]
ISSUES FOUND: [LIST ANY]
═══════════════════════════════════════
```

---

## 🐛 COMMON ISSUES & FIXES

### Issue 1: Notifications Not Showing
**Fix:**
```bash
# Check Android permissions
adb shell dumpsys package com.your.app | grep permission

# Ensure notification channel created
adb shell cmd notification list_channels
```

### Issue 2: Cloudinary Upload Fails
**Fix:**
- Verify credentials in `cloudinary_service.dart`
- Check upload preset exists
- Ensure image file path is valid

### Issue 3: Real-Time Not Working
**Fix:**
- Check Firestore rules
- Verify StreamBuilder is rebuilding
- Check internet connection

### Issue 4: Permission Spam
**Fix:**
- Already fixed with caching
- If still happening, clear app data and reinstall

---

## 🎯 FINAL CHECKLIST

Before marking as production-ready:

- [ ] All 74 automated tests pass
- [ ] All manual test suites pass
- [ ] No crashes in 10+ booking cycles
- [ ] Notifications work on both devices
- [ ] Real-time updates verified
- [ ] Error handling tested
- [ ] Permission flow smooth
- [ ] Cloudinary uploads reliable
- [ ] UI responsive on all sizes
- [ ] Dark mode works
- [ ] Performance acceptable (<3s per operation)

---

**🚀 IF ALL CHECKS PASS = PRODUCTION READY!**
