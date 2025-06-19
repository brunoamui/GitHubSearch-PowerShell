function Test-GitHubSearchToken {
    <#
    .SYNOPSIS
        Test the validity of a GitHub Personal Access Token.

    .DESCRIPTION
        Validates a GitHub Personal Access Token by making a test API call.
        Checks if the token has the necessary permissions for GitHub code search.

    .PARAMETER Token
        GitHub Personal Access Token to test.

    .EXAMPLE
        Test-GitHubSearchToken -Token "ghp_xxxxxxxxxxxxxxxxxxxx"
        Test if the provided token is valid.

    .EXAMPLE
        Test-GitHubSearchToken
        Test the currently configured token.

    .OUTPUTS
        Boolean indicating if the token is valid

    .NOTES
        Name: Test-GitHubSearchToken
        Author: Bruno Amui
        Version: 1.0.0
    #>
    
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string]$Token
    )

    try {
        # If no token provided, get from configuration
        if (-not $Token) {
            $config = Get-GitHubSearchConfig
            if ($config.HasEffectiveToken) {
                if ($config.HasConfiguredToken) {
                    $configData = Get-Content (Join-Path $env:USERPROFILE ".ghsearch_config.json") | ConvertFrom-Json
                    $Token = $configData.github_token
                } else {
                    $Token = Get-GitHubCLIToken
                }
            } else {
                Write-Warning "No token provided and no configured token found."
                return $false
            }
        }

        if (-not $Token) {
            Write-Warning "No token available to test."
            return $false
        }

        # Test token by making API call to user endpoint
        $headers = @{
            Authorization = "token $Token"
            "User-Agent" = "GitHubSearch-PowerShell/1.0.0"
            Accept = "application/vnd.github.v3+json"
        }
        
        $response = Invoke-RestMethod -Uri "https://api.github.com/user" -Headers $headers -ErrorAction Stop
        
        # If we get here, the token is valid
        Write-Verbose "Token validation successful for user: $($response.login)"
        return $true
    }
    catch {
        if ($_.Exception.Response.StatusCode -eq 401) {
            Write-Verbose "Token validation failed: Unauthorized (401)"
            return $false
        } elseif ($_.Exception.Response.StatusCode -eq 403) {
            Write-Verbose "Token validation failed: Forbidden (403) - Check token permissions"
            return $false
        } else {
            Write-Verbose "Token validation failed: $($_.Exception.Message)"
            return $false
        }
    }
}

