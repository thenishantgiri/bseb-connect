# 🚀 CI/CD Pipeline Documentation

## Overview

This project uses GitHub Actions for a complete CI/CD pipeline that handles:
- ✅ Automated testing (Flutter & Backend)
- 🏗️ Build validation
- 🚢 Deployment to AWS EC2
- 📱 Mobile app releases (Android & iOS)
- 🔄 Dependency updates
- 🔐 Security scanning

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     GitHub Repository                    │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │   Push   │→ │   Build  │→ │   Test   │             │
│  └──────────┘  └──────────┘  └──────────┘             │
│                                    ↓                    │
│                            ┌──────────────┐            │
│                            │   Deploy     │            │
│                            └──────────────┘            │
└─────────────────────────────────────────────────────────┘
                                    ↓
        ┌────────────────────────────────────────┐
        │                Deployment               │
        ├──────────────┬─────────────┬──────────┤
        │   AWS EC2    │  Play Store │ App Store│
        │   Backend    │   Android   │    iOS   │
        └──────────────┴─────────────┴──────────┘
```

## 📋 Workflows

### 1. Main CI/CD Pipeline (`main-cicd.yml`)

**Triggers:**
- Push to `main`, `develop`, `staging` branches
- Pull requests to these branches
- Manual trigger with environment selection

**Jobs:**
1. **Backend Tests** - Runs unit and integration tests
2. **Backend Build** - Builds NestJS application
3. **Flutter Tests** - Runs Flutter tests and analysis
4. **Flutter Build** - Builds for Android, iOS, and Web
5. **Deploy Backend** - Deploys to AWS EC2
6. **Deploy Flutter Web** - Deploys to S3/CloudFront

### 2. Pull Request Checks (`pr-checks.yml`)

**Triggers:**
- All pull requests

**Checks:**
- 🔍 Code quality analysis
- 🔐 Security scanning (secrets, vulnerabilities)
- 📊 Test coverage reporting
- 🏗️ Build validation
- 📦 Dependency review
- 🏷️ Auto-labeling

### 3. Mobile Release (`mobile-release.yml`)

**Triggers:**
- Manual workflow dispatch

**Features:**
- 📱 Android release to Google Play Store
- 🍎 iOS release to App Store Connect
- 🏷️ Automatic versioning
- 📝 GitHub release creation
- 📢 Slack notifications

## 🚀 Getting Started

### Step 1: Initialize Git Repository

```bash
git init
git add .
git commit -m "Initial commit"
```

### Step 2: Create GitHub Repository

```bash
# Using GitHub CLI
gh repo create bseb-connect --public --source=. --remote=origin --push

# Or manually
git remote add origin https://github.com/YOUR_USERNAME/bseb-connect.git
git branch -M main
git push -u origin main
```

### Step 3: Set Up GitHub Secrets

Follow the guide in [.github/GITHUB_SECRETS_SETUP.md](.github/GITHUB_SECRETS_SETUP.md)

Essential secrets to start:
```bash
# AWS Deployment
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION
EC2_HOST
EC2_USER
EC2_SSH_KEY
```

### Step 4: Deploy Backend to AWS

```bash
# First, deploy your EC2 instance
cd backend/deployment
./deploy-to-aws.sh

# Note the EC2 public IP and add it to GitHub secrets
gh secret set EC2_HOST --body "YOUR_EC2_IP"
```

### Step 5: Test the Pipeline

```bash
# Create a feature branch
git checkout -b feature/test-pipeline

# Make a small change
echo "# Test" >> README.md

# Commit and push
git add README.md
git commit -m "test: CI/CD pipeline"
git push origin feature/test-pipeline

# Create a pull request
gh pr create --title "Test CI/CD Pipeline" --body "Testing the pipeline"
```

## 📦 Deployment Environments

### Development
- **Branch:** `develop`
- **Auto-deploy:** Yes
- **URL:** `http://dev-api.bsebconnect.in`

### Staging
- **Branch:** `staging`
- **Auto-deploy:** Yes
- **Approval:** Not required
- **URL:** `http://staging-api.bsebconnect.in`

### Production
- **Branch:** `main`
- **Auto-deploy:** Yes
- **Approval:** Required (set up in GitHub environments)
- **URL:** `https://api.bsebconnect.in`

## 🔄 Workflow Scenarios

### Scenario 1: Feature Development

```bash
# 1. Create feature branch
git checkout -b feature/new-feature

# 2. Make changes and commit
git add .
git commit -m "feat: add new feature"

# 3. Push to GitHub
git push origin feature/new-feature

# 4. Create PR
gh pr create

# PR checks will run automatically
# After approval and merge, deployment happens
```

### Scenario 2: Hotfix

