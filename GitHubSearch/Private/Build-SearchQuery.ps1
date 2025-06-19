function Build-SearchQuery {
    <#
    .SYNOPSIS
        Build GitHub search query with enhanced patterns.

    .DESCRIPTION
        Constructs a GitHub code search query with language-specific patterns
        and filtering options.

    .PARAMETER Query
        Base search query.

    .PARAMETER Language
        Programming language filter.

    .PARAMETER Repository
        Repository filter (owner/repo format).

    .PARAMETER User
        User or organization filter.

    .PARAMETER SearchPattern
        Enhanced search pattern (function, class, import, variable, api, config).

    .OUTPUTS
        String containing the constructed search query

    .NOTES
        This is a private helper function for the GitHubSearch module.
    #>
    
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Query,
        
        [Parameter()]
        [string]$Language,
        
        [Parameter()]
        [string]$Repository,
        
        [Parameter()]
        [string]$User,
        
        [Parameter()]
        [string]$SearchPattern
    )

    $searchTerms = @()
    
    # Apply search patterns
    if ($SearchPattern) {
        switch ($SearchPattern.ToLower()) {
            "function" {
                if ($Language) {
                    switch ($Language.ToLower()) {
                        "python" { $searchTerms += "def $Query" }
                        "javascript" { $searchTerms += "function $Query" }
                        "typescript" { $searchTerms += "function $Query" }
                        "java" { $searchTerms += "public $Query" }
                        "csharp" { $searchTerms += "public $Query" }
                        "go" { $searchTerms += "func $Query" }
                        "rust" { $searchTerms += "fn $Query" }
                        "php" { $searchTerms += "function $Query" }
                        "ruby" { $searchTerms += "def $Query" }
                        default { $searchTerms += "function $Query" }
                    }
                } else {
                    $searchTerms += "function $Query"
                }
            }
            "class" {
                if ($Language) {
                    switch ($Language.ToLower()) {
                        "python" { $searchTerms += "class $Query" }
                        "javascript" { $searchTerms += "class $Query" }
                        "typescript" { $searchTerms += "class $Query" }
                        "java" { $searchTerms += "class $Query" }
                        "csharp" { $searchTerms += "class $Query" }
                        "php" { $searchTerms += "class $Query" }
                        "ruby" { $searchTerms += "class $Query" }
                        default { $searchTerms += "class $Query" }
                    }
                } else {
                    $searchTerms += "class $Query"
                }
            }
            "import" {
                if ($Language) {
                    switch ($Language.ToLower()) {
                        "python" { $searchTerms += "import $Query OR from $Query" }
                        "javascript" { $searchTerms += "import $Query OR require($Query)" }
                        "typescript" { $searchTerms += "import $Query" }
                        "java" { $searchTerms += "import $Query" }
                        "go" { $searchTerms += "import $Query" }
                        default { $searchTerms += "import $Query" }
                    }
                } else {
                    $searchTerms += "import $Query"
                }
            }
            "variable" {
                if ($Language) {
                    switch ($Language.ToLower()) {
                        "python" { $searchTerms += "$Query =" }
                        "javascript" { $searchTerms += "var $Query OR let $Query OR const $Query" }
                        "typescript" { $searchTerms += "let $Query OR const $Query" }
                        default { $searchTerms += "$Query =" }
                    }
                } else {
                    $searchTerms += "$Query ="
                }
            }
            "api" {
                $searchTerms += "$Query api"
            }
            "config" {
                $searchTerms += "$Query config"
            }
        }
    } else {
        $searchTerms += $Query
    }
    
    if ($Language) {
        $searchTerms += "language:$Language"
    }
    
    if ($Repository) {
        $searchTerms += "repo:$Repository"
    }
    
    if ($User) {
        $searchTerms += "user:$User"
    }
    
    return ($searchTerms -join " ")
}

