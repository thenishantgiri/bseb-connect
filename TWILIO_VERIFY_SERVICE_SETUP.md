# Twilio Verify Service Setup Guide for BSEB Connect

## 📋 Prerequisites
- Twilio account (sign up at https://www.twilio.com/try-twilio if you haven't)
- Access to Twilio Console

## 🚀 Step-by-Step Setup

### Step 1: Access Twilio Console
1. Go to https://console.twilio.com
2. Log in with your Twilio credentials
3. You'll see your Account SID and Auth Token on the dashboard

### Step 2: Navigate to Verify Services
1. **Direct Link**: https://console.twilio.com/us1/develop/verify/services
2. **Or Navigate**:
   - Click on "Develop" in the left sidebar
   - Under "Verify", click on "Services"
   - Click on "Try it out" if it's your first time

### Step 3: Create New Verify Service

1. **Click "Create Service"** button (blue button)

2. **Fill in Service Details**:
   ```
   Friendly Name: BSEB Connect
   ```
   This is just a display name for your reference

3. **Click "Create"**

4. **Copy the Service SID**:
   - It will look like: `VAxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`
   - Save this - you'll need it for your `.env` file

### Step 4: Configure Service Settings (Optional but Recommended)

After creating the service, you'll see configuration options:

#### 4.1 Code Length
- Default: 6 digits
- You can change to 4-8 digits if needed
- **Recommendation**: Keep 6 digits

#### 4.2 Lookup Enabled
- Toggle ON for better security
- This validates phone numbers before sending

#### 4.3 Custom Code Enabled
- Leave OFF (Twilio generates secure codes)

#### 4.4 Do Not Share Warning Enabled
- Toggle ON to add security warning to messages

#### 4.5 Channels Configuration

**SMS Settings**:
- **Template**: Customize your SMS message
  ```
  Your BSEB Connect verification code is: {{otp}}
  ```

**Voice Settings**:
- **Template**: Customize voice message
  ```
  Your BSEB Connect verification code is {{otp}}. I repeat, {{otp}}.
  ```

**Email Settings**:
- **From Email**: noreply@yourdomain.com
- **From Name**: BSEB Connect
- **Subject**: Your BSEB Connect Verification Code
- **HTML Template**: Can customize with your branding

### Step 5: Get Your Credentials

You now have everything needed:

1. **Account SID**:
   - Find at: Dashboard → Account Info
   - Format: `ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

2. **Auth Token**:
   - Find at: Dashboard → Account Info
   - Click "View" to reveal
   - Format: 32 character string

3. **Verify Service SID**:
   - From the service you just created
   - Format: `VAxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

### Step 6: Update Your .env File

Add these to your EC2 server's `.env` file:

```env
# Twilio Configuration
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=your_auth_token_here_32_chars
TWILIO_VERIFY_SERVICE_SID=VAxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Optional: For regular SMS (not needed for OTP)
TWILIO_PHONE_NUMBER=+1234567890

# Optional: For WhatsApp (sandbox number for testing)
TWILIO_WHATSAPP_NUMBER=+14155238886

# OTP Settings
OTP_EXPIRY_MINUTES=10
OTP_LENGTH=6

# For Production
NODE_ENV=production
ENABLE_TEST_OTP=false
```

## 🧪 Test Your Service

### Quick Test in Twilio Console:

1. Go to your Verify Service page
2. Click on "Try it out" tab
3. Enter your phone number (with country code)
4. Click "Send verification code"
5. Check your phone for OTP
6. Enter the code to verify

### Test via cURL:

```bash
# Send OTP
curl -X POST "https://verify.twilio.com/v2/Services/YOUR_SERVICE_SID/Verifications" \
  -u "YOUR_ACCOUNT_SID:YOUR_AUTH_TOKEN" \
  -d "To=+919876543210" \
  -d "Channel=sms"

# Verify OTP
curl -X POST "https://verify.twilio.com/v2/Services/YOUR_SERVICE_SID/VerificationCheck" \
  -u "YOUR_ACCOUNT_SID:YOUR_AUTH_TOKEN" \
  -d "To=+919876543210" \
  -d "Code=123456"
```

## 💡 Additional Features

### Enable WhatsApp (Optional)

1. **For Testing (Sandbox)**:
   - Go to: https://console.twilio.com/us1/develop/sms/try-it-out/whatsapp-learn
   - Follow setup instructions
   - Users must opt-in by sending "join [your-keyword]" to +14155238886

2. **For Production**:
   - Apply for WhatsApp Business API access
   - Get approved WhatsApp number
   - Update TWILIO_WHATSAPP_NUMBER in .env

### Rate Limiting

Twilio automatically enforces:
- Max 5 verification attempts per number per service
- Cooldown period between attempts
- Automatic fraud detection

### Monitoring

View analytics at:
- Console → Monitor → Insights → Verify
- See success rates, channels used, geographic distribution

## 🎯 Deploy to Your Server

After setting up the Verify Service:

```bash
# SSH into your EC2
ssh -i bseb-key-1764063616.pem ec2-user@65.2.113.83

# Update environment variables
sudo nano /var/www/bseb-backend/.env
# Add your Twilio credentials

# Pull latest code
cd /var/www/bseb-backend
sudo git pull origin main

# Install Twilio SDK
sudo npm install twilio

# Rebuild and restart
sudo npm run build
sudo pm2 restart bseb-backend

# Check logs
sudo pm2 logs bseb-backend
```

## 📊 Pricing

### Free Trial:
- $15 credit on signup
- ~300 verifications (at $0.05 each)
- All features available

### Pay as You Go:
- SMS Verification: $0.05
- Voice Verification: $0.05
- WhatsApp Verification: $0.05
- Email Verification: $0.05

### Volume Discounts:
- Available for >10,000 verifications/month
- Contact Twilio sales

## 🔍 Troubleshooting

| Issue | Solution |
|-------|----------|
| "Service not found" | Check SERVICE_SID is correct |
| "Authentication failed" | Verify Account SID and Auth Token |
| "Invalid number" | Ensure number includes country code (+91 for India) |
| "Rate limit exceeded" | Wait 10 minutes or use different number |
| No OTP received | Check Twilio balance, verify number format |

## 📱 Test Endpoints

Once deployed, test your endpoints:

```bash
# Send OTP via SMS
curl -X POST http://65.2.113.83/api/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"identifier": "9876543210", "type": "login"}'

# Send OTP via WhatsApp
curl -X POST http://65.2.113.83/api/auth/send-otp/whatsapp \
  -H "Content-Type: application/json" \
  -d '{"identifier": "9876543210"}'

# Verify OTP
curl -X POST http://65.2.113.83/api/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"identifier": "9876543210", "otp": "123456"}'

# Resend via Voice Call
curl -X POST http://65.2.113.83/api/auth/resend-otp \
  -H "Content-Type: application/json" \
  -d '{"identifier": "9876543210", "channel": "call"}'
```

## ✅ Checklist

- [ ] Created Twilio account
- [ ] Created Verify Service named "BSEB Connect"
- [ ] Copied Service SID (VAxxxxx...)
- [ ] Copied Account SID (ACxxxxx...)
- [ ] Copied Auth Token
- [ ] Updated .env file on EC2
- [ ] Deployed code to server
- [ ] Tested SMS OTP
- [ ] (Optional) Set up WhatsApp
- [ ] (Optional) Customized message templates

## 📞 Support

- **Twilio Status**: https://status.twilio.com
- **Verify Docs**: https://www.twilio.com/docs/verify
- **Support**: https://support.twilio.com
- **Console**: https://console.twilio.com

## 🎉 Success!

Once you've completed these steps, your BSEB Connect app will have:
- Professional OTP verification
- Multi-channel support (SMS, Voice, WhatsApp)
- Automatic retry and fraud detection
- Global delivery capability
- Detailed analytics and monitoring

The integration is production-ready and scalable!