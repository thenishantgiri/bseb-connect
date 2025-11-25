#!/bin/bash

# MSG91 Integration Deployment Script for BSEB Connect
# This script deploys the MSG91 OTP integration to the EC2 instance

set -e

echo "=========================================="
echo "MSG91 Integration Deployment Script"
echo "=========================================="

# Configuration
SERVER_IP="65.2.113.83"
SSH_KEY="./bseb-key-1764063616.pem"
REMOTE_DIR="/var/www/bseb-backend"

echo ""
echo "📋 Deployment Steps:"
echo "1. Connect to EC2 instance"
echo "2. Pull latest code from GitHub"
echo "3. Install MSG91 dependencies"
echo "4. Update environment variables"
echo "5. Rebuild the application"
echo "6. Restart PM2 process"
echo ""

# SSH into server and run deployment commands
echo "🚀 Starting deployment to ${SERVER_IP}..."

ssh -i "${SSH_KEY}" ec2-user@${SERVER_IP} << 'ENDSSH'
    set -e

    echo "📂 Navigating to backend directory..."
    cd /var/www/bseb-backend

    echo "📥 Pulling latest code from GitHub..."
    sudo git pull origin main

    echo "📦 Installing MSG91 dependencies..."
    sudo npm install @nestjs/axios axios

    echo "🔧 Creating MSG91 environment variables file..."
    # Create a temporary MSG91 config file
    sudo tee -a .env.msg91 > /dev/null << 'EOF'
# MSG91 Configuration
MSG91_AUTH_KEY=your_msg91_auth_key_here
MSG91_TEMPLATE_ID=your_template_id_here
MSG91_SENDER_ID=BSEBAP
MSG91_ROUTE=4
MSG91_COUNTRY=91

# OTP Settings
OTP_EXPIRY_MINUTES=10
OTP_LENGTH=6
OTP_RESEND_DELAY=60

# Development Settings (set to true for testing without actual SMS)
ENABLE_TEST_OTP=false
TEST_OTP_CODE=123456
EOF

    echo ""
    echo "⚠️  IMPORTANT: MSG91 Configuration Required!"
    echo "============================================"
    echo "Please update the .env file with your actual MSG91 credentials:"
    echo ""
    echo "1. MSG91_AUTH_KEY - Get from MSG91 Dashboard > Settings > API Keys"
    echo "2. MSG91_TEMPLATE_ID - Get from MSG91 Dashboard > SMS > Templates"
    echo "3. MSG91_SENDER_ID - Your registered 6-character sender ID"
    echo ""
    echo "To edit the .env file, run:"
    echo "sudo nano /var/www/bseb-backend/.env"
    echo ""

    # Check if .env file exists and merge MSG91 config
    if [ -f .env ]; then
        echo "📝 Appending MSG91 configuration to existing .env file..."
        echo "" | sudo tee -a .env > /dev/null
        echo "# MSG91 Configuration (Added on $(date))" | sudo tee -a .env > /dev/null
        sudo cat .env.msg91 | sudo tee -a .env > /dev/null
        sudo rm .env.msg91
    else
        echo "⚠️  No .env file found. Creating new one with MSG91 config..."
        sudo mv .env.msg91 .env
    fi

    echo "🏗️  Building the application..."
    sudo npm run build

    echo "🔄 Restarting PM2 process..."
    sudo pm2 restart bseb-backend

    echo "📊 Checking PM2 status..."
    sudo pm2 status bseb-backend

    echo ""
    echo "✅ MSG91 Integration deployed successfully!"
    echo ""
    echo "🧪 Test the OTP endpoints:"
    echo "----------------------------"
    echo "1. Send OTP:"
    echo "   POST http://${SERVER_IP}/api/auth/send-otp"
    echo "   Body: {\"identifier\": \"9876543210\", \"type\": \"login\"}"
    echo ""
    echo "2. Verify OTP:"
    echo "   POST http://${SERVER_IP}/api/auth/verify-otp"
    echo "   Body: {\"identifier\": \"9876543210\", \"otp\": \"123456\"}"
    echo ""
    echo "3. Resend OTP:"
    echo "   POST http://${SERVER_IP}/api/auth/resend-otp"
    echo "   Body: {\"identifier\": \"9876543210\"}"
    echo ""

ENDSSH

echo ""
echo "=========================================="
echo "🎉 Deployment Complete!"
echo "=========================================="
echo ""
echo "📌 Next Steps:"
echo "1. SSH into the server and update MSG91 credentials in .env file"
echo "2. Test the OTP endpoints using Postman"
echo "3. Update Flutter app to use the new OTP endpoints"
echo ""
echo "🔐 To update MSG91 credentials:"
echo "ssh -i ${SSH_KEY} ec2-user@${SERVER_IP}"
echo "sudo nano /var/www/bseb-backend/.env"
echo ""