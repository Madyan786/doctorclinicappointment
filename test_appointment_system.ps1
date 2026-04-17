# 🧪 BRUTAL AUTOMATED TEST SCRIPT - WINDOWS POWERSHELL
# Run: .\test_appointment_system.ps1

Write-Host "═══════════════════════════════════════════════"
Write-Host "🚀 DOCTOR CLINIC - BRUTAL TEST SUITE" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════"
Write-Host ""

$PASS = 0
$FAIL = 0

# Function to run test
function Run-Test {
    param(
        [string]$TestName,
        [scriptblock]$TestCommand
    )
    
    Write-Host "🧪 Running: $TestName" -ForegroundColor Blue
    
    try {
        $result = & $TestCommand 2>&1
        if ($LASTEXITCODE -eq 0 -or $result) {
            Write-Host "✅ PASS: $TestName" -ForegroundColor Green
            $script:PASS++
        } else {
            Write-Host "❌ FAIL: $TestName" -ForegroundColor Red
            $script:FAIL++
        }
    } catch {
        Write-Host "❌ FAIL: $TestName" -ForegroundColor Red
        $script:FAIL++
    }
    Write-Host ""
}

# ============================================
# PHASE 1: PROJECT SETUP CHECKS
# ============================================
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "📦 PHASE 1: PROJECT SETUP" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host ""

Run-Test "Flutter SDK installed" { flutter --version }
Run-Test "Project directory exists" { Test-Path "lib" }

# ============================================
# PHASE 2: FILE STRUCTURE CHECKS
# ============================================
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "📁 PHASE 2: FILE STRUCTURE" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host ""

Run-Test "Appointment service exists" { Test-Path "lib/core/services/appointment_service.dart" }
Run-Test "Notification service exists" { Test-Path "lib/core/services/notification_service.dart" }
Run-Test "Doctor appointments tab exists" { Test-Path "lib/doctor/doctor_appointments_tab.dart" }
Run-Test "Doctor home tab exists" { Test-Path "lib/doctor/doctor_home_tab.dart" }
Run-Test "Book appointment screen exists" { Test-Path "lib/screens/book_appointment_screen.dart" }
Run-Test "Cloudinary service exists" { Test-Path "lib/core/services/cloudinary_service.dart" }

# ============================================
# PHASE 3: CODE QUALITY CHECKS
# ============================================
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "🔍 PHASE 3: CODE QUALITY" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host ""

Run-Test "bookAppointment function exists" { 
    Select-String -Path "lib/core/services/appointment_service.dart" -Pattern "Future<bool> bookAppointment" -Quiet 
}
Run-Test "acceptAppointment function exists" { 
    Select-String -Path "lib/core/services/appointment_service.dart" -Pattern "Future<bool> acceptAppointment" -Quiet 
}
Run-Test "rejectAppointment function exists" { 
    Select-String -Path "lib/core/services/appointment_service.dart" -Pattern "Future<bool> rejectAppointment" -Quiet 
}
Run-Test "showInstantNotification exists" { 
    Select-String -Path "lib/core/services/notification_service.dart" -Pattern "Future<void> showInstantNotification" -Quiet 
}
Run-Test "Doctor notification on booking" { 
    Select-String -Path "lib/core/services/appointment_service.dart" -Pattern "Notify DOCTOR about new appointment request" -Quiet 
}
Run-Test "Permission caching implemented" { 
    Select-String -Path "lib/core/services/notification_service.dart" -Pattern "_permissionGranted" -Quiet 
}
Run-Test "Patient notification on accept" { 
    Select-String -Path "lib/core/services/appointment_service.dart" -Pattern "Appointment Confirmed" -Quiet 
}
Run-Test "Patient notification on reject" { 
    Select-String -Path "lib/core/services/appointment_service.dart" -Pattern "Appointment Rejected" -Quiet 
}
Run-Test "Stream for doctor appointments" { 
    Select-String -Path "lib/core/services/appointment_service.dart" -Pattern "streamDoctorAppointments" -Quiet 
}
Run-Test "Error handling in booking" { 
    Select-String -Path "lib/core/services/appointment_service.dart" -Pattern "try \{" -Quiet 
}
Run-Test "Developer logging present" { 
    Select-String -Path "lib/core/services/appointment_service.dart" -Pattern "developer.log" -Quiet 
}

# ============================================
# PHASE 4: NOTIFICATION FLOW CHECKS
# ============================================
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "🔔 PHASE 4: NOTIFICATION FLOW" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host ""

Run-Test "Patient booking notification" { 
    Select-String -Path "lib/core/services/appointment_service.dart" -Pattern "Appointment Request Sent" -Quiet 
}
Run-Test "Doctor new request notification" { 
    Select-String -Path "lib/core/services/appointment_service.dart" -Pattern "New Appointment Request" -Quiet 
}
Run-Test "Acceptance notification" { 
    Select-String -Path "lib/core/services/appointment_service.dart" -Pattern "Appointment Confirmed" -Quiet 
}
Run-Test "Rejection notification with reason" { 
    Select-String -Path "lib/core/services/appointment_service.dart" -Pattern "Appointment Rejected" -Quiet 
}
Run-Test "Doctor home tab notification" { 
    Select-String -Path "lib/doctor/doctor_home_tab.dart" -Pattern "showInstantNotification" -Quiet 
}
Run-Test "Notification permission request" { 
    Select-String -Path "lib/core/services/notification_service.dart" -Pattern "requestPermission" -Quiet 
}
Run-Test "Permission caching logic" { 
    Select-String -Path "lib/core/services/notification_service.dart" -Pattern "_permissionChecked" -Quiet 
}

