# GitHubSearch PowerShell Module - Basic Usage Examples

# Import the module
Import-Module ..\GitHubSearch\GitHubSearch.psd1

# Example 1: Basic search without content
Write-Host "Example 1: Basic search for 'hello world' in Python files" -ForegroundColor Green
Search-GitHubCode "hello world" -Language python -NumResults 3

Write-Host "`n" + "="*80 + "`n"

# Example 2: Enhanced search with code content
Write-Host "Example 2: Search with code content retrieval" -ForegroundColor Green
Search-GitHubCode "authentication" -Language python -NumResults 2 -ShowContent

Write-Host "`n" + "="*80 + "`n"

# Example 3: Pattern-based search
Write-Host "Example 3: Function pattern search" -ForegroundColor Green
Search-GitHubCode -SearchPattern function -Query "authenticate" -Language python -NumResults 2 -ShowContent

Write-Host "`n" + "="*80 + "`n"

# Example 4: Repository-specific search
Write-Host "Example 4: Search in specific repository" -ForegroundColor Green
Search-GitHubCode -Repository "microsoft/vscode" -SearchPattern class -Query "Editor" -NumResults 1 -ShowContent

Write-Host "`n" + "="*80 + "`n"

# Example 5: Using alias with JSON output
Write-Host "Example 5: Using alias with JSON output" -ForegroundColor Green
$results = ghsearch "jwt token" -Language javascript -NumResults 1 -ShowContent -Format json
Write-Host "JSON output length: $($results.Length) characters"

