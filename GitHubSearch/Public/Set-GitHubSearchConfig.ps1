function Set-GitHubSearchConfig {
    <#
    .SYNOPSIS
        Configure GitHub search settings including authentication token.

    .DESCRIPTION
        Sets up the GitHub search configuration including GitHub Personal Access Token.
        Supports both interactive setup and programmatic configuration.

    .PARAMETER Token
        GitHub Personal Access Token with 'public_repo' scope.

    .PARAMETER Interactive
        Run interactive setup wizard.

    .PARAMETER UseGitHubCLI
        Use the current GitHub CLI token if available.

    .PARAMETER Force
        Overwrite existing configuration without confirmation.

    .EXAMPLE
        Set-GitHubSearchConfig -Interactive
        Run the interactive setup wizard.

    .EXAMPLE
        Set-GitHubSearchConfig -Token "ghp_xxxxxxxxxxxxxxxxxxxx"
        Set the GitHub token directly.

    .EXAMPLE
        Set-GitHubSearchConfig -UseGitHubCLI
        Use the current GitHub CLI token.

    .OUTPUTS
        None

    .NOTES
        Name: Set-GitHubSearchConfig
        Author: Bruno Amui
        Version: 1.0.0
    #>
    
    [CmdletBinding(DefaultParameterSetName = 'Interactive')]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Token')]
        [ValidatePattern('^gh[ps]_[A-Za-z0-9_]{36}$')]
        [string]$Token,

        [Parameter(ParameterSetName = 'Interactive')]
        [switch]$Interactive,

        [Parameter(ParameterSetName = 'GitHubCLI')]
        [switch]$UseGitHubCLI,

        [Parameter()]
        [switch]$Force
    )

    try {
        $configPath = Join-Path $env:USERPROFILE ".ghsearch_config.json"
        
        # Check if configuration exists and warn user
        if ((Test-Path $configPath) -and -not $Force) {
            $existingConfig = Get-GitHubSearchConfig
            if ($existingConfig.HasConfiguredToken) {
                $overwrite = Read-Host "Configuration already exists. Overwrite? (y/N)"
                if ($overwrite -ne 'y' -and $overwrite -ne 'Y') {
                    Write-Host "Configuration unchanged." -ForegroundColor Yellow
                    return
                }
            }
        }

        switch ($PSCmdlet.ParameterSetName) {
            'Token' {
                Write-Host "Setting GitHub token..." -ForegroundColor Green
                
                # Validate token
                if (-not (Test-GitHubSearchToken -Token $Token)) {
                    throw "Invalid GitHub token. Please check your token has 'public_repo' scope."
                }

                $config = @{
                    github_token = $Token
                    token_source = "Manual"
                    configured_at = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
                }

                $config | ConvertTo-Json | Set-Content $configPath
                Write-Host "GitHub token configured successfully!" -ForegroundColor Green
            }

            'GitHubCLI' {
                Write-Host "Using GitHub CLI token..." -ForegroundColor Green
                
                $ghToken = Get-GitHubCLIToken
                if (-not $ghToken) {
                    throw "GitHub CLI not available or not authenticated. Run 'gh auth login' first."
                }

                # Validate token
                if (-not (Test-GitHubSearchToken -Token $ghToken)) {
                    throw "GitHub CLI token validation failed."
                }

                $config = @{
                    github_token = $ghToken
                    token_source = "GitHub CLI"
                    configured_at = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
                }

                $config | ConvertTo-Json | Set-Content $configPath
                Write-Host "GitHub CLI token configured successfully!" -ForegroundColor Green
            }

            'Interactive' {
                Write-Host "GitHub Search Configuration Setup" -ForegroundColor Green
                Write-Host ""
                
                # Check if GitHub CLI is available
                $ghToken = Get-GitHubCLIToken
                if ($ghToken) {
                    Write-Host "GitHub CLI detected and authenticated!" -ForegroundColor Green
                    Write-Host "Token: $($ghToken.Substring(0, 8))..." -ForegroundColor Yellow
                    Write-Host ""
                    $useGhToken = Read-Host "Use GitHub CLI token? (Y/n)"
                    
                    if ($useGhToken -eq "" -or $useGhToken -eq "Y" -or $useGhToken -eq "y") {
                        # Validate token
                        if (Test-GitHubSearchToken -Token $ghToken) {
                            $config = @{
                                github_token = $ghToken
                                token_source = "GitHub CLI"
                                configured_at = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
                            }
                            $config | ConvertTo-Json | Set-Content $configPath
                            Write-Host "GitHub CLI token configured successfully!" -ForegroundColor Green
                            return
                        } else {
                            Write-Warning "GitHub CLI token validation failed. Falling back to manual setup."
                        }
                    }
                }
                
                # Manual token setup
                Write-Host "Manual Token Setup" -ForegroundColor Cyan
                Write-Host "You'll need a GitHub Personal Access Token with 'public_repo' scope."
                Write-Host "Get one at: https://github.com/settings/tokens"
                Write-Host ""
                
                $manualToken = Read-Host "Enter your GitHub Personal Access Token (or press Enter to skip)" -AsSecureString
                
                if ($manualToken.Length -gt 0) {
                    $plaintextToken = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($manualToken))
                    
                    # Validate token
                    if (Test-GitHubSearchToken -Token $plaintextToken) {
                        $config = @{
                            github_token = $plaintextToken
                            token_source = "Manual"
                            configured_at = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
                        }
                        $config | ConvertTo-Json | Set-Content $configPath
                        Write-Host "GitHub token configured successfully!" -ForegroundColor Green
                    } else {
                        throw "Token validation failed. Please check your token has 'public_repo' scope."
                    }
                } else {
                    Write-Host "No token provided. Configuration unchanged." -ForegroundColor Yellow
                }
            }
        }
    }
    catch {
        Write-Error "Failed to configure GitHub search: $($_.Exception.Message)"
        throw
    }
}

