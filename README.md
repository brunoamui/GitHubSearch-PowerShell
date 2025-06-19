# GitHubSearch PowerShell Module

## Overview

GitHubSearch is a powerful PowerShell module that allows you to search GitHub code repositories with advanced features. It includes capabilities for code snippet retrieval, syntax highlighting, intelligent search patterns, and more.

## Features
- **Code Snippet Retrieval**: Retrieve actual file content with syntax highlighting
- **Search Patterns**: Use enhanced patterns like function, class, import, etc.
- **Multiple Output Formats**: Supports text, JSON, and YAML
- **Context-aware Display**: Configurable lines around code matches
- **GitHub CLI Integration**: Seamless authentication

## Installation

To install the module, clone the repository and import it into your PowerShell session:

```sh
git clone https://github.com/brunoamui/GitHubSearch-PowerShell.git
cd GitHubSearch-PowerShell
Import-Module .\GitHubSearch\GitHubSearch.psd1
```

## Configuration

Configure your GitHub Personal Access Token using the interactive setup:

```sh
Set-GitHubSearchConfig -Interactive
```

Or set it directly:

```sh
Set-GitHubSearchConfig -Token "YOUR_GITHUB_TOKEN"
```

## Usage

Search GitHub with advanced options:

```sh
# Basic search with content retrieval
Search-GitHubCode "function auth" -Language python -ShowContent

# Use patterns for specific searches
Search-GitHubCode -SearchPattern function -Query "authenticate" -ShowContent

# Specify output format
Search-GitHubCode "jwt token" -ShowContent -Format json
```

## Examples

```sh
# Extended context and repository-specific search
Search-GitHubCode -Repository "microsoft/vscode" -SearchPattern class -Query "Editor" -ShowContent -ContextLines 15
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request.

## Issues

Please submit any issues to the project GitHub [issue tracker](https://github.com/brunoamui/GitHubSearch-PowerShell/issues).

---

For more detailed help with any command, use PowerShell's `Get-Help`:

```sh
Get-Help Search-GitHubCode -Full
```

