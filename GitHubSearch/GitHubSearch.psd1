@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'GitHubSearch.psm1'

    # Version number of this module.
    ModuleVersion = '1.0.0'

    # Supported PSEditions
    CompatiblePSEditions = @('Desktop', 'Core')

    # ID used to uniquely identify this module
    GUID = 'f4c8a5d2-7b3e-4f1a-9e6d-2c8b5a3f7e9d'

    # Author of this module
    Author = 'Bruno Amui'

    # Company or vendor of this module
    CompanyName = 'Personal'

    # Copyright statement for this module
    Copyright = '(c) 2025 Bruno Amui. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'A powerful PowerShell module for searching GitHub code repositories with advanced features including code snippet retrieval, syntax highlighting, and intelligent search patterns.'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Name of the PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # DotNetFrameworkVersion = ''

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # ClrVersion = ''

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    # RequiredModules = @()

    # Assemblies that must be loaded prior to importing this module
    RequiredAssemblies = @('System.Web')

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    # FormatsToProcess = @()

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @('Search-GitHubCode', 'Get-GitHubSearchConfig', 'Set-GitHubSearchConfig', 'Test-GitHubSearchToken')

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @('ghsearch')

    # DSC resources to export from this module
    # DscResourcesToExport = @()

    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    # FileList = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('GitHub', 'Search', 'Code', 'API', 'Development', 'Repository', 'Syntax-Highlighting', 'PowerShell', 'Windows', 'Linux', 'MacOS')

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/brunoamui/GitHubSearch-PowerShell/blob/main/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/brunoamui/GitHubSearch-PowerShell'

            # A URL to an icon representing this module.
            IconUri = 'https://raw.githubusercontent.com/brunoamui/GitHubSearch-PowerShell/main/docs/icon.png'

            # ReleaseNotes of this module
            ReleaseNotes = @'
# Version 1.0.0
- Initial release of GitHubSearch PowerShell module
- Search GitHub code repositories with advanced filtering
- Code snippet retrieval with syntax highlighting
- Enhanced search patterns (function, class, import, variable, api, config)
- Context-aware code display with configurable line counts
- Support for multiple output formats (text, json, yaml)
- Smart file size management and progress indicators
- GitHub CLI integration for seamless authentication
- Cross-platform support (Windows, Linux, macOS)

## Features
- **Code Snippet Retrieval**: Get actual file content with `-ShowContent`
- **Search Patterns**: Language-specific intelligent search patterns
- **Syntax Highlighting**: Color-coded display for popular languages
- **Context Display**: Configurable surrounding lines (1-50)
- **Smart Limits**: File size management (1-1000KB)
- **Progress Tracking**: Real-time download progress
- **Multiple Formats**: Text, JSON, YAML output options
- **Authentication**: GitHub CLI auto-detection + manual token support
'@

            # Prerelease string of this module
            # Prerelease = ''

            # Flag to indicate whether the module requires explicit user acceptance for install/update/save
            # RequireLicenseAcceptance = $false

            # External dependent modules of this module
            # ExternalModuleDependencies = @()
        } # End of PSData hashtable
    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    HelpInfoURI = 'https://github.com/brunoamui/GitHubSearch-PowerShell/blob/main/docs/README.md'

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''
}

