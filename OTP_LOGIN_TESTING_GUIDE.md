# OTP Login Testing Guide

**How to test OTP login for BSEB Connect App**

---

## 🎯 Quick Overview

OTP login has 2 steps:
1. **Send OTP** → System generates 6-digit code and shows it in console
2. **Verify OTP** → Enter the code to complete login

---

## 📝 Prerequisites

1. **Backend running**: `cd backend && npm run start:dev`
2. **User registered**: You need an existing user (phone + email)
3. **Console access**: You'll see OTP codes in the terminal

---

## Method 1: Using Postman (Easiest)

### Step 1: Register a User First

```json
POST http://localhost:3000/auth/register
Content-Type: application/json

{
  "phone": "9999888877",
  "email": "mytest@example.com",
  "password": "Test@1234",
  "fullName": "Test User",
  "dob": "2005-01-01",
  "gender": "Male",
  "class": "12",
  "schoolName": "Test School",
  "state": "Bihar",
  "district": "Patna"
}
```

**Expected Response**:
```json
{
  "status": 1,
  "message": "Registration successful"
}
```

### Step 2: Send OTP

```json
POST http://localhost:3000/auth/login/otp
Content-Type: application/json

{
  "identifier": "mytest@example.com"
}
```

**OR with phone**:
```json
{
  "identifier": "9999888877"
}
```

**Expected Response**:
```json
{
  "status": 1,
  "message": "OTP sent successfully"
}
```

**Check Backend Console**:
Look for this line in your terminal:
```
OTP for email mytest@example.com: 123456
```
or
```
OTP for phone 9999888877: 654321
```

### Step 3: Verify OTP and Login

```json
POST http://localhost:3000/auth/login/verify
Content-Type: application/json

{
  "identifier": "mytest@example.com",
  "otp": "123456"
}
```

**Replace `123456` with the actual OTP from your console!**

**Expected Response**:
```json
{
  "status": 1,
  "message": "Login successful",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 1,
      "phone": "9999888877",
      "email": "mytest@example.com",
      "fullName": "Test User",
      ...
    }
  }
}
```

**✅ Success!** Save the `token` for authenticated requests.

---

## Method 2: Using cURL (Command Line)

### Complete Flow:

```bash
# Step 1: Register user
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "8888777766",
    "email": "curl@example.com",
    "password": "Test@1234",
    "fullName": "Curl User",
    "dob": "2005-01-01",
    "gender": "Male",
    "class": "12",
    "schoolName": "Test School",
    "state": "Bihar",
    "district": "Patna"
  }'

# Step 2: Send OTP
curl -X POST http://localhost:3000/auth/login/otp \
  -H "Content-Type: application/json" \
  -d '{"identifier": "curl@example.com"}'

# Check console for OTP, then:

# Step 3: Verify OTP (replace 123456 with actual OTP)
curl -X POST http://localhost:3000/auth/login/verify \
  -H "Content-Type: application/json" \
  -d '{"identifier": "curl@example.com", "otp": "123456"}'
```

---

## Method 3: Using Flutter App

### Step 1: Update UI Screen

**File**: `lib/view_controllers/LoginScreen.dart`

Add email/phone input field:

```dart
TextField(
  controller: identifierController,
  decoration: InputDecoration(
    labelText: 'Phone Number or Email',
    hintText: '9876543210 or user@example.com',
  ),
  keyboardType: TextInputType.emailAddress,
)
```

### Step 2: Send OTP in Controller

```dart
Future<void> sendOtp() async {
  final identifier = identifierController.text.trim();

  if (identifier.isEmpty) {
    Get.snackbar('Error', 'Please enter phone or email');
    return;
  }

  isLoading.value = true;

  final response = await ApiService().sendOtpLogin(identifier);

  isLoading.value = false;

  if (response.isSuccess) {
    // Navigate to OTP screen
    Get.to(() => OtpVerificationScreen(), arguments: identifier);
    Get.snackbar('Success', 'OTP sent to $identifier');
  } else {
    Get.snackbar('Error', response.message);
  }
}
```

### Step 3: Verify OTP Screen

```dart
Future<void> verifyOtp() async {
  final identifier = Get.arguments as String; // from previous screen
  final otp = otpController.text.trim();

  if (otp.length != 6) {
    Get.snackbar('Error', 'OTP must be 6 digits');
    return;
  }

  isLoading.value = true;

  final response = await ApiService().verifyOtp(identifier, otp);

  isLoading.value = false;

  if (response.isSuccess && response.data != null) {
    // Save user data
    await AuthController.to._saveUserData(response.data!);

    // Navigate to home
    Get.offAllNamed('/home');
    Get.snackbar('Success', 'Login successful');
  } else {
    Get.snackbar('Error', response.message);
  }
}
```

### Step 4: Get OTP from Console

Since SMS/Email integration isn't done yet, **check your backend console** for the OTP:

1. Run backend: `cd backend && npm run start:dev`
2. Watch the console output
3. When you request OTP, you'll see:
   ```
   OTP for email user@example.com: 123456
   ```
4. Enter `123456` in your Flutter app

---

## 🔥 Using Existing Test Users

I can see from the logs that these users have been created:

### Test User 1 (Email)
- **Email**: `testuser@example.com`
- **Phone**: `9876543210`
- **Password**: `Password@123`
- **Last OTP**: `191031` (might be expired)

### Test User 2 (BSEB Student)
- **Email**: `bseb.student@example.com`
- **Phone**: `9123456789`
- **Password**: `NewPassword@456` (was changed during testing)
- **Roll Number**: `TEST123`

### Quick Test Flow:

```bash
# 1. Send OTP to existing user
curl -X POST http://localhost:3000/auth/login/otp \
  -H "Content-Type: application/json" \
  -d '{"identifier": "testuser@example.com"}'

# 2. Check console for OTP

# 3. Verify OTP (use OTP from console)
curl -X POST http://localhost:3000/auth/login/verify \
  -H "Content-Type: application/json" \
  -d '{"identifier": "testuser@example.com", "otp": "YOUR_OTP_HERE"}'
```

---

## 🐛 Troubleshooting

### Issue 1: "ThrottlerException: Too Many Requests"

**Cause**: Rate limiter allows only 5 OTP requests per hour per user

**Solutions**:
1. **Wait 1 hour** for the limit to reset
2. **Use a different phone/email**
3. **Clear Redis cache**:
   ```bash
   docker exec -it bseb-redis redis-cli FLUSHALL
   ```
4. **Restart backend** to reset in-memory rate limiting

### Issue 2: "User not registered"

**Cause**: User doesn't exist in database

**Solution**: Register first using `/auth/register` endpoint

### Issue 3: "OTP expired or invalid"

**Cause**: OTP expires in 5 minutes for login

**Solution**:
1. Request a new OTP
2. Enter the new OTP quickly

### Issue 4: "Account temporarily locked"

**Cause**: 5 failed OTP attempts

**Solution**:
- Wait 15 minutes
- Or clear Redis: `docker exec -it bseb-redis redis-cli FLUSHALL`

### Issue 5: Can't see OTP in console

**Cause**: Backend not running or not watching console

**Solution**:
1. Make sure backend is running: `npm run start:dev`
2. Watch the terminal output
3. Look for lines starting with "OTP for"

---

## 📱 Production Setup

In production, OTPs won't be in the console. You need to:

1. **Integrate SMS Gateway** (e.g., Twilio, AWS SNS)
   - Update `auth.service.ts` line 52
   - Replace `console.log` with actual SMS service

2. **Integrate Email Service** (e.g., SendGrid, AWS SES)
   - Update `auth.service.ts` line 50
   - Replace `console.log` with actual email service

**Example SMS Integration**:
```typescript
// In auth.service.ts
if (this.isEmail(identifier)) {
  await this.emailService.sendOTP(identifier, otp);
} else {
  await this.smsService.sendOTP(identifier, otp);
}
```

---

## 🧪 Complete Test Script

Here's a complete test you can run:

```bash
#!/bin/bash

# Test OTP Login Flow

echo "=== Testing OTP Login ==="
echo ""

# Step 1: Register new user
echo "1. Registering new user..."
REGISTER_RESPONSE=$(curl -s -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "7777666655",
    "email": "testscript@example.com",
    "password": "Test@1234",
    "fullName": "Script Test User",
    "dob": "2005-01-01",
    "gender": "Male",
    "class": "12",
    "schoolName": "Test School",
    "state": "Bihar",
    "district": "Patna"
  }')

echo "Registration response: $REGISTER_RESPONSE"
echo ""

# Step 2: Send OTP
echo "2. Sending OTP..."
OTP_RESPONSE=$(curl -s -X POST http://localhost:3000/auth/login/otp \
  -H "Content-Type: application/json" \
  -d '{"identifier": "testscript@example.com"}')

echo "OTP response: $OTP_RESPONSE"
echo ""
echo "⚠️  CHECK YOUR BACKEND CONSOLE FOR OTP!"
echo ""

# Step 3: Prompt for OTP
read -p "Enter the OTP from console: " USER_OTP

echo "3. Verifying OTP..."
VERIFY_RESPONSE=$(curl -s -X POST http://localhost:3000/auth/login/verify \
  -H "Content-Type: application/json" \
  -d "{\"identifier\": \"testscript@example.com\", \"otp\": \"$USER_OTP\"}")

echo "Verification response: $VERIFY_RESPONSE"
echo ""

if echo "$VERIFY_RESPONSE" | grep -q "Login successful"; then
  echo "✅ TEST PASSED: OTP login successful!"
else
  echo "❌ TEST FAILED: OTP login failed"
fi
```

Save as `test_otp_login.sh` and run:
```bash
chmod +x test_otp_login.sh
./test_otp_login.sh
```

---

## 🎯 Summary

**OTP Login in 3 Steps**:
1. Register user (one time)
2. Send OTP → Check console for code
3. Verify OTP → Login successful

**Key Points**:
- OTPs are currently printed in console (development only)
- OTPs expire in 5 minutes
- Rate limit: 5 requests per hour
- Account locks after 5 failed attempts

**For Production**:
- Integrate SMS/Email gateway
- OTPs will be sent to user's phone/email
- Console logging should be removed

Need help with a specific step? Let me know! 🚀
