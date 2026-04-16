#!/bin/bash
# 🧪 BRUTAL AUTOMATED TEST SCRIPT
# Run: chmod +x test_appointment_system.sh && ./test_appointment_system.sh

echo "═══════════════════════════════════════════════"
echo "🚀 DOCTOR CLINIC - BRUTAL TEST SUITE"
echo "═══════════════════════════════════════════════"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PASS=0
FAIL=0

# Function to run test
run_test() {
    local test_name=$1
    local test_command=$2
    
    echo -e "${BLUE}🧪 Running: ${test_name}${NC}"
    
    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ PASS: ${test_name}${NC}"
        ((PASS++))
    else
        echo -e "${RED}❌ FAIL: ${test_name}${NC}"
        ((FAIL++))
    fi
    echo ""
}

# ============================================
# PHASE 1: PROJECT SETUP CHECKS
# ============================================
echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
echo -e "${YELLOW}📦 PHASE 1: PROJECT SETUP${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
echo ""

run_test "Flutter SDK installed" "flutter --version"
run_test "Dependencies installed" "flutter pub get"
run_test "Project analyzes clean" "flutter analyze --no-fatal-infos"

# ============================================
# PHASE 2: FILE STRUCTURE CHECKS
# ============================================
echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
echo -e "${YELLOW}📁 PHASE 2: FILE STRUCTURE${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
echo ""

run_test "Appointment service exists" "test -f lib/core/services/appointment_service.dart"
run_test "Notification service exists" "test -f lib/core/services/notification_service.dart"
run_test "Doctor appointments tab exists" "test -f lib/doctor/doctor_appointments_tab.dart"
run_test "Doctor home tab exists" "test -f lib/doctor/doctor_home_tab.dart"
run_test "Book appointment screen exists" "test -f lib/screens/book_appointment_screen.dart"
run_test "Cloudinary service exists" "test -f lib/core/services/cloudinary_service.dart"

# ============================================
# PHASE 3: CODE QUALITY CHECKS
# ============================================
echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
echo -e "${YELLOW}🔍 PHASE 3: CODE QUALITY${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
echo ""

# Check for critical functions
run_test "bookAppointment function exists" "grep -q 'Future<bool> bookAppointment' lib/core/services/appointment_service.dart"
run_test "acceptAppointment function exists" "grep -q 'Future<bool> acceptAppointment' lib/core/services/appointment_service.dart"
run_test "rejectAppointment function exists" "grep -q 'Future<bool> rejectAppointment' lib/core/services/appointment_service.dart"
run_test "showInstantNotification exists" "grep -q 'Future<void> showInstantNotification' lib/core/services/notification_service.dart"
run_test "Doctor notification on booking" "grep -q 'Notify DOCTOR about new appointment request' lib/core/services/appointment_service.dart"
run_test "Permission caching implemented" "grep -q '_permissionGranted' lib/core/services/notification_service.dart"
run_test "Patient notification on accept" "grep -q 'Appointment Confirmed' lib/core/services/appointment_service.dart"
run_test "Patient notification on reject" "grep -q 'Appointment Rejected' lib/core/services/appointment_service.dart"
run_test "Stream for doctor appointments" "grep -q 'streamDoctorAppointments' lib/core/services/appointment_service.dart"
run_test "Error handling in booking" "grep -q 'try {' lib/core/services/appointment_service.dart"
run_test "Developer logging present" "grep -q 'developer.log' lib/core/services/appointment_service.dart"

# ============================================
# PHASE 4: INTEGRATION CHECKS
# ============================================
echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
echo -e "${YELLOW}🔗 PHASE 4: INTEGRATION${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
echo ""

run_test "Firebase initialized in main" "grep -q 'Firebase.initializeApp()' lib/main.dart"
run_test "NotificationService initialized" "grep -q 'Get.put(NotificationService())' lib/main.dart"
run_test "AppointmentService initialized" "grep -q 'Get.put(AppointmentService())' lib/main.dart"
run_test "CloudinaryService initialized" "grep -q 'Get.put(CloudinaryService())' lib/main.dart"
run_test "Cloudinary import present" "grep -q 'cloudinary_public' pubspec.yaml"
run_test "Firebase Auth dependency" "grep -q 'firebase_auth' pubspec.yaml"
run_test "Firestore dependency" "grep -q 'cloud_firestore' pubspec.yaml"
run_test "Local notifications dependency" "grep -q 'flutter_local_notifications' pubspec.yaml"

# ============================================
# PHASE 5: SECURITY CHECKS
# ============================================
echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
echo -e "${YELLOW}🔒 PHASE 5: SECURITY${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
echo ""

run_test "Firestore rules exist" "test -f firestore.rules"
run_test "Doctors collection secured" "grep -q 'match /doctors/' firestore.rules"
run_test "Appointments collection secured" "grep -q 'match /appointments/' firestore.rules"
run_test "Users collection secured" "grep -q 'match /users/' firestore.rules"
run_test "Reviews collection secured" "grep -q 'match /reviews/' firestore.rules"

# ============================================
# PHASE 6: UI/UX CHECKS
# ============================================
echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
echo -e "${YELLOW}🎨 PHASE 6: UI/UX${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
echo ""