```bash
# 1. Create hotfix branch from main
git checkout main
git checkout -b hotfix/critical-fix

# 2. Make fix and push
git add .
git commit -m "fix: critical issue"
git push origin hotfix/critical-fix

# 3. Create PR to main
gh pr create --base main

# After merge, auto-deploys to production
```

### Scenario 3: Mobile Release

1. Go to Actions tab in GitHub
2. Select "Mobile App Release" workflow
3. Click "Run workflow"
4. Enter version (e.g., "1.2.0")
5. Add release notes
6. Select platform (android/ios/both)
7. Run and monitor

## 🛠️ Local Testing

### Test GitHub Actions Locally

Install [act](https://github.com/nektos/act):

```bash
# macOS
brew install act

# Ubuntu
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
```

Run workflows locally:

```bash
# Test main workflow
act push -W .github/workflows/main-cicd.yml

# Test PR checks
act pull_request -W .github/workflows/pr-checks.yml
```

### Pre-commit Hooks

Set up pre-commit hooks for local validation:

```bash
# Create pre-commit hook
cat > .git/hooks/pre-commit <<'EOF'
#!/bin/bash

# Run Flutter tests
flutter test

# Run Flutter analyzer
flutter analyze

# Check formatting
dart format --set-exit-if-changed .

# Run backend tests
cd backend && npm test
EOF

chmod +x .git/hooks/pre-commit
```

## 📊 Monitoring

### GitHub Actions Dashboard

Monitor your workflows:
1. Go to repository → Actions tab
2. View workflow runs
3. Click on a run for detailed logs
4. Download artifacts if needed

### Deployment Status

Check deployment status:

```bash
# Check backend health
curl http://YOUR_EC2_IP:3000/health

# Check PM2 status
ssh -i bseb-connect-key.pem ubuntu@YOUR_EC2_IP 'pm2 status'

# View logs
ssh -i bseb-connect-key.pem ubuntu@YOUR_EC2_IP 'pm2 logs'
```

## 🔧 Troubleshooting

### Common Issues

#### 1. Workflow Fails with "Bad credentials"

```bash
# Verify secrets are set
gh secret list

# Re-set the secret
gh secret set SECRET_NAME --body "value"
```

#### 2. EC2 Deployment Fails

```bash
# Check SSH connectivity
ssh -i bseb-connect-key.pem ubuntu@EC2_IP

# Check if PM2 is running
pm2 status

# Check nginx
sudo systemctl status nginx
```

#### 3. Mobile Build Fails

```yaml
# Check keystore/certificate expiry
# Verify version numbers are correct
# Ensure all secrets are properly base64 encoded
```

## 🔐 Security

### Branch Protection

Set up branch protection for `main`:

```bash
# Using GitHub CLI
gh api repos/:owner/:repo/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["build"]}' \
  --field enforce_admins=false \
  --field required_pull_request_reviews='{"required_approving_review_count":1}'
```

### Secret Scanning

GitHub automatically scans for exposed secrets. Additional scanning in PR checks.

### Dependency Scanning

Dependabot configured for:
- Weekly updates
- Security patches
- Grouped updates for related packages

## 📈 Best Practices

1. **Commit Messages**
   ```
   feat: new feature
   fix: bug fix
   docs: documentation
   test: testing
   chore: maintenance
   ```

2. **Branch Naming**
   ```
   feature/description
   bugfix/description
   hotfix/description
   release/version
   ```

3. **PR Guidelines**
   - Write descriptive PR titles
   - Include issue numbers
   - Add screenshots for UI changes
   - Request reviews

4. **Version Tagging**
   ```bash
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin v1.0.0
   ```

## 🔄 Maintenance

### Weekly Tasks
- Review Dependabot PRs
- Check for security alerts
- Monitor deployment metrics

### Monthly Tasks
- Review and rotate secrets
- Update dependencies
- Performance analysis

### Quarterly Tasks
- Review CI/CD pipeline efficiency
- Update documentation
- Security audit

## 📚 Resources

- [GitHub Actions Documentation](https://docs.github.com/actions)
- [AWS EC2 Guide](https://docs.aws.amazon.com/ec2/)
- [Flutter CI/CD](https://docs.flutter.dev/deployment/cd)
- [NestJS Deployment](https://docs.nestjs.com/deployment/docker)

## 🆘 Support

For issues or questions:
1. Check [Troubleshooting](#-troubleshooting)
2. Review workflow logs
3. Create an issue with:
   - Workflow run link
   - Error messages
   - Steps to reproduce

## 🎯 Quick Commands

```bash
# View recent workflow runs
gh run list

# Watch a workflow run
gh run watch

# Re-run failed workflow
gh run rerun [run-id]

# Download workflow artifacts
gh run download [run-id]

# View workflow logs
gh run view [run-id] --log

# Cancel a workflow run
gh run cancel [run-id]
```

---

**Last Updated:** November 2024
**Maintained By:** BSEB Connect Team