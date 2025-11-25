# MSG91 OTP Integration Guide for BSEB Connect

## 🚀 Quick Setup

### 1. Get MSG91 Account
1. Sign up at https://msg91.com
2. Get your credentials from Dashboard:
   - **Auth Key**: Settings → API Keys
   - **Template ID**: SMS → Templates (Create OTP template)
   - **Sender ID**: SMS → Sender IDs (6 characters, e.g., "BSEBAP")

### 2. Backend Setup

#### Install Dependencies
```bash
cd backend
npm install @nestjs/axios axios
```

#### Update Environment Variables
Add to your `.env` file on EC2:
```env
# MSG91 Configuration
MSG91_AUTH_KEY=your_actual_auth_key_here
MSG91_TEMPLATE_ID=your_template_id_here
MSG91_SENDER_ID=BSEBAP
MSG91_ROUTE=4
MSG91_COUNTRY=91

# OTP Settings
OTP_EXPIRY_MINUTES=10
OTP_LENGTH=6
OTP_RESEND_DELAY=60
```

#### Add MSG91 Service to Module
Update `backend/src/app.module.ts`:
```typescript
import { HttpModule } from '@nestjs/axios';
import { Msg91Service } from './common/msg91.service';

@Module({
  imports: [
    HttpModule,
    // ... other imports
  ],
  providers: [
    Msg91Service,
    // ... other providers
  ],
})
```

#### Update Auth Module
Update `backend/src/auth/auth.module.ts`:
```typescript
import { HttpModule } from '@nestjs/axios';
import { Msg91Service } from '../common/msg91.service';

@Module({
  imports: [
    HttpModule,
    // ... other imports
  ],
  providers: [
    AuthService,
    Msg91Service, // Add this
    // ... other providers
  ],
})
```

### 3. Frontend (Flutter) Updates

#### Update OTP Screen
Update `lib/screens/mobile_otp_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_api_service.dart';

class MobileOTPScreen extends StatefulWidget {
  @override
  _MobileOTPScreenState createState() => _MobileOTPScreenState();
}

class _MobileOTPScreenState extends State<MobileOTPScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final AuthApiService _authService = Get.find<AuthApiService>();

  bool _isOTPSent = false;
  bool _isLoading = false;
  String _maskedPhone = '';
  int _resendTimer = 0;
  Timer? _timer;

  // Send OTP
  Future<void> _sendOTP() async {
    final phone = _phoneController.text.trim();

    // Validate phone
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(phone)) {
      Get.snackbar('Error', 'Enter valid 10-digit mobile number');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authService.sendOTP(phone);

      if (response.success) {
        setState(() {
          _isOTPSent = true;
          _maskedPhone = response.data['identifier'];
          _startResendTimer();
        });

        Get.snackbar(
          'Success',
          'OTP sent to $_maskedPhone',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Verify OTP
  Future<void> _verifyOTP() async {
    final otp = _otpController.text.trim();

    if (otp.length != 6) {
      Get.snackbar('Error', 'Enter 6-digit OTP');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authService.verifyOTP(
        _phoneController.text.trim(),
        otp,
      );

      if (response.success) {
        // Save tokens and navigate
        await _authService.saveTokens(
          response.data['access_token'],
          response.data['refresh_token'],
        );

        Get.offAllNamed('/home');
      }
    } catch (e) {
      Get.snackbar('Error', 'Invalid OTP');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Resend OTP
  Future<void> _resendOTP() async {
    if (_resendTimer > 0) return;

    setState(() => _isLoading = true);

    try {
      final response = await _authService.resendOTP(_phoneController.text);

      if (response.success) {
        _startResendTimer();
        Get.snackbar('Success', 'OTP resent successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Please try again later');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _startResendTimer() {
    setState(() => _resendTimer = 60);

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mobile Verification')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (!_isOTPSent) ...[
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  hintText: '10-digit mobile number',
                  prefixText: '+91 ',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _sendOTP,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Send OTP'),
              ),
            ] else ...[
              Text(
                'OTP sent to $_maskedPhone',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: 'Enter OTP',
                  hintText: '6-digit OTP',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: _resendTimer > 0 ? null : _resendOTP,
                    child: Text(
                      _resendTimer > 0
                          ? 'Resend in $_resendTimer s'
                          : 'Resend OTP',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOTP,
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Verify OTP'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

#### Add API Service Methods
Update `lib/services/auth_api_service.dart`:

```dart
// Send OTP
Future<ApiResponse<Map<String, dynamic>>> sendOTP(String identifier) async {
  try {
    final response = await _dio.post(
      '${Constant.BASE_URL}auth/send-otp',
      data: {'identifier': identifier, 'type': 'login'},
    );
    return ApiResponse.fromJson(response.data);
  } catch (e) {
    throw _handleError(e);
  }
}