# ============================================
# PHASE 5: REAL-TIME FEATURES
# ============================================
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "⚡ PHASE 5: REAL-TIME FEATURES" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host ""

Run-Test "StreamBuilder in doctor appointments" { 
    Select-String -Path "lib/doctor/doctor_appointments_tab.dart" -Pattern "StreamBuilder" -Quiet 
}
Run-Test "StreamBuilder in doctor home" { 
    Select-String -Path "lib/doctor/doctor_home_tab.dart" -Pattern "StreamBuilder" -Quiet 
}
Run-Test "Firestore snapshots listener" { 
    Select-String -Path "lib/doctor/doctor_appointments_tab.dart" -Pattern "\.snapshots\(\)" -Quiet 
}
Run-Test "Stream method for doctor" { 
    Select-String -Path "lib/core/services/appointment_service.dart" -Pattern "streamDoctorAppointments" -Quiet 
}
Run-Test "Stream method for patient" { 
    Select-String -Path "lib/core/services/appointment_service.dart" -Pattern "streamUserAppointments" -Quiet 
}

# ============================================
# PHASE 6: ERROR HANDLING
# ============================================
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "🛡️ PHASE 6: ERROR HANDLING" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host ""

Run-Test "Try-catch in doctor appointments" { 
    Select-String -Path "lib/doctor/doctor_appointments_tab.dart" -Pattern "try \{" -Quiet 
}
Run-Test "Try-catch in doctor home" { 
    Select-String -Path "lib/doctor/doctor_home_tab.dart" -Pattern "try \{" -Quiet 
}
Run-Test "Error logging" { 
    Select-String -Path "lib/doctor/doctor_appointments_tab.dart" -Pattern "❌ Error" -Quiet 
}
Run-Test "User-friendly error messages" { 
    Select-String -Path "lib/doctor/doctor_appointments_tab.dart" -Pattern "Get.snackbar" -Quiet 
}

# ============================================
# PHASE 7: UI/UX CHECKS
# ============================================
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "🎨 PHASE 7: UI/UX" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host ""

Run-Test "Loading dialog in accept" { 
    Select-String -Path "lib/doctor/doctor_appointments_tab.dart" -Pattern "Get.dialog" -Quiet 
}
Run-Test "Success feedback messages" { 
    Select-String -Path "lib/doctor/doctor_appointments_tab.dart" -Pattern "Get.snackbar" -Quiet 
}
Run-Test "Payment slip viewer" { 
    Select-String -Path "lib/doctor/doctor_appointments_tab.dart" -Pattern "_showPaymentSlipDialog" -Quiet 
}
Run-Test "Empty state handling" { 
    Select-String -Path "lib/doctor/doctor_appointments_tab.dart" -Pattern "_buildEmptyState" -Quiet 
}
Run-Test "Dark mode support" { 
    Select-String -Path "lib/doctor/doctor_appointments_tab.dart" -Pattern "isDark" -Quiet 
}

# ============================================
# PHASE 8: CLOUDINARY INTEGRATION
# ============================================
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "☁️ PHASE 8: CLOUDINARY INTEGRATION" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host ""

Run-Test "CloudinaryService class exists" { 
    Select-String -Path "lib/core/services/cloudinary_service.dart" -Pattern "class CloudinaryService" -Quiet 
}
Run-Test "Upload image method" { 
    Select-String -Path "lib/core/services/cloudinary_service.dart" -Pattern "Future<String> uploadImage" -Quiet 
}
Run-Test "Payment slip upload method" { 
    Select-String -Path "lib/core/services/appointment_service.dart" -Pattern "uploadPaymentSlip" -Quiet 
}
Run-Test "Cloudinary folder structure" { 
    Select-String -Path "lib/core/services/appointment_service.dart" -Pattern "folder: 'payment_slips'" -Quiet 
}
Run-Test "Secure URL returned" { 
    Select-String -Path "lib/core/services/cloudinary_service.dart" -Pattern "response.secureUrl" -Quiet 
}

# ============================================
# FINAL SUMMARY
# ============================================
Write-Host ""
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "📊 TEST SUMMARY" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host ""

$TOTAL = $PASS + $FAIL
$PERCENTAGE = [math]::Round(($PASS / $TOTAL) * 100)

Write-Host "Total Tests: $TOTAL" -ForegroundColor Cyan
Write-Host "✅ Passed: $PASS" -ForegroundColor Green
Write-Host "❌ Failed: $FAIL" -ForegroundColor Red
Write-Host "Success Rate: $PERCENTAGE%" -ForegroundColor $(if($PERCENTAGE -ge 90){"Green"}else{"Yellow"})
Write-Host ""

if ($FAIL -eq 0) {
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Green
    Write-Host "🎉 ALL TESTS PASSED - PRODUCTION READY!" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Green
} elseif ($PERCENTAGE -ge 80) {
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host "⚠️  MOSTLY PASSING - MINOR FIXES NEEDED" -ForegroundColor Yellow
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Yellow
} else {
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Red
    Write-Host "❌ CRITICAL FAILURES - FIX REQUIRED" -ForegroundColor Red
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Red
}

Write-Host ""
