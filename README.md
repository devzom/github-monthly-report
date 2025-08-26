# Monthly work report generator based on GitHub PR diffs

Comprehensive tool for generating monthly tax deductible reports based on GitHub pull requests.
Automatically downloads diff files and creates organized summaries for tax reporting purposes.

## Setups

- GitHub CLI (`gh`) installed and authenticated
- `jq` command-line JSON processor
- Bash shell (macOS/Linux) or Git Bash/WSL (Windows)

### Installing GitHub CLI

**macOS (Homebrew):**
```bash
brew install gh
```

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install gh
```

**Windows:**
```powershell
# Using winget (Windows 10 1709+)
winget install --id GitHub.cli

# Using Chocolatey
choco install gh

# Using Scoop
scoop install gh
```

**Other platforms:** Visit https://cli.github.com/ for installation instructions

### Installing jq

**macOS (Homebrew):**
```bash
brew install jq
```

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install jq
```

**Windows:**
```powershell
# Using winget
winget install stedolan.jq

# Using Chocolatey
choco install jq

# Using Scoop
scoop install jq
```

### Authentication

**Initial GitHub CLI auth:**

```bash
# Authenticate with GitHub
gh auth login
```

Follow the interactive prompts to:
1. Choose GitHub.com
2. Select HTTPS or SSH protocol
3. Authenticate via web browser or personal access token
4. Choose your preferred git protocol

**Verify auth:**
```bash
# Check authentication status
gh auth status

# Test API access
gh api user
```

**Required permissions:**
The authenticated user needs:
- Read access to repositories in the target organization
- Ability to view pull requests and their diffs

### Script Setup

**Make script executable (macOS/Linux):**
```bash
chmod +x generate_monthly_report.sh
```

**Windows Setup:**
For Windows users, you have several options:

1. **Git Bash** (Recommended):
   - Install Git for Windows (includes Git Bash)
   - Open Git Bash terminal
   - Navigate to script directory and run as shown in usage examples

2. **Windows Subsystem for Linux (WSL)**:
   - Install WSL2 with Ubuntu
   - Install dependencies within WSL environment
   - Run script from WSL terminal

3. **PowerShell with Git Bash**:
   ```powershell
   # Run from PowerShell
   bash ./generate_monthly_report.sh
   ```

**Configure organization (optional):**
Edit the script to change the target organization:
```bash
# Open script in editor
nano generate_monthly_report.sh

# Modify this line:
repositoryOwner="your-org-name"
```

## Usage

**macOS/Linux:**
```bash
# Generate report for current month
./generate_monthly_report.sh

# Generate report for specific month (YYYY-MM format)
./generate_monthly_report.sh 2025-07

# Generate report for custom date range
./generate_monthly_report.sh 2025-07-01 2025-07-31
```

**Windows (Git Bash):**
```bash
# Generate report for current month
./generate_monthly_report.sh

# Generate report for specific month (YYYY-MM format)
./generate_monthly_report.sh 2025-07

# Generate report for custom date range
./generate_monthly_report.sh 2025-07-01 2025-07-31
```

**Windows (PowerShell):**
```powershell
# Generate report for current month
bash ./generate_monthly_report.sh

# Generate report for specific month (YYYY-MM format)
bash ./generate_monthly_report.sh 2025-07

# Generate report for custom date range
bash ./generate_monthly_report.sh 2025-07-01 2025-07-31
```

### Output

The script generates:

1. **Console Report**: Detailed PR information with repository, title, PR number, close date, diff URL, and PR URL
2. **Summary by Repository**: Count of PRs per repository
3. **Diff File Downloads**: Individual diff files saved locally in organized directory structure
4. **Summary File**: Master list linking PR titles to their corresponding diff files

### Example Output

```
Generating report for period: 2025-07-01 to 2025-07-31
======================================================
Fetching merged pull requests...
Found 8 merged pull requests

PR DIFFS FOR TAX DEDUCTIBLE REPORT
==================================

Repository: your-org-name/repositoryExample
Title: prefix-168: Fix export and release o pkg
PR Number: #218
Closed At: 2025-04-29T11:25:40Z
Diff URL: https://github.com/your-org-name/repositoryExample/pull/218.diff
PR URL: https://github.com/your-org-name/repositoryExample/pull/218
------------------------------------------------------------

SUMMARY BY REPOSITORY
====================
6 PRs: your-org-name/repositoryExample
1 PRs: your-org-name/repositoryExample2
1 PRs: your-org-name/repositoryExample3

DIFF URLS
================================
https://github.com/your-org-name/repositoryExample/pull/218.diff
...

GENERATING DIFFs
===============================================
 ✓✓✓ Generated: diffs/2025-07-01_2025-07-31/repositoryExample-217.......txt
...

 ✓✓✓ Generated summary: diffs/2025-07-01_2025-07-31/summary.txt
```

## Features

- **Smart date handling**: Automatically detects month boundaries and handles edge cases
- **Comprehensive PR search**: Fetches merged PRs for specified date ranges from configured organization
- **Local diffs storage**: Downloads actual diff files and stores them in organized directory structure
- **File organization**: Creates time-stamped directories (`YYYY-MM-DD_YYYY-MM-DD`) for easy archiving
- **Summary generation**: Creates master summary file linking PR titles to their diff files
- **Multiple outputs**: Console report, individual diff files, and summary file
- **Error handling**: Gracefully handles missing PRs, network issues, and invalid dates
- **Filename sanitization**: Cleans PR titles for safe filesystem usage

## Structure

The script creates the following directory structure:

```
diffs/
└── YYYY-MM-DD_YYYY-MM-DD/
    ├── summary.txt
    ├── repo-name-123-PR_Title_Sanitized.txt
    ├── repo-name-124-Another_PR_Title.txt
    └── ...
```

- **summary.txt**: Master file with format `[PR Title]-[filename]` for each diff
- **Individual diffs files**: Named as `{repo-short-name}-{pr-number}-{sanitized-title}.txt`

## GitHub CLI Commands Used

The script uses these GitHub CLI commands internally:
```bash
# Search for merged PRs
gh search prs --author=@me --owner="your-org-name" --merged --created="YYYY-MM-DD..YYYY-MM-DD" --json title,repository,url,closedAt,number

# Download individual diff files
gh pr diff "PR_NUMBER" --repo "REPO_NAME"
```

## Configuration

The script need to configure organization / repo owner.
To use with a different organization, modify the `repositoryOwner` variable at the top of the script.
