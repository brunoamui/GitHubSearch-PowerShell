#Requires -Version 5.1

# Get public and private function definition files
$Public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)

# Dot source the files
foreach ($import in @($Public + $Private)) {
    try {
        . $import.FullName
    }
    catch {
        Write-Error -Message "Failed to import function $($import.FullName): $_"
    }
}

# Export public functions
Export-ModuleMember -Function $Public.BaseName

# Create alias for backward compatibility
Set-Alias -Name 'ghsearch' -Value 'Search-GitHubCode'
Export-ModuleMember -Alias 'ghsearch'

# Module variables
$script:ConfigPath = Join-Path $env:USERPROFILE ".ghsearch_config.json"

# Load required assemblies
Add-Type -AssemblyName System.Web