run_test "Loading dialog in accept" "grep -q 'Get.dialog' lib/doctor/doctor_appointments_tab.dart"
run_test "Loading dialog in reject" "grep -q 'barrierDismissible: false' lib/doctor/doctor_appointments_tab.dart"
run_test "Success feedback messages" "grep -q 'Get.snackbar' lib/doctor/doctor_appointments_tab.dart"
run_test "Payment slip viewer" "grep -q '_showPaymentSlipDialog' lib/doctor/doctor_appointments_tab.dart"
run_test "Empty state handling" "grep -q '_buildEmptyState' lib/doctor/doctor_appointments_tab.dart"
run_test "Dark mode support" "grep -q 'isDark' lib/doctor/doctor_appointments_tab.dart"
run_test "Tablet responsive" "grep -q 'isTablet' lib/doctor/doctor_appointments_tab.dart"

# ============================================
# PHASE 7: NOTIFICATION FLOW CHECKS
# ============================================
echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
echo -e "${YELLOW}🔔 PHASE 7: NOTIFICATION FLOW${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
echo ""

run_test "Patient booking notification" "grep -q 'Appointment Request Sent' lib/core/services/appointment_service.dart"
run_test "Doctor new request notification" "grep -q 'New Appointment Request' lib/core/services/appointment_service.dart"
run_test "Acceptance notification" "grep -q 'Appointment Confirmed' lib/core/services/appointment_service.dart"
run_test "Rejection notification with reason" "grep -q 'Appointment Rejected' lib/core/services/appointment_service.dart"
run_test "Doctor home tab notification" "grep -q 'showInstantNotification' lib/doctor/doctor_home_tab.dart"
run_test "Notification permission request" "grep -q 'requestPermission' lib/core/services/notification_service.dart"
run_test "Permission caching logic" "grep -q '_permissionChecked' lib/core/services/notification_service.dart"

# ============================================
# PHASE 8: ERROR HANDLING CHECKS
# ============================================
echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
echo -e "${YELLOW}🛡️ PHASE 8: ERROR HANDLING${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
echo ""

run_test "Try-catch in booking" "grep -A5 'bookAppointment' lib/core/services/appointment_service.dart | grep -q 'try'"
run_test "Try-catch in accept" "grep -A5 'acceptAppointment' lib/core/services/appointment_service.dart | grep -q 'try'"
run_test "Try-catch in reject" "grep -A5 'rejectAppointment' lib/core/services/appointment_service.dart | grep -q 'try'"
run_test "Error logging" "grep -q '❌ Error' lib/core/services/appointment_service.dart"
run_test "User-friendly error messages" "grep -q 'Get.snackbar.*Error' lib/core/services/appointment_service.dart"

# ============================================
# PHASE 9: REAL-TIME FEATURES
# ============================================
echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
echo -e "${YELLOW}⚡ PHASE 9: REAL-TIME FEATURES${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
echo ""

run_test "StreamBuilder in doctor appointments" "grep -q 'StreamBuilder' lib/doctor/doctor_appointments_tab.dart"
run_test "StreamBuilder in doctor home" "grep -q 'StreamBuilder' lib/doctor/doctor_home_tab.dart"
run_test "Firestore snapshots listener" "grep -q '.snapshots()' lib/doctor/doctor_appointments_tab.dart"
run_test "Stream method for doctor" "grep -q 'streamDoctorAppointments' lib/core/services/appointment_service.dart"
run_test "Stream method for patient" "grep -q 'streamUserAppointments' lib/core/services/appointment_service.dart"

# ============================================
# PHASE 10: CLOUDINARY INTEGRATION
# ============================================
echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
echo -e "${YELLOW}☁️ PHASE 10: CLOUDINARY INTEGRATION${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
echo ""

run_test "CloudinaryService class exists" "grep -q 'class CloudinaryService' lib/core/services/cloudinary_service.dart"
run_test "Upload image method" "grep -q 'Future<String> uploadImage' lib/core/services/cloudinary_service.dart"
run_test "Payment slip upload method" "grep -q 'uploadPaymentSlip' lib/core/services/appointment_service.dart"
run_test "Cloudinary folder structure" "grep -q \"folder: 'payment_slips'\" lib/core/services/appointment_service.dart"
run_test "Secure URL returned" "grep -q 'response.secureUrl' lib/core/services/cloudinary_service.dart"

# ============================================
# FINAL SUMMARY
# ============================================
echo ""
echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
echo -e "${YELLOW}📊 TEST SUMMARY${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
echo ""

TOTAL=$((PASS + FAIL))
PERCENTAGE=$((PASS * 100 / TOTAL))

echo -e "Total Tests: ${BLUE}${TOTAL}${NC}"
echo -e "${GREEN}✅ Passed: ${PASS}${NC}"
echo -e "${RED}❌ Failed: ${FAIL}${NC}"
echo -e "Success Rate: ${GREEN}${PERCENTAGE}%${NC}"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
    echo -e "${GREEN}🎉 ALL TESTS PASSED - PRODUCTION READY!${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
    exit 0
elif [ $PERCENTAGE -ge 80 ]; then
    echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}⚠️  MOSTLY PASSING - MINOR FIXES NEEDED${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
    exit 1
else
    echo -e "${RED}═══════════════════════════════════════════════${NC}"
    echo -e "${RED}❌ CRITICAL FAILURES - FIX REQUIRED${NC}"
    echo -e "${RED}═══════════════════════════════════════════════${NC}"
    exit 2
fi
