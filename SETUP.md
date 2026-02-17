# Repository Setup Guide

This guide explains how to configure your GitHub repository for the automated CI/CD pipeline.

## 🔧 GitHub Repository Settings

### 1. Branch Protection Rules

Go to **Settings → Branches** and add a rule for `main` branch:

#### Required Settings:
- ✅ **Require a pull request before merging**
  - ✅ Require approvals: 1
  - ✅ Dismiss stale pull request approvals when new commits are pushed
  - ✅ Require review from CODEOWNERS (optional)

- ✅ **Require status checks to pass before merging**
  - ✅ Require branches to be up to date before merging
  - Required status checks:
    - `Analyze`
    - `Test`
    - `Build Example App (ubuntu-latest)`
    - `Build Example App (macos-latest)`
    - `Build Example App (windows-latest)`
    - `All Checks Passed`

- ✅ **Require conversation resolution before merging**
- ✅ **Require linear history** (optional, for cleaner git history)
- ✅ **Include administrators** (optional, enforces rules for admins too)

### 2. Repository Secrets

Go to **Settings → Secrets and variables → Actions** and add:

#### Required Secrets for Publishing:

1. **PUB_DEV_ACCESS_TOKEN**
   - Get from `~/.config/dart/pub-credentials.json` after running `flutter pub login`
   - The `accessToken` field

2. **PUB_DEV_REFRESH_TOKEN**
   - Get from `~/.config/dart/pub-credentials.json` after running `flutter pub login`
   - The `refreshToken` field

#### How to Get pub.dev Tokens:

```bash
# 1. Login to pub.dev
flutter pub login

# 2. Follow the OAuth flow in your browser

# 3. Get the tokens (macOS/Linux)
cat ~/.config/dart/pub-credentials.json

# 3. Get the tokens (Windows)
type %APPDATA%\dart\pub-credentials.json
```

### 3. GitHub Actions Permissions

Go to **Settings → Actions → General**:

- **Actions permissions**: Allow all actions and reusable workflows
- **Workflow permissions**: 
  - ✅ Read and write permissions
  - ✅ Allow GitHub Actions to create and approve pull requests

### 4. Labels Setup

Create these labels in **Issues → Labels**:

**Size Labels:**
- `size/XS` - color: #009900
- `size/S` - color: #77bb00
- `size/M` - color: #eebb00
- `size/L` - color: #ee9900
- `size/XL` - color: #ee5500

**Category Labels:**
- `documentation` - color: #0075ca
- `example` - color: #d73a4a
- `test` - color: #0e8a16
- `ci` - color: #000000
- `material` - color: #1976d2
- `cupertino` - color: #007aff
- `core` - color: #5319e7
- `dependencies` - color: #0366d6

**Status Labels:**
- `ready for review` - color: #0e8a16
- `needs changes` - color: #e11d21
- `blocked` - color: #b60205

### 5. GitHub Pages (Optional)

If you want to host documentation:

1. Go to **Settings → Pages**
2. Source: Deploy from a branch
3. Branch: `gh-pages` / `docs` folder
4. Enforce HTTPS: ✅

## 🚀 Workflow Overview

### Pull Request Flow

1. **Developer creates PR** → triggers:
   - CI checks (format, analyze, test, build)
   - PR title validation
   - Auto-labeling
   - Size labeling
   - Version and changelog checks

2. **Review process**:
   - Requires 1 approval
   - All CI checks must pass
   - Conversations must be resolved

3. **Merge to main**:
   - Squash and merge recommended
   - Delete branch after merge

### Release Flow

1. **Manual Release** (Recommended):
   ```bash
   cd /path/to/flutter_declarative_popups
   ./scripts/release.sh minor  # or major/patch
   ```

2. **Auto-publish triggers when**:
   - A tag matching `flutter_declarative_popups-v*.*.*` is pushed
   - GitHub Actions will:
     - Run all tests
     - Publish to pub.dev
     - Create GitHub release
     - Upload artifacts

### Alternative: Manual Tag Creation

```bash
# After merging PR to main
git checkout main
git pull origin main

# Create and push tag
git tag flutter_declarative_popups-v0.3.1
git push origin flutter_declarative_popups-v0.3.1
```

## 📊 Monitoring

### Check CI/CD Status

1. **Actions Tab**: Monitor workflow runs
2. **Pull Requests**: Check status checks
3. **Releases**: Verify GitHub releases
4. **pub.dev**: Confirm package publication

### Troubleshooting

**CI Failing?**
- Check Actions tab for detailed logs
- Ensure all tests pass locally
- Verify code formatting: `dart format .`

**Publish Failing?**
- Verify pub.dev tokens are correct
- Check `flutter pub publish --dry-run` locally
- Ensure version is bumped

**PR Checks Stuck?**
- Try pushing an empty commit: `git commit --allow-empty -m "Trigger CI"`
- Check if base branch is up to date

## 🔐 Security Best Practices

1. **Never commit tokens** to the repository
2. **Rotate tokens periodically** (every 6 months)
3. **Use branch protection** to prevent direct pushes to main
4. **Review dependencies** in pull requests
5. **Enable Dependabot** for security updates

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [pub.dev Publishing Guide](https://dart.dev/tools/pub/publishing)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)
