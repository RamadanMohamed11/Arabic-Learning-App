# Phone Installation Fix Guide

## 🔧 Issues Fixed

### 1. ✅ Android SDK Version Updated
**Problem**: Plugins require Android SDK 36, but project was using SDK 34
**Solution**: Updated both `compileSdk` and `targetSdk` to 36

```kotlin
// Updated in android/app/build.gradle.kts
android {
    compileSdk = 36  // Was 34, now matches plugin requirements
    defaultConfig {
        targetSdk = 36   // Was 34, now matches compileSdk
    }
}
```

### 2. 🚫 Installation Blocked by User/Phone
**Error**: `INSTALL_FAILED_USER_RESTRICTED: Install canceled by user`
**Cause**: Phone security settings are blocking the installation

## 📱 Phone Settings Fix

### For Xiaomi Phones (M2101K6G - Redmi Note 10 Pro):

#### Step 1: Enable Developer Options
1. Go to **Settings** > **About phone**
2. Tap **MIUI version** 7 times until "You are now a developer" appears
3. Go back to **Settings** > **Additional settings** > **Developer options**

#### Step 2: Enable USB Debugging & Installation
1. In **Developer options**:
   - ✅ Enable **USB debugging**
   - ✅ Enable **USB debugging (Security settings)**
   - ✅ Enable **Install via USB**
   - ✅ Enable **USB installation** (if available)

#### Step 3: MIUI Optimization (Important for Xiaomi)
1. In **Developer options**:
   - ✅ **Turn OFF MIUI optimization** (very important!)
   - Phone will ask to restart - **restart it**

#### Step 4: Unknown Sources
1. Go to **Settings** > **Privacy protection** > **Special app access**
2. Find **Install unknown apps**
3. Enable for **USB debugging** or **ADB**

### For Other Android Phones:

#### General Steps:
1. **Settings** > **About phone** > Tap **Build number** 7 times
2. **Settings** > **Developer options**:
   - ✅ Enable **USB debugging**
   - ✅ Enable **Install via USB**
3. **Settings** > **Security** > **Unknown sources** ✅ Enable

## 🔄 Installation Commands

### Method 1: Clean Build & Install
```bash
# 1. Clean everything
flutter clean
flutter pub get

# 2. Build debug APK
flutter build apk --debug

# 3. Install on phone
flutter install
```

### Method 2: Direct ADB Installation
```bash
# 1. Build APK
flutter build apk --debug

# 2. Check if device is connected
adb devices

# 3. Install directly
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

### Method 3: Force Install (if still blocked)
```bash
# Install with force flag
adb install -r -d build/app/outputs/flutter-apk/app-debug.apk
```

## 🔍 Troubleshooting Steps

### If Still Getting "User Restricted" Error:

#### 1. Check ADB Connection
```bash
adb devices
# Should show your device as "device" not "unauthorized"
```

#### 2. Restart ADB Server
```bash
adb kill-server
adb start-server
adb devices
```

#### 3. Re-enable USB Debugging
1. Turn OFF USB debugging
2. Turn ON USB debugging
3. Accept the computer authorization popup on phone

#### 4. Try Different USB Cable/Port
- Use original USB cable
- Try different USB port on computer
- Ensure cable supports data transfer (not just charging)

### If Phone Shows Authorization Dialog:
1. **Always allow from this computer** ✅ Check this
2. Tap **OK**

### For Xiaomi Phones Specifically:
1. **MIUI Optimization MUST be OFF**
2. Go to **Settings** > **Apps** > **Manage apps** > **⋮** > **Special access** > **Install unknown apps**
3. Enable for system apps that handle installations

## 🚀 Complete Installation Process

### Step-by-Step:
```bash
# 1. Ensure phone is properly connected
adb devices

# 2. Clean and rebuild
flutter clean
flutter pub get

# 3. Build with updated SDK
flutter build apk --debug

# 4. Install on phone
flutter install

# Alternative: Direct install
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

## ⚠️ Important Notes

### SDK Updates:
- ✅ **compileSdk = 36** - Now matches all plugin requirements
- ✅ **targetSdk = 36** - Ensures compatibility
- ✅ **NDK = 27.0.12077973** - Latest required version

### Plugin Compatibility:
- ✅ **audioplayers_android** - Now compatible with SDK 36
- ✅ **path_provider_android** - Now compatible with SDK 36
- ✅ **shared_preferences_android** - Now compatible with SDK 36
- ✅ **speech_to_text** - Now compatible with SDK 36

### Installation Success Indicators:
```bash
# Successful installation output:
Performing Streamed Install
Success
```

## 📱 Device-Specific Tips

### Xiaomi/Redmi Phones:
- **MIUI Optimization OFF** is crucial
- May need to restart phone after changing developer settings
- Check **Security** app for any installation blocks

### Samsung Phones:
- Enable **Developer options** > **USB debugging**
- **Settings** > **Biometrics and security** > **Install unknown apps**

### Huawei Phones:
- **Settings** > **Security** > **More settings** > **Allow installation of apps from unknown sources**
- May need to disable **App lock** temporarily

## 🎯 Expected Results

After following these steps:
- ✅ No more SDK version warnings during build
- ✅ Successful APK installation on phone
- ✅ App launches and runs normally
- ✅ All plugins (audio, storage, speech) work correctly

## Date
2025-01-21
