# Private helper functions for GitHubSearch module

function Invoke-GitHubCodeSearch {
    [CmdletBinding()]
    param(
        [string]$Query,
        [int]$NumResults,
        [string]$Language,
        [string]$Repository,
        [string]$User,
        [string]$Sort,
        [string]$Order,
        [string]$Token,
        [string]$SearchPattern
    )
    
    $searchQuery = Build-SearchQuery -Query $Query -Language $Language -Repository $Repository -User $User -SearchPattern $SearchPattern
    $encodedQuery = [System.Web.HttpUtility]::UrlEncode($searchQuery)
    
    $uri = "https://api.github.com/search/code?q=$encodedQuery&sort=$Sort&order=$Order&per_page=$NumResults"
    
    $response = Invoke-GitHubRequest -Uri $uri -Token $Token
    
    if ($response -and $response.items) {
        $results = @()
        foreach ($item in $response.items) {
            $results += @{
                name = $item.name
                path = $item.path
                repository = $item.repository.full_name
                url = $item.html_url
                api_url = $item.url
                score = $item.score
                language = if ($item.repository.language) { $item.repository.language } else { "Unknown" }
                repo_description = $item.repository.description
                repo_stars = $item.repository.stargazers_count
                repo_updated = $item.repository.updated_at
                file_size = if ($item.repository.size) { $item.repository.size } else { 0 }
                owner = $item.repository.owner.login
                repo_name = $item.repository.name
            }
        }
        return @{
            results = $results
            total_count = $response.total_count
            search_query = $searchQuery
        }
    }
    
    return $null
}

function Invoke-GitHubRequest {
    [CmdletBinding()]
    param(
        [string]$Uri,
        [string]$Token
    )
    
    try {
        $headers = @{
            Authorization = "token $Token"
            "User-Agent" = "GitHubSearch-PowerShell/1.0.0"
            Accept = "application/vnd.github.v3+json"
        }
        
        $response = Invoke-RestMethod -Uri $Uri -Headers $headers
        return $response
    }
    catch {
        if ($_.Exception.Response.StatusCode -eq 403) {
            throw "API rate limit exceeded or insufficient permissions. Check your token."
        } elseif ($_.Exception.Response.StatusCode -eq 401) {
            throw "Authentication failed. Check your GitHub token."
        } else {
            throw "GitHub API request failed: $($_.Exception.Message)"
        }
    }
}

