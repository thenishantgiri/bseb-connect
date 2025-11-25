# Twilio OTP Integration Guide for BSEB Connect

## 🚀 Quick Setup

### 1. Get Twilio Account

1. Sign up at https://www.twilio.com/try-twilio
2. You'll get $15 free credits (enough for ~300 OTP verifications)
3. Get your credentials from Dashboard:
   - **Account SID**: Dashboard > Account Info
   - **Auth Token**: Dashboard > Account Info

### 2. Create Twilio Verify Service

1. Go to [Twilio Console > Verify > Services](https://console.twilio.com/us1/develop/verify/services)
2. Click "Create Service"
3. Name: "BSEB Connect"
4. Copy the **Service SID** (starts with `VA...`)

### 3. Backend Setup

#### Install Dependencies
```bash
cd backend
npm install twilio
```

#### Update Environment Variables
Add to your `.env` file on EC2:
```env
# Twilio Configuration
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=your_auth_token_here
TWILIO_VERIFY_SERVICE_SID=VAxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_PHONE_NUMBER=+1234567890  # Optional: for regular SMS
TWILIO_WHATSAPP_NUMBER=+14155238886  # Twilio sandbox number

# OTP Settings
OTP_EXPIRY_MINUTES=10
OTP_LENGTH=6

# Development Settings
NODE_ENV=production
ENABLE_TEST_OTP=false
TEST_OTP_CODE=123456
```

### 4. Deploy to Production

```bash
cd backend/deployment
./deploy-twilio.sh
```

Or manually:
```bash
ssh -i bseb-key-1764063616.pem ec2-user@65.2.113.83
cd /var/www/bseb-backend
sudo git pull origin main
sudo npm install twilio
sudo nano .env  # Add Twilio credentials
sudo npm run build
sudo pm2 restart bseb-backend
```

## 📱 Frontend (Flutter) Integration

### Update OTP Screen
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
  String _maskedIdentifier = '';
  String _otpChannel = 'sms';
  int _resendTimer = 0;
  Timer? _timer;

  // Send OTP with channel selection
  Future<void> _sendOTP({String channel = 'sms'}) async {
    final identifier = _phoneController.text.trim();

    // Validate input
    if (channel == 'sms' || channel == 'whatsapp') {
      if (!RegExp(r'^[6-9]\d{9}$').hasMatch(identifier)) {
        Get.snackbar('Error', 'Enter valid 10-digit mobile number');
        return;
      }
    } else if (channel == 'email') {
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(identifier)) {
        Get.snackbar('Error', 'Enter valid email address');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final endpoint = channel == 'whatsapp'
        ? 'send-otp/whatsapp'
        : 'send-otp';

      final response = await _authService.sendOTP(identifier, channel: channel);

      if (response.success) {
        setState(() {
          _isOTPSent = true;
          _maskedIdentifier = response.data['identifier'];
          _otpChannel = response.data['channel'] ?? channel;
          _startResendTimer();
        });

        Get.snackbar(
          'Success',
          'OTP sent via ${_otpChannel.toUpperCase()} to $_maskedIdentifier',
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

    if (otp.length < 4) {
      Get.snackbar('Error', 'Enter valid OTP');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authService.verifyOTP(
        _phoneController.text.trim(),
        otp,
      );

      if (response.success) {
        // Save tokens if provided
        if (response.data['access_token'] != null) {
          await _authService.saveTokens(
            response.data['access_token'],
            response.data['refresh_token'],
          );
        }

        Get.offAllNamed('/home');
      }
    } catch (e) {
      Get.snackbar('Error', 'Invalid OTP');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Resend OTP with different channel
  Future<void> _resendOTP({String? channel}) async {
    if (_resendTimer > 0) return;

    setState(() => _isLoading = true);

    try {
      final response = await _authService.resendOTP(
        _phoneController.text,
        channel: channel ?? _otpChannel,
      );

      if (response.success) {
        _startResendTimer();
        Get.snackbar(
          'Success',
          'OTP resent via ${channel?.toUpperCase() ?? _otpChannel.toUpperCase()}'
        );
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
      appBar: AppBar(title: Text('Verification')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (!_isOTPSent) ...[
              // Input Field
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: InputDecoration(
                  labelText: 'Mobile Number / Email',
                  hintText: 'Enter mobile or email',
                  prefixIcon: Icon(Icons.phone_android),
                ),
              ),

              SizedBox(height: 20),

              // Channel Selection
              Text('Send OTP via:', style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // SMS Button
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _sendOTP(channel: 'sms'),
                    icon: Icon(Icons.message),
                    label: Text('SMS'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),

                  // WhatsApp Button
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _sendOTP(channel: 'whatsapp'),
                    icon: Icon(Icons.chat),
                    label: Text('WhatsApp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),

                  // Call Button
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _sendOTP(channel: 'call'),
                    icon: Icon(Icons.call),
                    label: Text('Call'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
                ],
              ),
            ] else ...[
              // OTP Verification
              Text(
                'OTP sent via ${_otpChannel.toUpperCase()} to $_maskedIdentifier',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),

              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: 'Enter OTP',
                  hintText: 'Enter OTP',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),

              SizedBox(height: 20),

              // Verify Button
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyOTP,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Verify OTP'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                ),
              ),

              SizedBox(height: 20),

              // Resend Options
              Text('Didn\'t receive OTP?'),
              SizedBox(height: 10),

              if (_resendTimer > 0)
                Text('Resend available in $_resendTimer seconds')
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => _resendOTP(channel: 'sms'),
                      child: Text('Resend SMS'),
                    ),
                    TextButton(
                      onPressed: () => _resendOTP(channel: 'call'),
                      child: Text('Call me'),
                    ),
                    TextButton(
                      onPressed: () => _resendOTP(channel: 'whatsapp'),
                      child: Text('WhatsApp'),
                    ),
                  ],
                ),

              SizedBox(height: 20),

              // Change Number
              TextButton(
                onPressed: () {
                  setState(() {
                    _isOTPSent = false;
                    _otpController.clear();
                  });
                },
                child: Text('Change Number'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

### Update API Service
Update `lib/services/auth_api_service.dart`:

```dart
// Send OTP with channel selection
Future<ApiResponse<Map<String, dynamic>>> sendOTP(
  String identifier, {
  String channel = 'sms',
}) async {
  try {
    final endpoint = channel == 'whatsapp'
      ? 'auth/send-otp/whatsapp'
      : 'auth/send-otp';

    final response = await _dio.post(
      '${Constant.BASE_URL}$endpoint',
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

// Resend OTP with channel selection
Future<ApiResponse<Map<String, dynamic>>> resendOTP(
  String identifier, {
  String? channel,
}) async {
  try {
    final data = {'identifier': identifier};
    if (channel != null) data['channel'] = channel;

    final response = await _dio.post(
      '${Constant.BASE_URL}auth/resend-otp',
      data: data,
    );
    return ApiResponse.fromJson(response.data);
  } catch (e) {
    throw _handleError(e);
  }
}
```

## 🧪 Testing

### Test with Postman

1. Import `BSEB_Connect_Twilio_OTP.postman_collection.json`
2. Set environment variables
3. Test endpoints:

```json
// Send OTP via SMS
POST {{base_url}}/api/auth/send-otp
{
  "identifier": "9876543210",
  "type": "login"
}

// Send OTP via WhatsApp
POST {{base_url}}/api/auth/send-otp/whatsapp
{
  "identifier": "9876543210"
}

// Verify OTP
POST {{base_url}}/api/auth/verify-otp
{
  "identifier": "9876543210",
  "otp": "123456"
}

// Resend with Voice Call
POST {{base_url}}/api/auth/resend-otp
{
  "identifier": "9876543210",
  "channel": "call"
}
```

### Test Mode
In development, set `ENABLE_TEST_OTP=true` and use OTP `123456` for any number.

## 📊 Twilio vs MSG91 Comparison

| Feature | Twilio Verify | MSG91 |
|---------|--------------|-------|
| **SMS OTP** | ✅ | ✅ |
| **Voice OTP** | ✅ | ❌ |
| **WhatsApp OTP** | ✅ | ❌ |
| **Email OTP** | ✅ | ❌ |
| **Auto Retry** | ✅ | ❌ |
| **Fraud Detection** | ✅ | ❌ |
| **Global Coverage** | ✅ 190+ countries | ⚠️ Limited |
| **India DLT** | ✅ Automatic | ⚠️ Manual |
| **Price (India)** | ~$0.05/verification | ~$0.0045/SMS |
| **Free Credits** | $15 (~300 OTPs) | ₹0 |
| **Setup Time** | 10 minutes | 30 minutes |
| **Code Complexity** | Simple | Complex |

## 🔒 Security Features

1. **Rate Limiting**: 5 OTP requests per hour
2. **Auto Expiry**: OTPs expire in 10 minutes
3. **Fraud Detection**: Twilio blocks suspicious requests
4. **Secure Storage**: No OTP storage needed (Twilio handles it)
5. **Multi-channel**: Fallback to voice/WhatsApp if SMS fails

## 🚨 Troubleshooting

| Issue | Solution |
|-------|----------|
| OTP not received | Check Twilio credits, verify phone format (+91XXXXXXXXXX) |
| Invalid Service SID | Create new Verify Service in Twilio Console |
| WhatsApp not working | Enable WhatsApp sandbox, user must opt-in first |
| Rate limit error | Twilio limits verifications per number |

## 💡 Advanced Features

### Enable WhatsApp Sandbox
1. Go to [Twilio WhatsApp Sandbox](https://console.twilio.com/us1/develop/sms/try-it-out/whatsapp-learn)
2. Follow setup instructions
3. User sends "join [keyword]" to Twilio WhatsApp number
4. Now WhatsApp OTP will work for that user

### Custom OTP Templates
```javascript
// In Twilio Console > Verify > Services > Your Service
// Customize messages for each channel
SMS: "Your BSEB Connect OTP is {{otp}}"
Voice: "Your verification code is {{otp}}"
Email: Custom HTML template
```

### Production Checklist
- [ ] Get Twilio production credentials
- [ ] Remove test mode (`ENABLE_TEST_OTP=false`)
- [ ] Set up billing alerts
- [ ] Configure custom OTP templates
- [ ] Test all channels (SMS, Voice, WhatsApp)
- [ ] Monitor usage in Twilio Console

## 📞 Support

- **Twilio Docs**: https://www.twilio.com/docs/verify
- **Twilio Console**: https://console.twilio.com
- **Status Page**: https://status.twilio.com