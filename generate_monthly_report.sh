#!/bin/bash

# Usage: ./generate_monthly_report.sh [YYYY-MM] or ./generate_monthly_report.sh [start_date] [end_date]
repositoryOwner="your-org-name"

generate_pr_report() {
    local pr_data, total_prs

    pr_data=$1

    # Count total PRs
    total_prs=$(echo "$pr_data" | jq 'length')
    echo "Found $total_prs merged pull requests"
    echo ""

    echo "PR DIFFS FOR TAX DEDUCTIBLE REPORT"
    echo "=================================="
    echo ""

    # Parse and output PR details with diff URLs
    echo "$pr_data" | jq -r '.[] |
    "Repository: " + .repository.nameWithOwner +
    "\nTitle: " + .title +
    "\nPR Number: #" + (.number | tostring) +
    "\nClosed At: " + .closedAt +
    "\nDiff URL: " + .url + ".diff" +
    "\nPR URL: " + .url +
    "\n" + ("-" * 60) + "\n"'

    echo ""
    echo "SUMMARY BY REPOSITORY"
    echo "===================="
    echo "$pr_data" | jq -r 'group_by(.repository.nameWithOwner) | .[] |
    "\(length) PRs: " + .[0].repository.nameWithOwner'
}

get_month_range() {
    local month;
    local year;
    local year_month;
    local start_date;
    local end_date;

    year_month=$1;
    year=$(echo "$year_month" | cut -d'-' -f1);
    month=$(echo "$year_month" | cut -d'-' -f2);

    # First day of month
    start_date="${year}-${month}-01"

    if [[ $? -eq 0 ]];
     then
        local next_year;
        local next_month;

        # Get last day of the month
        if [[ "$month" == "12" ]];
            then
                next_year=$((year + 1))
                next_month="01"
        else
            next_year=$year
            next_month=$(printf "%02d" $((10#$month + 1)))
        fi

        end_date=$(date -j -v-1d -f "%Y-%m-%d" "${next_year}-${next_month}-01" "+%Y-%m-%d")
    else
        # Fallback for different date command
        end_date="${year}-${month}-31"
    fi

    echo "$start_date $end_date"
}

check_pdf_dependencies() {
    local missing_deps=()

    if ! command -v enscript &> /dev/null; then
        missing_deps+=("enscript")
    fi

    if ! command -v ps2pdf &> /dev/null; then
        missing_deps+=("ghostscript")
    fi

    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo "❌ Missing required dependencies for PDF generation:"
        for dep in "${missing_deps[@]}"; do
            echo "   - $dep"
        done
        echo ""
        echo "Install with: brew install ${missing_deps[*]}"
        echo "Falling back to .txt file generation..."
        return 1
    fi

    return 0
}

generate_diff_files() {
    local pr_data=$1
    local start_date=$2
    local end_date=$3
    local use_pdf=false

    # Check if PDF dependencies are available
    if check_pdf_dependencies; then
        use_pdf=true
        echo "✅ PDF dependencies found. Generating PDF files..."
    fi

    echo ""
    echo "DIFF URLS"
    echo "================================"
    echo "$pr_data" | jq -r '.[].url + ".diff"'

    echo ""
    echo "GENERATING DIFFs"
    echo "==============================================="

    # Create time range directory
    local time_range="${start_date}_${end_date}"
    mkdir -p "diffs/$time_range"

    # Generation summary file
    local summary_file="diffs/$time_range/summary.txt"
    echo "# Summary for $start_date to $end_date" > "$summary_file"

    # Scope repositories & generate diff files
    local org_prs
    org_prs=$(echo "$pr_data" | jq -r '.[]')

    if [[ -n "$org_prs" && "$org_prs" != "null" ]]; then
        echo "$org_prs" | jq -r '"\(.repository.nameWithOwner)|\(.number)|\(.title)"' | while IFS='|' read -r repo_name pr_number pr_title; do

            # Clean up title for filename (remove special characters)
            clean_title=$(echo "$pr_title" | sed 's/[^a-zA-Z0-9 -]//g' | sed 's/ /_/g' | cut -c1-50)
            repo_short=$(echo "$repo_name" | cut -d'/' -f2)
            filename="${repo_short}-${pr_number}-${clean_title}"

            if [[ "$use_pdf" == true ]]; then
                _filename="$filename.pdf"
                temp_file="/tmp/$filename.txt"

                # Get diff content and convert to PDF
                gh pr diff "$pr_number" --repo "$repo_name" > "$temp_file" 2>/dev/null

                if [[ $? -eq 0 ]]; then
                    # Convert text to PDF using enscript and ps2pdf
                    enscript "$temp_file" -o - 2>/dev/null | ps2pdf - "diffs/$time_range/$_filename" 2>/dev/null

                    if [[ $? -eq 0 ]]; then
                        echo " ✓✓✓ Generated: diffs/$time_range/$_filename"
                        echo "[$pr_title]-[$_filename]" >> "$summary_file"
                    else
                        echo " ✗✗✗✗✗✗✗✗✗ Failed to convert diff to PDF for PR #$pr_number"
                    fi

                    # Clean up temp file
                    rm -f "$temp_file"
                else
                    echo " ✗✗✗✗✗✗✗✗✗ Failed to generate diff for PR #$pr_number"
                fi
            else
                _filename="$filename.txt"
                gh pr diff "$pr_number" --repo "$repo_name" > "diffs/$time_range/$_filename" 2>/dev/null

                if [[ $? -eq 0 ]]; then
                    echo " ✓✓✓ Generated: diffs/$time_range/$_filename"
                    echo "[$pr_title]-[$_filename]" >> "$summary_file"
                else
                    echo " ✗✗✗✗✗✗✗✗✗ Failed to generate diff for PR #$pr_number"
                fi
            fi
        done
    else
        echo "No repositories found."
    fi

    # Display summary file creation
    if [[ -f "$summary_file" ]]; then
        echo ""
        echo " ✓✓✓ Generated summary: $summary_file"
    fi
}
    # Use `current month` by default
if [[ $# -eq 0 ]];
then
    current_month=$(date "+%Y-%m")
    range=$(get_month_range "$current_month")
    start_date=$(echo "$range" | cut -d' ' -f1)
    end_date=$(echo "$range" | cut -d' ' -f2)

    # Use date range from arguments
elif [[ $# -eq 1 ]];
    then
        # YYYY-MM format
        range=$(get_month_range "$1")
        start_date=$(echo "$range" | cut -d' ' -f1)
        end_date=$(echo "$range" | cut -d' ' -f2)

elif [[ $# -eq 2 ]];
    then
        start_date=$1
        end_date=$2

else
    echo "Usage: $0 [YYYY-MM] or $0 [start_date] [end_date]"
    echo "-------------------------------------------------"
    echo "Example: $0 2025-07" # Current month
    echo "Example: $0 2025-07-01 2025-07-31"
    exit 1
fi

echo "Generating report for period: $start_date to $end_date"
echo "======================================================"

echo "Fetching merged pull requests..."
pr_data=$(gh search prs --author=@me --owner="$repositoryOwner" --merged --created="$start_date..$end_date" --json title,repository,url,closedAt,number)

if [[ -z "$pr_data" || "$pr_data" == "[]" ]];
    then
        echo "No merged pull requests found for the specified date range."
        exit 0
fi

generate_pr_report "$pr_data"

generate_diff_files "$pr_data" "$start_date" "$end_date"