// Verify OTP
Future<ApiResponse<Map<String, dynamic>>> verifyOTP(
  String identifier,
  String otp,
) async {
  try {
    final response = await _dio.post(
      '${Constant.BASE_URL}auth/verify-otp',
      data: {'identifier': identifier, 'otp': otp},
    );
    return ApiResponse.fromJson(response.data);
  } catch (e) {
    throw _handleError(e);
  }
}

// Resend OTP
Future<ApiResponse<Map<String, dynamic>>> resendOTP(String identifier) async {
  try {
    final response = await _dio.post(
      '${Constant.BASE_URL}auth/resend-otp',
      data: {'identifier': identifier},
    );
    return ApiResponse.fromJson(response.data);
  } catch (e) {
    throw _handleError(e);
  }
}
```

### 4. Deploy Backend Changes

```bash
# On your EC2 instance
cd ~/bseb-connect
git pull origin main

# Copy to production
sudo cp -r backend/* /var/www/bseb-backend/
cd /var/www/bseb-backend

# Install new dependencies
npm install @nestjs/axios axios

# Add MSG91 credentials to .env
nano .env
# Add your MSG91 credentials

# Rebuild
npm run build

# Restart
pm2 restart bseb-backend
```

### 5. Test OTP Flow

#### Using Postman:
```json
// 1. Send OTP
POST {{base_url}}/api/auth/send-otp
{
  "identifier": "9876543210",
  "type": "login"
}

// 2. Verify OTP
POST {{base_url}}/api/auth/verify-otp
{
  "identifier": "9876543210",
  "otp": "123456"
}

// 3. Resend OTP
POST {{base_url}}/api/auth/resend-otp
{
  "identifier": "9876543210"
}
```

### 6. MSG91 Dashboard Features

1. **Template Management**: Create templates for different OTP scenarios
2. **Analytics**: Monitor delivery rates and OTP usage
3. **Logs**: View all sent messages and their status
4. **Balance**: Monitor SMS credits

### 7. Production Checklist

- [ ] Get MSG91 production credentials
- [ ] Create OTP template and get it approved
- [ ] Register Sender ID (DLT registration for India)
- [ ] Add credits to MSG91 account
- [ ] Update production .env with credentials
- [ ] Test with real phone numbers
- [ ] Enable rate limiting for OTP requests
- [ ] Set up monitoring for failed OTPs

### 8. Security Best Practices

1. **Rate Limiting**: Limit OTP requests per number
2. **OTP Expiry**: Set reasonable expiry (5-10 minutes)
3. **Attempt Limits**: Lock after 5 failed attempts
4. **Secure Storage**: Store OTPs in Redis, not database
5. **No Logs**: Don't log actual OTP values
6. **HTTPS Only**: Ensure API uses HTTPS in production

### 9. Troubleshooting

| Issue | Solution |
|-------|----------|
| OTP not received | Check MSG91 credits, template approval, DLT registration |
| Invalid template | Ensure template is approved in MSG91 dashboard |
| Rate limit error | Check MSG91 rate limits and upgrade plan if needed |
| Invalid sender ID | Register sender ID with DLT (India requirement) |

### 10. Development Mode

For testing without MSG91 credits:
```env
# In .env
NODE_ENV=development
ENABLE_TEST_OTP=true
TEST_OTP_CODE=123456
```

This will accept `123456` as valid OTP in development mode.