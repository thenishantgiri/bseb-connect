# GitHub Secrets Configuration Guide

This guide explains how to set up all required GitHub secrets for the CI/CD pipeline.

## 📋 Prerequisites

1. GitHub repository with Actions enabled
2. AWS account with appropriate permissions
3. Google Play Console access (for Android releases)
4. Apple Developer account (for iOS releases)
5. Slack workspace (optional, for notifications)

## 🔐 Required Secrets

### AWS Secrets

These secrets are required for deploying the backend to AWS EC2:

| Secret Name | Description | How to Get |
|------------|-------------|------------|
| `AWS_ACCESS_KEY_ID` | AWS IAM user access key | AWS Console → IAM → Users → Security credentials |
| `AWS_SECRET_ACCESS_KEY` | AWS IAM user secret key | AWS Console → IAM → Users → Security credentials |
| `AWS_REGION` | AWS region (e.g., `us-east-1`) | Your preferred AWS region |
| `EC2_HOST` | Public IP or domain of EC2 instance | After running `deploy-to-aws.sh` |
| `EC2_USER` | SSH username (usually `ubuntu`) | Default: `ubuntu` for Ubuntu AMI |
| `EC2_SSH_KEY` | Private SSH key content | Content of `bseb-connect-key.pem` |

#### Setting up AWS IAM User

1. Go to AWS IAM Console
2. Create new user: `github-actions-user`
3. Attach policies:
   - `AmazonEC2FullAccess` (or custom policy with limited permissions)
   - `AmazonS3FullAccess` (if using S3 for web hosting)
   - `CloudFrontFullAccess` (if using CloudFront)
4. Create access keys and save them

#### Adding EC2 SSH Key

```bash
# Get the content of your SSH key
cat backend/deployment/bseb-connect-key.pem

# Copy the entire content including:
# -----BEGIN RSA PRIVATE KEY-----
# [key content]
# -----END RSA PRIVATE KEY-----
```

### Android Release Secrets

For automated Android app releases to Google Play Store:

| Secret Name | Description | How to Get |
|------------|-------------|------------|
| `ANDROID_KEYSTORE_BASE64` | Base64 encoded keystore file | See below |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password | Your keystore password |
| `ANDROID_KEY_PASSWORD` | Key password | Your key password |
| `ANDROID_KEY_ALIAS` | Key alias | Your key alias |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | Service account JSON | Google Play Console |

#### Creating Android Keystore

```bash
# Generate keystore
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload

# Convert to base64
base64 upload-keystore.jks > keystore_base64.txt

# Copy content of keystore_base64.txt to GitHub secret
```

#### Setting up Google Play Service Account

1. Go to Google Play Console
2. Settings → API access
3. Create new service account
4. Grant permissions: "Release manager"
5. Download JSON key file
6. Copy entire JSON content to `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` secret

### iOS Release Secrets

For automated iOS app releases to App Store:

| Secret Name | Description | How to Get |
|------------|-------------|------------|
| `IOS_BUILD_CERTIFICATE_BASE64` | Base64 encoded p12 certificate | See below |
| `IOS_P12_PASSWORD` | Certificate password | Your certificate password |
| `IOS_PROVISION_PROFILE_BASE64` | Base64 encoded provisioning profile | See below |
| `IOS_KEYCHAIN_PASSWORD` | Temporary keychain password | Any secure password |
| `APP_STORE_CONNECT_API_KEY_ID` | App Store Connect API key ID | App Store Connect |
| `APP_STORE_CONNECT_ISSUER_ID` | App Store Connect issuer ID | App Store Connect |
| `APP_STORE_CONNECT_API_KEY_BASE64` | Base64 encoded API key | App Store Connect |

#### Preparing iOS Certificates

```bash
# Export certificate from Keychain to p12
# Open Keychain Access → My Certificates → Right-click → Export

# Convert to base64
base64 Certificates.p12 > cert_base64.txt

# Convert provisioning profile to base64
base64 YourApp.mobileprovision > profile_base64.txt
```

#### Setting up App Store Connect API

1. Go to App Store Connect
2. Users and Access → Keys
3. Generate new API key with "App Manager" role
4. Download the .p8 key file
5. Note the Key ID and Issuer ID
6. Convert key to base64: `base64 AuthKey_xxxxx.p8`

### Web Deployment Secrets (Optional)

For deploying Flutter web to S3/CloudFront:

| Secret Name | Description | How to Get |
|------------|-------------|------------|
| `S3_BUCKET_NAME` | S3 bucket name for web hosting | Your S3 bucket name |
| `CLOUDFRONT_DISTRIBUTION_ID` | CloudFront distribution ID | CloudFront console |
| `WEB_DOMAIN` | Your web app domain | e.g., `app.bsebconnect.in` |

### Notification Secrets (Optional)

| Secret Name | Description | How to Get |
|------------|-------------|------------|
| `SLACK_WEBHOOK` | Slack incoming webhook URL | Slack App settings |

#### Setting up Slack Webhook

1. Go to https://api.slack.com/apps
2. Create new app or select existing
3. Incoming Webhooks → Activate
4. Add New Webhook to Workspace
5. Copy webhook URL

## 🚀 How to Add Secrets to GitHub

### Method 1: GitHub Web UI

1. Go to your repository on GitHub
2. Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Enter name and value
5. Click "Add secret"

### Method 2: GitHub CLI

