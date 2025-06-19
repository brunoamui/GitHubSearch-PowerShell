function Search-GitHubCode {
    <#
    .SYNOPSIS
        Search GitHub code repositories with advanced features including code snippet retrieval and intelligent patterns.

    .DESCRIPTION
        A powerful function for searching GitHub code repositories using the GitHub API. Supports advanced features like:
        - Code snippet retrieval with syntax highlighting
        - Enhanced search patterns (function, class, import, variable, api, config)
        - Context-aware code display with configurable surrounding lines
        - Multiple output formats (text, json, yaml)
        - Smart file size management and progress indicators
        - GitHub CLI integration for seamless authentication

    .PARAMETER Query
        The search query string (required).

    .PARAMETER Format
        Output format: text, json, yaml (default: text).

    .PARAMETER NumResults
        Number of results to return (1-100, default: 10).

    .PARAMETER Language
        Filter by programming language (e.g., python, javascript, etc.).

    .PARAMETER Repository
        Filter by specific repository (format: owner/repo).

    .PARAMETER User
        Filter by user or organization.

    .PARAMETER Sort
        Sort results by: indexed, score (default: score).

    .PARAMETER Order
        Sort order: asc, desc (default: desc).

    .PARAMETER ShowContent
        Retrieve and display actual code content for each result.

    .PARAMETER ContextLines
        Number of context lines to show around matches (1-50, default: 5).

    .PARAMETER MaxFileSize
        Maximum file size in KB to retrieve content for (1-1000, default: 100).

    .PARAMETER SearchPattern
        Enhanced search patterns: function, class, import, variable, api, config.

    .EXAMPLE
        Search-GitHubCode "function auth"
        Basic search for files containing "function auth".

    .EXAMPLE
        Search-GitHubCode "authentication" -Language python -ShowContent
        Search for authentication in Python files with code content retrieval.

    .EXAMPLE
        Search-GitHubCode -SearchPattern function -Query "authenticate" -Language python -ShowContent
        Search for Python functions containing "authenticate" with code snippets.

    .EXAMPLE
        Search-GitHubCode -Repository "microsoft/vscode" -SearchPattern class -Query "Editor" -ShowContent
        Search for Editor classes in the VS Code repository with code content.

    .EXAMPLE
        Search-GitHubCode "jwt token" -ShowContent -ContextLines 15 -MaxFileSize 500
        Search with extended context and large file support.

    .INPUTS
        String

    .OUTPUTS
        PSCustomObject or JSON/YAML formatted string depending on Format parameter

    .NOTES
        Name: Search-GitHubCode
        Author: Bruno Amui
        Version: 1.0.0
        Requires: PowerShell 5.1+, GitHub Personal Access Token

    .LINK
        https://github.com/brunoamui/GitHubSearch-PowerShell
    #>
    
    [CmdletBinding(DefaultParameterSetName = 'Basic')]
    [OutputType([PSCustomObject], ParameterSetName = 'Basic')]
    [OutputType([String], ParameterSetName = 'JSON')]
    [OutputType([String], ParameterSetName = 'YAML')]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Query,
        
        [Parameter()]
        [ValidateSet("text", "json", "yaml")]
        [string]$Format = "text",
        
        [Parameter()]
        [Alias("n")]
        [ValidateRange(1, 100)]
        [int]$NumResults = 10,
        
        [Parameter()]
        [Alias("l")]
        [ValidateNotNullOrEmpty()]
        [string]$Language,
        
        [Parameter()]
        [Alias("r")]
        [ValidatePattern('^[a-zA-Z0-9\-_\.]+/[a-zA-Z0-9\-_\.]+$')]
        [string]$Repository,
        
        [Parameter()]
        [Alias("u")]
        [ValidateNotNullOrEmpty()]
        [string]$User,
        
        [Parameter()]
        [ValidateSet("indexed", "score")]
        [string]$Sort = "score",
        
        [Parameter()]
        [ValidateSet("asc", "desc")]
        [string]$Order = "desc",
        
        [Parameter()]
        [Alias("c")]
        [switch]$ShowContent,
        
        [Parameter()]
        [ValidateRange(1, 50)]
        [int]$ContextLines = 5,
        
        [Parameter()]
        [ValidateRange(1, 1000)]
        [int]$MaxFileSize = 100,
        
        [Parameter()]
        [ValidateSet("function", "class", "import", "variable", "api", "config")]
        [string]$SearchPattern
    )

    begin {
        Write-Verbose "Starting GitHub code search with query: '$Query'"
        
        # Load configuration
        $configData = Get-GitHubSearchConfig
        
        # Get GitHub token (auto-detect GitHub CLI or use configured token)
        $token = $null
        if (-not $configData.github_token) {
            $ghToken = Get-GitHubCLIToken
            if ($ghToken) {
                Write-Verbose "Auto-detected GitHub CLI token"
                $token = $ghToken
            } else {
                throw "GitHub token not configured. Use Set-GitHubSearchConfig to configure your token or authenticate with 'gh auth login'."
            }
        } else {
            $token = $configData.github_token
        }

        # Validate token
        if (-not (Test-GitHubSearchToken -Token $token)) {
            throw "GitHub token validation failed. Please check your token and try again."
        }
    }

    process {
        try {
            # Build search query with patterns
            $searchQuery = Build-SearchQuery -Query $Query -Language $Language -Repository $Repository -User $User -SearchPattern $SearchPattern
            Write-Verbose "Built search query: '$searchQuery'"

            # Perform the search
            Write-Host "Searching GitHub for: $Query" -ForegroundColor Yellow
            if ($SearchPattern) { Write-Host "Pattern: $SearchPattern" -ForegroundColor Yellow }
            if ($Language) { Write-Host "Language: $Language" -ForegroundColor Yellow }
            if ($Repository) { Write-Host "Repository: $Repository" -ForegroundColor Yellow }
            if ($User) { Write-Host "User: $User" -ForegroundColor Yellow }
            if ($ShowContent) { 
                Write-Host "Code content retrieval: Enabled" -ForegroundColor Cyan 
                Write-Host "Context lines: $ContextLines" -ForegroundColor Cyan
                Write-Host "Max file size: $MaxFileSize KB" -ForegroundColor Cyan
            }
            Write-Host ""

            $searchResults = Invoke-GitHubCodeSearch -Query $Query -NumResults $NumResults -Language $Language -Repository $Repository -User $User -Sort $Sort -Order $Order -Token $token -SearchPattern $SearchPattern

            if (-not $searchResults) {
                Write-Warning "No results found for query: '$Query'"
                return
            }

            # Format and display results
            $output = Format-GitHubSearchResults -SearchResults $searchResults -Format $Format -ShowContent $ShowContent -ContextLines $ContextLines -MaxFileSize $MaxFileSize -Token $token -SearchQuery $Query

            return $output
        }
        catch {
            Write-Error "GitHub search failed: $($_.Exception.Message)"
            throw
        }
    }

    end {
        Write-Verbose "GitHub code search completed"
    }
}

