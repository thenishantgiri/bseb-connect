#!/bin/bash

# Quick setup script for GitHub secrets
# This script helps configure essential secrets for CI/CD

echo "🚀 BSEB Connect - GitHub Secrets Setup"
echo "======================================"
echo ""

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI not installed. Installing..."
    brew install gh
fi

# Check authentication
if ! gh auth status &> /dev/null; then
    echo "🔑 Please authenticate with GitHub"
    gh auth login
fi

echo "📝 Setting up essential secrets for CI/CD..."
echo ""

# Function to set secret if value provided
set_secret() {
    local name=$1
    local value=$2
    if [ ! -z "$value" ]; then
        echo "✓ Setting $name"
        gh secret set "$name" --body "$value"
    else
        echo "⚠️  Skipped $name (no value provided)"
    fi
}

# AWS Configuration
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1️⃣  AWS Configuration (Required for deployment)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "If you don't have AWS credentials yet, you can skip and add later."
echo ""

read -p "AWS Access Key ID (press Enter to skip): " AWS_KEY
read -s -p "AWS Secret Access Key (press Enter to skip): " AWS_SECRET
echo ""
read -p "AWS Region [us-east-1]: " AWS_REGION
AWS_REGION=${AWS_REGION:-us-east-1}

set_secret "AWS_ACCESS_KEY_ID" "$AWS_KEY"
set_secret "AWS_SECRET_ACCESS_KEY" "$AWS_SECRET"
set_secret "AWS_REGION" "$AWS_REGION"

# EC2 Configuration (will be set after deployment)
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2️⃣  EC2 Configuration (Add after running deploy-to-aws.sh)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "These will be available after you deploy your EC2 instance."
echo ""

read -p "EC2 Host/IP (press Enter to skip): " EC2_HOST
read -p "EC2 User [ubuntu]: " EC2_USER
EC2_USER=${EC2_USER:-ubuntu}

if [ ! -z "$EC2_HOST" ]; then
    set_secret "EC2_HOST" "$EC2_HOST"
    set_secret "EC2_USER" "$EC2_USER"

    # SSH Key
    read -p "Path to SSH key file (e.g., backend/deployment/bseb-connect-key.pem): " SSH_KEY_PATH
    if [ -f "$SSH_KEY_PATH" ]; then
        echo "✓ Setting EC2_SSH_KEY from file"
        gh secret set EC2_SSH_KEY < "$SSH_KEY_PATH"
    else
        echo "⚠️  SSH key file not found: $SSH_KEY_PATH"
    fi
fi

# Optional: Slack notifications
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3️⃣  Slack Notifications (Optional)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
read -p "Slack Webhook URL (press Enter to skip): " SLACK_WEBHOOK
set_secret "SLACK_WEBHOOK" "$SLACK_WEBHOOK"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Basic secrets configuration complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Current secrets:"
gh secret list

echo ""
echo "📌 Next Steps:"
echo "1. Run AWS deployment: cd backend/deployment && ./deploy-to-aws.sh"
echo "2. After deployment, run this script again to add EC2 secrets"
echo "3. For mobile releases, add Android/iOS secrets (see .github/GITHUB_SECRETS_SETUP.md)"
echo ""
echo "📚 Documentation: .github/GITHUB_SECRETS_SETUP.md"
echo "🔗 Repository: https://github.com/thenishantgiri/bseb-connect"