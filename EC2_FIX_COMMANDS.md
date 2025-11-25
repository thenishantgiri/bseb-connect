# EC2 Fix Commands - Run These Manually

## SSH into your server first:
```bash
ssh -i backend/deployment/bseb-key-1764063616.pem ec2-user@65.2.113.83
```

## Then run these commands in order:

### 1. Go to home directory and pull latest code:
```bash
cd ~
cd bseb-connect
git pull origin main
```

### 2. Build the backend:
```bash
cd backend
npm install twilio
npm run build
```

### 3. Copy built files to production directory:
```bash
sudo cp -r dist/* /var/www/bseb-backend/dist/
sudo cp package.json /var/www/bseb-backend/
sudo cp package-lock.json /var/www/bseb-backend/
```

### 4. Install Twilio in production directory:
```bash
cd /var/www/bseb-backend
sudo npm install twilio
```

### 5. Create PM2 ecosystem file:
```bash
sudo nano /var/www/bseb-backend/ecosystem.config.js
```

Paste this content:
```javascript
module.exports = {
  apps: [{
    name: 'bseb-backend',
    script: 'dist/src/main.js',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    }
  }]
};
```

### 6. Start the application with PM2:
```bash
cd /var/www/bseb-backend
sudo pm2 delete all  # Clear any existing processes
sudo pm2 start ecosystem.config.js
sudo pm2 save
sudo pm2 startup systemd -u root --hp /root
```

### 7. Check if it's running:
```bash
sudo pm2 list
sudo pm2 logs bseb-backend --lines 50
```

### 8. Update Twilio credentials:
```bash
sudo nano /var/www/bseb-backend/.env
```

Add these lines (replace with your actual credentials):
```
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=your_auth_token_here
TWILIO_VERIFY_SERVICE_SID=VAxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
ENABLE_TEST_OTP=false
NODE_ENV=production
```

### 9. Restart the application:
```bash
sudo pm2 restart bseb-backend
sudo pm2 logs bseb-backend --lines 20
```

### 10. Test if backend is working:
```bash
curl http://localhost:3000
curl http://localhost:3000/api
```

## If you get errors:

### Check where the main.js file is:
```bash
find /var/www/bseb-backend -name "main.js"
```

### If it's in a different location, update ecosystem.config.js:
```bash
sudo nano /var/www/bseb-backend/ecosystem.config.js
```

Change the script path to the correct location, for example:
- If main.js is at `/var/www/bseb-backend/dist/main.js`, use: `script: 'dist/main.js'`
- If main.js is at `/var/www/bseb-backend/dist/src/main.js`, use: `script: 'dist/src/main.js'`

### Then restart:
```bash
sudo pm2 restart bseb-backend
```

## Success indicators:
- `pm2 list` shows the process as "online" in green
- `pm2 logs` shows "Nest application successfully started"
- `curl http://localhost:3000` returns a response
- `curl http://65.2.113.83/api` from your local machine works