function Format-GitHubSearchResults {
    [CmdletBinding()]
    param(
        [object]$SearchResults,
        [string]$Format,
        [bool]$ShowContent,
        [int]$ContextLines,
        [int]$MaxFileSize,
        [string]$Token,
        [string]$SearchQuery
    )
    
    if (-not $SearchResults -or -not $SearchResults.results) {
        Write-Warning "No results found."
        return $null
    }
    
    $results = $SearchResults.results
    $totalCount = $SearchResults.total_count
    
    Write-Host "Found $totalCount total results (showing $($results.Count)):" -ForegroundColor Green
    Write-Host "Search query: $($SearchResults.search_query)" -ForegroundColor DarkGray
    if ($ShowContent) {
        Write-Host "Retrieving code content..." -ForegroundColor Cyan
    }
    Write-Host ""
    
    switch ($Format.ToLower()) {
        "json" {
            if ($ShowContent) {
                # Add content to results
                for ($i = 0; $i -lt $results.Count; $i++) {
                    $result = $results[$i]
                    Write-Progress -Activity "Retrieving content" -Status "File $($i+1) of $($results.Count)" -PercentComplete (($i + 1) / $results.Count * 100)
                    
                    $contentInfo = Get-GitHubFileContent -Owner $result.owner -Repo $result.repo_name -Path $result.path -Token $Token -MaxFileSize $MaxFileSize
                    $result.file_content = $contentInfo.content
                    $result.content_error = $contentInfo.error
                    $result.file_size_kb = $contentInfo.size
                }
                Write-Progress -Activity "Retrieving content" -Completed
            }
            return ($SearchResults | ConvertTo-Json -Depth 6)
        }
        "yaml" {
            # Simple YAML-like output
            $output = @"
total_count: $totalCount
search_query: "$($SearchResults.search_query)"
show_content: $ShowContent
results:
"@
            foreach ($i in 0..($results.Count-1)) {
                $result = $results[$i]
                $output += @"

  - item_$($i+1):
      name: "$($result.name)"
      path: "$($result.path)"
      repository: "$($result.repository)"
      url: "$($result.url)"
      language: "$($result.language)"
      score: $($result.score)
      repo_stars: $($result.repo_stars)
"@
                
                if ($ShowContent) {
                    Write-Progress -Activity "Retrieving content" -Status "File $($i+1) of $($results.Count)" -PercentComplete (($i + 1) / $results.Count * 100)
                    
                    $contentInfo = Get-GitHubFileContent -Owner $result.owner -Repo $result.repo_name -Path $result.path -Token $Token -MaxFileSize $MaxFileSize
                    if ($contentInfo.content) {
                        $output += "`n      content_preview: |"
                        $lines = ($contentInfo.content -split "`n")[0..9]  # First 10 lines for YAML
                        foreach ($line in $lines) {
                            $output += "`n        $line"
                        }
                    } else {
                        $output += "`n      content_error: `"$($contentInfo.error)`""
                    }
                }
            }
            if ($ShowContent) {
                Write-Progress -Activity "Retrieving content" -Completed
            }
            return $output
        }
        default { # text
            for ($i = 0; $i -lt $results.Count; $i++) {
                $result = $results[$i]
                Write-Host "[$($i+1)] " -NoNewline -ForegroundColor Cyan
                Write-Host $result.name -ForegroundColor Green
                Write-Host "    Repository: " -NoNewline -ForegroundColor Gray
                Write-Host $result.repository -ForegroundColor Blue
                Write-Host "    Path: " -NoNewline -ForegroundColor Gray
                Write-Host $result.path -ForegroundColor Yellow
                Write-Host "    Language: " -NoNewline -ForegroundColor Gray
                Write-Host $result.language -ForegroundColor Magenta
                Write-Host "    Stars: " -NoNewline -ForegroundColor Gray
                Write-Host $result.repo_stars -ForegroundColor White
                Write-Host "    Score: " -NoNewline -ForegroundColor Gray
                Write-Host $result.score -ForegroundColor White
                Write-Host "    URL: " -NoNewline -ForegroundColor Gray
                Write-Host $result.url -ForegroundColor Blue
                
                if ($ShowContent) {
                    Write-Host "    Retrieving content..." -ForegroundColor DarkCyan
                    
                    $contentInfo = Get-GitHubFileContent -Owner $result.owner -Repo $result.repo_name -Path $result.path -Token $Token -MaxFileSize $MaxFileSize
                    
                    if ($contentInfo.content) {
                        Write-Host "    File Size: " -NoNewline -ForegroundColor Gray
                        Write-Host "$($contentInfo.size) KB" -ForegroundColor White
                        
                        $snippet = Get-CodeSnippetWithContext -Content $contentInfo.content -SearchQuery $SearchQuery -ContextLines $ContextLines -FileName $result.name
                        
                        if ($snippet) {
                            Write-Host ""
                            Write-Host "    Code Preview (lines $($snippet.startLine)-$($snippet.startLine + $snippet.lines.Count - 1) of $($snippet.totalLines)):" -ForegroundColor DarkCyan
                            Write-Host "    " + ("-" * 80) -ForegroundColor DarkGray
                            
                            for ($lineIndex = 0; $lineIndex -lt $snippet.lines.Count; $lineIndex++) {
                                $line = $snippet.lines[$lineIndex]
                                $actualLineNumber = $snippet.startLine + $lineIndex
                                $isMatchLine = $snippet.matchingLineNumbers -contains $actualLineNumber
                                
                                $highlight = Get-SyntaxHighlightedLine -Line $line -Language $result.language -IsMatchLine $isMatchLine
                                
                                $lineNumberStr = $actualLineNumber.ToString().PadLeft(4)
                                Write-Host "    $lineNumberStr | " -NoNewline -ForegroundColor DarkGray
                                Write-Host "$($highlight.prefix)" -NoNewline -ForegroundColor $highlight.color
                                Write-Host $highlight.line -ForegroundColor $highlight.color
                            }
                            
                            Write-Host "    " + ("-" * 80) -ForegroundColor DarkGray
                            
                            if ($snippet.hasMatches -and $snippet.matchingLineNumbers.Count -gt 0) {
                                Write-Host "    Matches found on lines: " -NoNewline -ForegroundColor DarkCyan
                                Write-Host ($snippet.matchingLineNumbers -join ", ") -ForegroundColor Yellow
                            }
                        }
                    } else {
                        Write-Host "    Content Error: " -NoNewline -ForegroundColor Red
                        Write-Host $contentInfo.error -ForegroundColor DarkRed
                    }
                }
                
                if ($result.repo_description) {
                    Write-Host "    Description: " -NoNewline -ForegroundColor Gray
                    Write-Host $result.repo_description -ForegroundColor DarkGray
                }
                Write-Host ""
            }
            return $null
        }
    }
}

function Get-GitHubFileContent {
    [CmdletBinding()]
    param(
        [string]$Owner,
        [string]$Repo,
        [string]$Path,
        [string]$Token,
        [int]$MaxFileSize
    )
    
    try {
        # First check file size
        $fileInfoUri = "https://api.github.com/repos/$Owner/$Repo/contents/$Path"
        $fileInfo = Invoke-GitHubRequest -Uri $fileInfoUri -Token $Token
        
        if ($fileInfo -and $fileInfo.size) {
            $fileSizeKB = [math]::Round($fileInfo.size / 1024, 2)
            if ($fileSizeKB -gt $MaxFileSize) {
                return @{
                    content = $null
                    error = "File too large ($fileSizeKB KB > $MaxFileSize KB limit)"
                    size = $fileSizeKB
                }
            }
        }
        
        # Get the raw content
        if ($fileInfo -and $fileInfo.download_url) {
            $headers = @{
                "User-Agent" = "GitHubSearch-PowerShell/1.0.0"
            }
            $content = Invoke-RestMethod -Uri $fileInfo.download_url -Headers $headers
            return @{
                content = $content
                error = $null
                size = $fileSizeKB
                encoding = $fileInfo.encoding
            }
        }
        
        return @{
            content = $null
            error = "Unable to retrieve file content"
            size = 0
        }
    }
    catch {
        return @{
            content = $null
            error = "Error retrieving file: $($_.Exception.Message)"
            size = 0
        }
    }
}

function Get-CodeSnippetWithContext {
    [CmdletBinding()]
    param(
        [string]$Content,
        [string]$SearchQuery,
        [int]$ContextLines,
        [string]$FileName
    )
    
    if (-not $Content) {
        return $null
    }
    
    $lines = $Content -split "`n"
    $matchingLines = @()
    
    # Find lines that contain the search terms
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        # Simple search - could be enhanced with regex
        $queryWords = $SearchQuery -split " " | Where-Object { $_ -ne "AND" -and $_ -ne "OR" -and $_ -notlike "language:*" -and $_ -notlike "repo:*" -and $_ -notlike "user:*" }
        
        $hasMatch = $false
        foreach ($word in $queryWords) {
            if ($line -match [regex]::Escape($word)) {
                $hasMatch = $true
                break
            }
        }
        
        if ($hasMatch) {
            $matchingLines += $i
        }
    }
    
    if ($matchingLines.Count -eq 0) {
        # If no specific matches, return first few lines as preview
        $endLine = [math]::Min($ContextLines * 2, $lines.Count - 1)
        return @{
            lines = $lines[0..$endLine]
            startLine = 1
            hasMatches = $false
            totalLines = $lines.Count
        }
    }
    
    # Get context around first match
    $firstMatch = $matchingLines[0]
    $startLine = [math]::Max(0, $firstMatch - $ContextLines)
    $endLine = [math]::Min($lines.Count - 1, $firstMatch + $ContextLines)
    
    return @{
        lines = $lines[$startLine..$endLine]
        startLine = $startLine + 1
        matchLine = $firstMatch + 1
        hasMatches = $true
        totalLines = $lines.Count
        matchingLineNumbers = @($matchingLines | ForEach-Object { $_ + 1 })
    }
}

function Get-SyntaxHighlightedLine {
    [CmdletBinding()]
    param(
        [string]$Line,
        [string]$Language,
        [bool]$IsMatchLine = $false
    )
    
    if ($IsMatchLine) {
        return @{
            prefix = ">>> "
            color = "Yellow"
            line = $Line
        }
    }
    
    # Basic syntax highlighting based on language
    switch ($Language.ToLower()) {
        "python" {
            if ($Line -match "^\s*def\s+|^\s*class\s+") {
                return @{ prefix = ""; color = "Cyan"; line = $Line }
            } elseif ($Line -match "^\s*import\s+|^\s*from\s+") {
                return @{ prefix = ""; color = "Magenta"; line = $Line }
            } elseif ($Line -match "^\s*#") {
                return @{ prefix = ""; color = "DarkGray"; line = $Line }
            }
        }
        "javascript" {
            if ($Line -match "^\s*function\s+|^\s*class\s+|^\s*const\s+|^\s*let\s+|^\s*var\s+") {
                return @{ prefix = ""; color = "Cyan"; line = $Line }
            } elseif ($Line -match "^\s*import\s+|^\s*require\s*\(") {
                return @{ prefix = ""; color = "Magenta"; line = $Line }
            } elseif ($Line -match "^\s*//|^\s*/\*") {
                return @{ prefix = ""; color = "DarkGray"; line = $Line }
            }
        }
        default {
            # Generic highlighting
            if ($Line -match "^\s*#|^\s*//|^\s*/\*") {
                return @{ prefix = ""; color = "DarkGray"; line = $Line }
            }
        }
    }
    
    return @{ prefix = ""; color = "White"; line = $Line }
}

