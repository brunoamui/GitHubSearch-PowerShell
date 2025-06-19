function Get-GitHubCLIToken {
    <#
    .SYNOPSIS
        Get the current GitHub CLI authentication token.

    .DESCRIPTION
        Attempts to retrieve the current GitHub CLI authentication token if available.

    .OUTPUTS
        String containing the GitHub CLI token, or null if not available

    .NOTES
        This is a private helper function for the GitHubSearch module.
    #>
    
    [CmdletBinding()]
    [OutputType([string])]
    param()

    try {
        $ghToken = gh auth token 2>$null
        if ($LASTEXITCODE -eq 0 -and $ghToken) {
            return $ghToken.Trim()
        }
    }
    catch {
        # gh command not available or not authenticated
        Write-Verbose "GitHub CLI not available or not authenticated"
    }
    return $null
}

