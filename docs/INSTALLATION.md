# GitHubSearch PowerShell Module - Installation Guide

## Prerequisites

- **PowerShell 5.1 or later** (Windows PowerShell or PowerShell Core)
- **GitHub Personal Access Token** with `public_repo` scope
- **Optional**: GitHub CLI for automatic token detection

## Installation Methods

### Method 1: Clone from GitHub (Recommended)

1. **Clone the repository**:
   ```powershell
   git clone https://github.com/brunoamui/GitHubSearch-PowerShell.git
   cd GitHubSearch-PowerShell
   ```

2. **Import the module**:
   ```powershell
   Import-Module .\GitHubSearch\GitHubSearch.psd1
   ```

3. **Verify installation**:
   ```powershell
   Get-Module GitHubSearch
   ```

### Method 2: PowerShell Gallery (Future)

*Note: This module will be published to PowerShell Gallery in the future.*

```powershell
# Future installation method
Install-Module -Name GitHubSearch
```

### Method 3: Manual Installation

1. **Download the module**:
   - Download the latest release from GitHub
   - Extract to a folder named `GitHubSearch`

2. **Copy to PowerShell modules directory**:
   ```powershell
   # For current user
   $UserModulesPath = [Environment]::GetFolderPath("MyDocuments") + "\WindowsPowerShell\Modules"
   Copy-Item -Path ".\GitHubSearch" -Destination "$UserModulesPath\" -Recurse
   
   # For all users (requires admin)
   $SystemModulesPath = "$env:ProgramFiles\WindowsPowerShell\Modules"
   Copy-Item -Path ".\GitHubSearch" -Destination "$SystemModulesPath\" -Recurse
   ```

3. **Import the module**:
   ```powershell
   Import-Module GitHubSearch
   ```

## Configuration

### Option 1: Interactive Setup (Recommended)

Run the interactive configuration wizard:

```powershell
Set-GitHubSearchConfig -Interactive
```

This will:
- Check for GitHub CLI authentication
- Prompt for manual token if needed
- Validate the token
- Save configuration securely

### Option 2: GitHub CLI Integration

If you have GitHub CLI installed and authenticated:

```powershell
# First authenticate with GitHub CLI
gh auth login

# Use GitHub CLI token
Set-GitHubSearchConfig -UseGitHubCLI
```

### Option 3: Manual Token Configuration

```powershell
# Set token directly
Set-GitHubSearchConfig -Token "ghp_xxxxxxxxxxxxxxxxxxxx"
```

## Getting GitHub Personal Access Token

1. **Go to GitHub Settings**: https://github.com/settings/tokens
2. **Click "Generate new token (classic)"**
3. **Configure the token**:
   - **Note**: `GitHubSearch PowerShell Module`
   - **Expiration**: Choose appropriate expiration
   - **Scopes**: Select `public_repo`
4. **Generate and copy the token**
5. **Use in configuration**:
   ```powershell
   Set-GitHubSearchConfig -Token "YOUR_TOKEN_HERE"
   ```

## Verification

### Test Installation

```powershell
# Check module is loaded
Get-Module GitHubSearch

# Check available commands
Get-Command -Module GitHubSearch

# Test configuration
Get-GitHubSearchConfig -ShowDetails

# Test token
Test-GitHubSearchToken
```

### Basic Test Search

```powershell
# Simple search test
Search-GitHubCode "hello world" -Language python -NumResults 3

# Test with alias
ghsearch "function auth" -NumResults 2
```

## Troubleshooting

### Module Not Found

```powershell
# Check if module path is correct
$env:PSModulePath -split ';'

# Import with full path
Import-Module "C:\Path\To\GitHubSearch\GitHubSearch.psd1"
```

### Token Issues

```powershell
# Test token validity
Test-GitHubSearchToken -Token "YOUR_TOKEN"

# Check configuration
Get-GitHubSearchConfig -ShowDetails

# Reconfigure if needed
Set-GitHubSearchConfig -Interactive -Force
```

### PowerShell Execution Policy

If you encounter execution policy errors:

```powershell
# Check current policy
Get-ExecutionPolicy

# Set policy for current user (recommended)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or bypass for current session
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```

## Updating

### From Git Repository

```powershell
# Pull latest changes
git pull origin main

# Re-import module
Import-Module .\GitHubSearch\GitHubSearch.psd1 -Force
```

### Manual Update

1. Download the latest release
2. Replace the existing module files
3. Re-import the module:
   ```powershell
   Import-Module GitHubSearch -Force
   ```

## Uninstallation

### Remove Module

```powershell
# Remove from current session
Remove-Module GitHubSearch

# Delete configuration (optional)
Remove-Item "$env:USERPROFILE\.ghsearch_config.json" -ErrorAction SilentlyContinue

# Remove module files
# Delete from PowerShell modules directory if installed there
```

## System Requirements

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| PowerShell | 5.1 | 7.0+ |
| .NET Framework | 4.6.1 | 4.8 |
| Memory | 256 MB | 512 MB |
| Disk Space | 5 MB | 10 MB |
| Network | Internet access for GitHub API | Stable broadband |

## Next Steps

After successful installation:

1. **Read the documentation**: `Get-Help Search-GitHubCode -Full`
2. **Try examples**: Run scripts in the `examples` folder
3. **Explore features**: Test different search patterns and options
4. **Join the community**: Report issues and contribute on GitHub

---

For more help, see the [README](../README.md) or visit the [GitHub repository](https://github.com/brunoamui/GitHubSearch-PowerShell).

