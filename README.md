# Monthly GitHub PR Report Generator

Semi-automated tool for generating monthly tax deductible reports based on GitHub pull requests.

## Prerequisites

- GitHub CLI (`gh`) installed and authenticated
- `jq` command-line JSON processor

## Usage

### Basic Usage

```bash
# Generate report for current month
./generate_monthly_report.sh

# Generate report for specific month (YYYY-MM format)
./generate_monthly_report.sh 2024-07

# Generate report for custom date range
./generate_monthly_report.sh 2024-07-01 2024-07-31
```

### Output

The script generates:

1. **Detailed PR Information**: Repository, title, PR number, close date, diff URL, and PR URL
2. **Summary by Repository**: Count of PRs per repository
3. **Diff URLs Only**: Clean list of diff URLs for easy copying

### Example Output

```
Generating report for period: 2024-07-01 to 2024-07-31
======================================================
Fetching merged pull requests...
Found 15 merged pull requests

PR DIFFS FOR TAX DEDUCTIBLE REPORT
==================================

Repository: your_org/**
Title: ***
PR Number: #4156
Closed At: 2024-07-31T09:58:43Z
Diff URL: url.diff
PR URL: ...4156
------------------------------------------------------------

SUMMARY BY REPOSITORY
====================
13 PRs in your_org/someRepo

DIFF URLS ONLY
================================
https://github.com/your_org/someRepo/pull/4156.diff
https://github.com/your_org/someRepo/pull/4149.diff
...
```

## Features

- Automatically detects month boundaries
- Fetches up to 100 merged PRs per month
- Generates diff URLs by appending `.diff` to PR URLs
- Provides multiple output formats for different use cases
- Handles edge cases (no PRs found, invalid dates)

## GitHub CLI Command Used

The script uses this GitHub CLI command internally:
```bash
gh search prs --author=@me --merged --created=YYYY-MM-DD..YYYY-MM-DD --json title,repository,url,closedAt,number --limit 100
```

## Notes

- Only merged pull requests are included
- The script searches for PRs authored by the current GitHub user (`@me`)
- Diff URLs provide the actual code changes in unified diff format
- Perfect for tax deductible reporting requirements based on actual code contributions
