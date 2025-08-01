#!/bin/bash

# Usage: ./generate_monthly_report.sh [YYYY-MM] or ./generate_monthly_report.sh [start_date] [end_date]

# Function to get first and last day of a month
get_month_range() {
    local year_month=$1
    local year=$(echo $year_month | cut -d'-' -f1)
    local month=$(echo $year_month | cut -d'-' -f2)

    # First day of month
    local start_date="${year}-${month}-01"

    # Last day of month
    local last_day=$(date -j -f "%Y-%m-%d" "${year}-${month}-01" "+%Y-%m-%d" 2>/dev/null)

    if [[ $? -eq 0 ]]; then
        # Get last day of the month
        if [[ "$month" == "12" ]]; then
            local next_year=$((year + 1))
            local next_month="01"
        else
            local next_year=$year
            local next_month=$(printf "%02d" $((10#$month + 1)))
        fi

        local end_date=$(date -j -v-1d -f "%Y-%m-%d" "${next_year}-${next_month}-01" "+%Y-%m-%d")
    else
        # Fallback for different date command
        local end_date="${year}-${month}-31"
    fi

    echo "$start_date $end_date"
}

# Parse command line arguments
if [[ $# -eq 0 ]]; then
    # Default to current month
    current_month=$(date "+%Y-%m")
    range=$(get_month_range $current_month)
    start_date=$(echo $range | cut -d' ' -f1)
    end_date=$(echo $range | cut -d' ' -f2)
elif [[ $# -eq 1 ]]; then
    # Single argument: YYYY-MM format
    range=$(get_month_range $1)
    start_date=$(echo $range | cut -d' ' -f1)
    end_date=$(echo $range | cut -d' ' -f2)
elif [[ $# -eq 2 ]]; then
    # Two arguments: start_date end_date
    start_date=$1
    end_date=$2
else
    echo "Usage: $0 [YYYY-MM] or $0 [start_date] [end_date]"
    echo "Example: $0 2025-07"
    echo "Example: $0 2025-07-01 2025-07-31"
    exit 1
fi

echo "Generating report for period: $start_date to $end_date"
echo "======================================================"

# Fetch merged PRs using GitHub CLI
echo "Fetching merged pull requests..."
pr_data=$(gh search prs --author=@me --merged --created=2025-07-01..2025-07-31 --json title,repository,url,closedAt,number --limit 100)
# pr_data=$(gh search prs --author=@me --merged --created="$start_date..$end_date" --json title,repository,url,closedAt,number --limit 100)

# Check if we got any data
if [[ -z "$pr_data" || "$pr_data" == "[]" ]]; then
    echo "No merged pull requests found for the specified period."
    exit 0
fi

# Count total PRs
total_prs=$(echo "$pr_data" | jq 'length')
echo "Found $total_prs merged pull requests"
echo ""

# Generate report
echo "PR DIFFS FOR TAX DEDUCTIBLE REPORT"
echo "=================================="
echo ""

# Parse and output PR details with diff URLs
echo "$pr_data" | jq -r '.[] |
"Repository: " + .repository.nameWithOwner +
"\nTitle: " + .title +
"\nPR Number: (.number | tostring) +
"\nClosed At: " + .closedAt +
"\nDiff URL: " + .url + ".diff" +
"\nPR URL: " + .url +
"\n" + ("-" * 60) + "\n"'

# Generate summary by repository
echo ""
echo "SUMMARY BY REPOSITORY"
echo "===================="
echo "$pr_data" | jq -r 'group_by(.repository.nameWithOwner) | .[] |
"\(length) PRs in " + .[0].repository.nameWithOwner'

echo ""
echo "DIFF URLS ONLY"
echo "================================"
echo "$pr_data" | jq -r '.[].url + ".diff"'
