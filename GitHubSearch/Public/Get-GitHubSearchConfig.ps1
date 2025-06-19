function Get-GitHubSearchConfig {
    <#
    .SYNOPSIS
        Get the current GitHub search configuration.

    .DESCRIPTION
        Retrieves the current configuration for GitHub search including token information,
        GitHub CLI status, and API availability.

    .PARAMETER ShowDetails
        Show detailed configuration information including token validation.

    .EXAMPLE
        Get-GitHubSearchConfig
        Show basic configuration information.

    .EXAMPLE
        Get-GitHubSearchConfig -ShowDetails
        Show detailed configuration with token validation.

    .OUTPUTS
        PSCustomObject containing configuration information

    .NOTES
        Name: Get-GitHubSearchConfig
        Author: Bruno Amui
        Version: 1.0.0
    #>
    
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter()]
        [switch]$ShowDetails
    )

    try {
        $configPath = Join-Path $env:USERPROFILE ".ghsearch_config.json"
        
        # Load configuration file
        $config = @{}
        if (Test-Path $configPath) {
            try {
                $config = Get-Content $configPath | ConvertFrom-Json -AsHashtable
            }
            catch {
                Write-Warning "Failed to parse config file. Using defaults."
                $config = @{}
            }
        }

        # Check GitHub CLI status
        $ghToken = Get-GitHubCLIToken
        $hasGitHubCLI = [bool]$ghToken
        
        # Determine effective token
        $effectiveToken = $null
        $tokenSource = "None"
        
        if ($config.github_token) {
            $effectiveToken = $config.github_token
            $tokenSource = $config.token_source -or "Manual"
        } elseif ($ghToken) {
            $effectiveToken = $ghToken
            $tokenSource = "GitHub CLI"
        }

        # Create configuration object
        $configInfo = [PSCustomObject]@{
            ConfigFilePath = $configPath
            ConfigFileExists = Test-Path $configPath
            HasConfiguredToken = [bool]$config.github_token
            HasGitHubCLI = $hasGitHubCLI
            HasEffectiveToken = [bool]$effectiveToken
            TokenSource = $tokenSource
            GitHubAPIAvailable = [bool]$effectiveToken
        }

        if ($ShowDetails) {
            Write-Host "GitHub Search Configuration:" -ForegroundColor Green
            Write-Host "Config file: $configPath"
            Write-Host "Config file exists: $($configInfo.ConfigFileExists)" -ForegroundColor $(if ($configInfo.ConfigFileExists) { 'Green' } else { 'Red' })
            
            Write-Host "GitHub CLI: " -NoNewline
            if ($hasGitHubCLI) {
                Write-Host "Available and authenticated" -ForegroundColor Green
                Write-Host "GitHub CLI Token: $($ghToken.Substring(0, 8))..." -ForegroundColor Yellow
            } else {
                Write-Host "Not available or not authenticated" -ForegroundColor Yellow
            }
            
            Write-Host "Configured Token: " -NoNewline
            if ($config.github_token) {
                Write-Host "Yes (Source: $($config.token_source -or 'Manual'))" -ForegroundColor Green
            } else {
                Write-Host "No" -ForegroundColor Red
            }
            
            Write-Host "Effective Token: " -NoNewline
            if ($effectiveToken) {
                Write-Host "Available (Source: $tokenSource)" -ForegroundColor Green
                
                if ($effectiveToken) {
                    Write-Host "Token validation: " -NoNewline
                    if (Test-GitHubSearchToken -Token $effectiveToken) {
                        Write-Host "Valid" -ForegroundColor Green
                    } else {
                        Write-Host "Invalid" -ForegroundColor Red
                    }
                }
            } else {
                Write-Host "None" -ForegroundColor Red
            }
            
            Write-Host "GitHub API Available: " -NoNewline
            if ($configInfo.GitHubAPIAvailable) {
                Write-Host "Yes" -ForegroundColor Green
            } else {
                Write-Host "No" -ForegroundColor Red
                Write-Host "  Run 'Set-GitHubSearchConfig' to configure a token or 'gh auth login' for GitHub CLI." -ForegroundColor Yellow
            }
        }

        return $configInfo
    }
    catch {
        Write-Error "Failed to get GitHub search configuration: $($_.Exception.Message)"
        throw
    }
}

