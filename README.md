# Monthly work report generator based on GitHub PR diffs

Comprehensive tool for generating monthly tax deductible reports based on GitHub pull requests.
Automatically downloads diff files and creates organized summaries for tax reporting purposes.
By default it produces `.txt` files, but can be configured to generate `.pdf` files as well.

Supports flexible organization targeting - either specify the organization as a parameter or set a default in the script.

## Setups

- Bash shell (macOS/Linux) or Git Bash/WSL (Windows)
- _GitHub CLI_ `gh` installed and authenticated
- `jq` command-line JSON processor

### Installing GitHub CLI

<details>
<summary>More details</summary>

**macOS (Homebrew):**
```bash
brew install gh
```

**Ubuntu/Debian:**
```bash
sudo apt update && apt install gh
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

</details>


### Installing jq

<details>
<summary>More details</summary>

**macOS (Homebrew):**

```bash
brew install jq
```

**Ubuntu/Debian:**
```bash
sudo apt update && apt install jq
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

</details>

### Authentication

**Initial GitHub CLI auth:**

```bash
# Authenticate with GitHub
gh auth login
```

Follow prompts to:
1. Choose GitHub.com
2. Select HTTPS or SSH protocol
3. Authenticate via web browser or personal access token
4. Choose your preferred git protocol

**Required permissions:**
The authenticated user needs:
- Read access to repositories in the target organization
- Ability to view pull requests and their diffs

### Script Setup
<details>
<summary>More details</summary>

**Make script executable (macOS/Linux):**
```bash
chmod +x generate-report.sh
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
   bash ./generate-report.sh
   ```
   
</details>

## Organization Configuration

You have two options for specifying the target GitHub organization:

### Option 1: Pass as Parameter (Recommended)
Simply provide the organization name as the first parameter when running the script:

```bash
./generate-report.sh my-org-name
```

### Option 2: Edit Default in Script
Alternatively, you can set a default organization by editing the script:

```bash
# Modify this line in generate-report.sh:
repositoryOwner="your-org-name"
```

> [!TIP]
> Using the parameter approach (Option 1) is more flexible as it allows you to work with different organizations without modifying the script.

#### PDF Generation (Optional)

To generate diff files as PDF documents, you need to install the following dependencies via Homebrew:

```bash
brew install enscript ghostscript
```

## Usage

### With Organization Parameter (Recommended)

**macOS/Linux/Windows (Git Bash):**
```bash
# Generate report for current month with specific organization
./generate-report.sh my-org-name

# Generate report for specific month with organization
./generate-report.sh my-org-name 2025-07

# Generate report for custom date range with organization
./generate-report.sh my-org-name 2025-07-01 2025-07-31
```

**Windows (PowerShell):**
```powershell
# Generate report for current month with specific organization
bash ./generate-report.sh my-org-name

# Generate report for specific month with organization
bash ./generate-report.sh my-org-name 2025-07

# Generate report for custom date range with organization
bash ./generate-report.sh my-org-name 2025-07-01 2025-07-31
```

### Using Default Organization

**macOS/Linux/Windows (Git Bash):**
```bash
# Generate report for current month (uses default org from script)
./generate-report.sh

# Generate report for specific month (uses default org)
./generate-report.sh 2025-07

# Generate report for custom date range (uses default org)
./generate-report.sh 2025-07-01 2025-07-31
```

**Windows (PowerShell):**
```powershell
# Generate report for current month (uses default org from script)
bash ./generate-report.sh

# Generate report for specific month (uses default org)
bash ./generate-report.sh 2025-07

# Generate report for custom date range (uses default org)
bash ./generate-report.sh 2025-07-01 2025-07-31
```

### Output

1. **Console log**: Detailed PR information with repository, title, PR number, close date, diff URL, and PR URL
2. **Summary by repository**: Count of PRs per repository
3. **Diff file downloads**: Individual diff files saved locally in organized directory structure
4. **Summary file**: Master list linking PR titles to their corresponding diff files

### Example output

<details>

<summary>More details</summary>

```
    Generating report for period: 2025-07-01 to 2025-07-31
    ======================================================
    Fetching merged pull requests...
    Found 8 merged pull requests
    
    PR DIFFS FOR TAX DEDUCTIBLE REPORT
    ==================================
    
    Repository: your-org-name/repositoryExample
    Title: prefix-168: Fix export and release o pkg
    PR number: #218
    Closed at: 2025-04-29T11:25:40Z
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

</details>

## Features

- **Organization targeting**: Pass organization name as parameter or use default from script
- **Smart date from/to handling**: Automatically detects month boundaries and handles edge cases
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