```bash
# Install GitHub CLI
brew install gh  # macOS
# or
sudo apt install gh  # Ubuntu

# Authenticate
gh auth login

# Add secret
gh secret set AWS_ACCESS_KEY_ID --body "your-access-key-id"
gh secret set AWS_SECRET_ACCESS_KEY --body "your-secret-access-key"

# Add secret from file
gh secret set EC2_SSH_KEY < bseb-connect-key.pem
gh secret set ANDROID_KEYSTORE_BASE64 < keystore_base64.txt
```

### Method 3: Using a Script

Create `set-secrets.sh`:

```bash
#!/bin/bash

# Load secrets from .env file (DO NOT COMMIT THIS FILE)
source .github-secrets.env

# Set all secrets
gh secret set AWS_ACCESS_KEY_ID --body "$AWS_ACCESS_KEY_ID"
gh secret set AWS_SECRET_ACCESS_KEY --body "$AWS_SECRET_ACCESS_KEY"
gh secret set AWS_REGION --body "$AWS_REGION"
gh secret set EC2_HOST --body "$EC2_HOST"
gh secret set EC2_USER --body "$EC2_USER"
gh secret set EC2_SSH_KEY --body "$EC2_SSH_KEY"
# ... add more as needed
```

## 🔍 Verifying Secrets

After adding secrets, verify they're set:

```bash
# List all secrets (names only, values are hidden)
gh secret list
```

## 🏗️ Environment-Specific Secrets

You can use GitHub Environments for different deployment stages:

### Creating Environments

1. Settings → Environments
2. New environment → Name it (e.g., `production`, `staging`, `development`)
3. Add environment-specific secrets
4. Configure protection rules (e.g., require approval for production)

### Environment-Specific Secrets

Add these to each environment:

| Environment | Secret Examples |
|------------|----------------|
| Development | `EC2_HOST_DEV`, `DATABASE_URL_DEV` |
| Staging | `EC2_HOST_STAGING`, `DATABASE_URL_STAGING` |
| Production | `EC2_HOST_PROD`, `DATABASE_URL_PROD` |

## 🛡️ Security Best Practices

1. **Rotate secrets regularly** - Every 90 days minimum
2. **Use least privilege** - Grant minimal required permissions
3. **Never commit secrets** - Use `.gitignore` properly
4. **Audit secret access** - Review GitHub audit logs
5. **Use environments** - Separate dev/staging/prod secrets
6. **Enable 2FA** - On GitHub and all service accounts
7. **Use branch protection** - Require reviews for main branch

## 📝 Secret Rotation Checklist

- [ ] AWS access keys (every 90 days)
- [ ] Database passwords (every 90 days)
- [ ] JWT secrets (every 180 days)
- [ ] SSL certificates (before expiry)
- [ ] API keys (yearly or as required)
- [ ] SSH keys (yearly)

## 🆘 Troubleshooting

### Common Issues

1. **"Bad credentials" error**
   - Verify secret name matches exactly (case-sensitive)
   - Check secret value doesn't have extra spaces/newlines

2. **"Permission denied" for EC2**
   - Verify SSH key format (should include header/footer)
   - Check EC2 security group allows GitHub Actions IPs

3. **Android build fails**
   - Verify keystore base64 encoding is correct
   - Check passwords match exactly

4. **iOS build fails**
   - Ensure certificate hasn't expired
   - Verify provisioning profile matches certificate

## 📚 Additional Resources

- [GitHub Encrypted Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [Google Play Console API](https://developers.google.com/android-publisher)
- [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi)

## 🔄 Quick Setup Script

Save this as `setup-github-secrets.sh`:

```bash
#!/bin/bash

echo "🔐 GitHub Secrets Setup"
echo "======================="

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI not installed. Please install it first."
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "🔑 Please authenticate with GitHub"
    gh auth login
fi

echo "📝 Enter your secrets (press Enter to skip optional ones):"

# AWS Secrets
read -p "AWS_ACCESS_KEY_ID: " aws_key
read -p "AWS_SECRET_ACCESS_KEY: " aws_secret
read -p "AWS_REGION [us-east-1]: " aws_region
aws_region=${aws_region:-us-east-1}

# EC2 Secrets
read -p "EC2_HOST (IP or domain): " ec2_host
read -p "EC2_USER [ubuntu]: " ec2_user
ec2_user=${ec2_user:-ubuntu}
read -p "Path to SSH key file: " ssh_key_path

# Set secrets
echo "🚀 Setting secrets..."

[ ! -z "$aws_key" ] && gh secret set AWS_ACCESS_KEY_ID --body "$aws_key"
[ ! -z "$aws_secret" ] && gh secret set AWS_SECRET_ACCESS_KEY --body "$aws_secret"
[ ! -z "$aws_region" ] && gh secret set AWS_REGION --body "$aws_region"
[ ! -z "$ec2_host" ] && gh secret set EC2_HOST --body "$ec2_host"
[ ! -z "$ec2_user" ] && gh secret set EC2_USER --body "$ec2_user"

if [ -f "$ssh_key_path" ]; then
    gh secret set EC2_SSH_KEY < "$ssh_key_path"
fi

echo "✅ Basic secrets configured!"
echo "📌 Remember to add platform-specific secrets for mobile releases"

# List secrets
echo ""
echo "📋 Current secrets:"
gh secret list
```

Make it executable and run:

```bash
chmod +x setup-github-secrets.sh
./setup-github-secrets.sh
```