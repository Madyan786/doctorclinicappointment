# Cloudinary Setup Guide (FREE 25GB Storage)

## Step 1: Create Free Cloudinary Account

1. Go to: https://cloudinary.com/users/register_free
2. Sign up with your email (or Google/GitHub)
3. Verify your email
4. Login to dashboard: https://console.cloudinary.com/

## Step 2: Get Your Credentials

After logging in, you'll see your dashboard. Copy these values:

- **Cloud Name**: (e.g., `dxxxxxxxx`)
- **API Key**: (e.g., `123456789012345`)
- **API Secret**: (e.g., `abcdefghijklmnopqrstuvwxyz`)

## Step 3: Create Upload Preset

1. Go to: **Settings** → **Upload** → **Upload presets**
2. Click **Add upload preset**
3. Configure:
   - **Preset name**: `doctor_clinic_preset`
   - **Signing Mode**: Select **"Unsigned"** (important!)
   - **Folder**: Leave empty or use `doctor_clinic`
   - **Use filename**: Yes
   - **Unique filename**: Yes
4. Click **Save**

## Step 4: Update Flutter App

Open `lib/core/services/cloudinary_service.dart` and replace:

```dart
static const String _cloudName = 'YOUR_CLOUD_NAME';
static const String _uploadPreset = 'doctor_clinic_preset';
```

With your actual values:

```dart
static const String _cloudName = 'dxxxxxxxx'; // Your cloud name
static const String _uploadPreset = 'doctor_clinic_preset'; // Your preset name
```

## Step 5: Test Upload

1. Run the app
2. Go to Doctor Registration
3. Upload a profile picture
4. Check Cloudinary dashboard → Media Library to see uploaded image

---

## Free Tier Limits

✅ **25 GB** storage
✅ **25 GB** bandwidth per month
✅ **Unlimited** transformations
✅ **7,500** transformations/month

**Perfect for small to medium apps!**

---

## Folders Used in App

- `doctor_profiles/` - Doctor profile images
- `doctor_licenses/` - Medical license documents
- `doctor_degrees/` - Degree certificates
- `payment_slips/` - Appointment payment proofs

---

## Dashboard Access

View all uploaded images: https://console.cloudinary.com/console/media_library

---

## Important Notes

1. **Unsigned presets** allow uploads without API authentication (good for mobile apps)
2. Cloudinary automatically optimizes images for faster loading
3. Images are served via CDN (faster than Firebase Storage)
4. You can set auto-deletion rules in Settings if needed

---

## Need Help?

- Cloudinary Docs: https://cloudinary.com/documentation
- Flutter Plugin: https://pub.dev/packages/cloudinary_public
