#!/bin/bash

# PM Sync - Full bidirectional sync between local and GitHub
set -e

# Configuration
EPICS_DIR=".claude/epics"
UPDATES_DIR=".claude/context/updates"
GITHUB_REPO=$(gh repo view --json owner,name --jq '.owner.login + "/" + .name' 2>/dev/null || echo "unknown/repo")

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
PULLED_UPDATED=0
PULLED_CLOSED=0
PUSHED_UPDATED=0
PUSHED_CREATED=0
CONFLICTS_RESOLVED=0
SYNC_FAILURES=()

echo -e "${BLUE}🔄 Starting bidirectional sync with GitHub...${NC}"
echo

# Check if gh CLI is available and authenticated
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI (gh) not found. Please install it first.${NC}"
    exit 1
fi

if ! gh auth status &> /dev/null; then
    echo -e "${RED}❌ Not authenticated with GitHub. Run 'gh auth login' first.${NC}"
    exit 1
fi

# Function to parse frontmatter
parse_frontmatter() {
    local file="$1"
    local key="$2"
    
    if [ ! -f "$file" ]; then
        return 1
    fi
    
    # Extract frontmatter between --- lines
    sed -n '1,/^---$/p' "$file" | grep "^${key}:" | head -1 | sed "s/^${key}: *//"
}

# Function to update frontmatter
update_frontmatter() {
    local file="$1"
    local key="$2"
    local value="$3"
    
    if [ ! -f "$file" ]; then
        return 1
    fi
    
    # Create temp file
    local temp_file=$(mktemp)
    
    # Check if key exists
    if grep -q "^${key}:" "$file"; then
        # Update existing key
        sed "s/^${key}: .*/${key}: ${value}/" "$file" > "$temp_file"
    else
        # Add new key after the first --- line
        awk -v key="$key" -v value="$value" '
        BEGIN { added = 0 }
        /^---$/ && NR == 1 { print; next }
        /^---$/ && NR > 1 && !added { 
            print key ": " value
            print
            added = 1
            next 
        }
        { print }
        ' "$file" > "$temp_file"
    fi
    
    mv "$temp_file" "$file"
}

# Function to get GitHub issue by number
get_github_issue() {
    local issue_number="$1"
    gh issue view "$issue_number" --json number,title,state,body,labels,updatedAt 2>/dev/null || echo ""
}

# Function to extract issue number from GitHub URL
extract_issue_number() {
    local github_url="$1"
    echo "$github_url" | grep -o '[0-9]*$' || echo ""
}

# Function to compare timestamps (returns 0 if first is newer, 1 if second is newer)
is_newer() {
    local timestamp1="$1"
    local timestamp2="$2"
    
    # Convert to seconds since epoch for comparison
    local ts1=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$timestamp1" "+%s" 2>/dev/null || echo "0")
    local ts2=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$timestamp2" "+%s" 2>/dev/null || echo "0")
    
    [ "$ts1" -gt "$ts2" ]
}

echo -e "${YELLOW}📥 Step 1: Pulling updates from GitHub...${NC}"

# Get all epic and task issues from GitHub
echo "Fetching GitHub issues..."
GITHUB_EPICS=$(gh issue list --label "epic" --limit 1000 --json number,title,state,body,labels,updatedAt 2>/dev/null || echo "[]")
GITHUB_TASKS=$(gh issue list --label "task" --limit 1000 --json number,title,state,body,labels,updatedAt 2>/dev/null || echo "[]")

echo "Found $(echo "$GITHUB_EPICS" | jq length) epics and $(echo "$GITHUB_TASKS" | jq length) tasks on GitHub"

# Process GitHub epics
echo "$GITHUB_EPICS" | jq -c '.[]' | while read -r issue; do
    issue_number=$(echo "$issue" | jq -r '.number')
    issue_title=$(echo "$issue" | jq -r '.title')
    issue_state=$(echo "$issue" | jq -r '.state')
    updated_at=$(echo "$issue" | jq -r '.updatedAt')
    
    # Find local epic file by issue number
    local_file=$(find "$EPICS_DIR" -name "*.md" -exec grep -l "github.*${issue_number}$" {} \; 2>/dev/null | head -1)
    
    if [ -n "$local_file" ]; then
        local_updated=$(parse_frontmatter "$local_file" "updated")
        local_state=$(parse_frontmatter "$local_file" "status")
        
        # Compare timestamps and states
        if [ -n "$local_updated" ] && is_newer "$updated_at" "$local_updated"; then
            echo "  Updating local epic: $issue_title"
            
            # Update status if different
            github_status="open"
            [ "$issue_state" = "closed" ] && github_status="completed"
            
            if [ "$local_state" != "$github_status" ]; then
                update_frontmatter "$local_file" "status" "$github_status"
            fi
            
            update_frontmatter "$local_file" "updated" "$updated_at"
            update_frontmatter "$local_file" "last_sync" "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
            
            PULLED_UPDATED=$((PULLED_UPDATED + 1))
        fi
    fi
done

# Process GitHub tasks
echo "$GITHUB_TASKS" | jq -c '.[]' | while read -r issue; do
    issue_number=$(echo "$issue" | jq -r '.number')
    issue_title=$(echo "$issue" | jq -r '.title')
    issue_state=$(echo "$issue" | jq -r '.state')
    updated_at=$(echo "$issue" | jq -r '.updatedAt')
    
    # Find local task file by issue number
    local_file=$(find "$EPICS_DIR" -name "*.md" -path "*/tasks/*" -exec grep -l "github.*${issue_number}$" {} \; 2>/dev/null | head -1)
    
    if [ -n "$local_file" ]; then
        local_updated=$(parse_frontmatter "$local_file" "updated")
        local_status=$(parse_frontmatter "$local_file" "status")
        
        # Compare timestamps and states
        if [ -n "$local_updated" ] && is_newer "$updated_at" "$local_updated"; then
            echo "  Updating local task: $issue_title"
            
            # Update status if different
            github_status="todo"
            case "$issue_state" in
                "closed") github_status="completed" ;;
                "open") 
                    # Check if it's in progress based on labels
                    if echo "$issue" | jq -r '.labels[].name' | grep -q "in progress"; then
                        github_status="in_progress"
                    else
                        github_status="todo"
                    fi
                    ;;
            esac
            
            if [ "$local_status" != "$github_status" ]; then
                update_frontmatter "$local_file" "status" "$github_status"
            fi
            
            update_frontmatter "$local_file" "updated" "$updated_at"
            update_frontmatter "$local_file" "last_sync" "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
            
            PULLED_UPDATED=$((PULLED_UPDATED + 1))
        fi
    fi
done

echo

echo -e "${YELLOW}📤 Step 2: Pushing local updates to GitHub...${NC}"

# Process local epics
for epic_file in "$EPICS_DIR"/*.md; do
    [ ! -f "$epic_file" ] && continue
    
    epic_name=$(basename "$epic_file" .md)
    github_url=$(parse_frontmatter "$epic_file" "github")
    local_updated=$(parse_frontmatter "$epic_file" "updated")
    local_status=$(parse_frontmatter "$epic_file" "status")
    last_sync=$(parse_frontmatter "$epic_file" "last_sync")
    
    if [ -n "$github_url" ]; then
        issue_number=$(extract_issue_number "$github_url")
        
        if [ -n "$issue_number" ]; then
            # Check if GitHub issue exists
            github_issue=$(get_github_issue "$issue_number")
            
            if [ -z "$github_issue" ]; then
                echo "  GitHub issue #$issue_number was deleted, archiving local epic: $epic_name"
                update_frontmatter "$epic_file" "status" "archived"
                continue
            fi
            
            github_updated=$(echo "$github_issue" | jq -r '.updatedAt')
            
            # Check if local is newer than GitHub
            if [ -n "$local_updated" ] && [ -n "$github_updated" ] && is_newer "$local_updated" "$github_updated"; then
                echo "  Updating GitHub epic #$issue_number: $epic_name"
                
                # Convert local status to GitHub state
                case "$local_status" in
                    "completed"|"archived") gh issue close "$issue_number" 2>/dev/null || true ;;
                    *) gh issue reopen "$issue_number" 2>/dev/null || true ;;
                esac
                
                # Update issue body
                if gh issue edit "$issue_number" --body-file "$epic_file" 2>/dev/null; then
                    update_frontmatter "$epic_file" "last_sync" "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
                    PUSHED_UPDATED=$((PUSHED_UPDATED + 1))
                else
                    SYNC_FAILURES+=("Failed to update epic #$issue_number")
                fi
            fi
        fi
    else
        # No GitHub URL - create new issue
        echo "  Creating new GitHub epic: $epic_name"
        
        # Create issue
        new_issue=$(gh issue create --title "$epic_name" --body-file "$epic_file" --label "epic" 2>/dev/null)
        
        if [ -n "$new_issue" ]; then
            # Extract issue number from URL
            issue_number=$(echo "$new_issue" | grep -o '[0-9]*$')
            
            # Update local file with GitHub URL
            update_frontmatter "$epic_file" "github" "$new_issue"
            update_frontmatter "$epic_file" "last_sync" "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
            
            PUSHED_CREATED=$((PUSHED_CREATED + 1))
        else
            SYNC_FAILURES+=("Failed to create epic: $epic_name")
        fi
    fi
done

# Process local tasks
for epic_dir in "$EPICS_DIR"/*/; do
    [ ! -d "$epic_dir" ] && continue
    
    tasks_dir="${epic_dir}tasks"
    [ ! -d "$tasks_dir" ] && continue
    
    for task_file in "$tasks_dir"/*.md; do
        [ ! -f "$task_file" ] && continue
        
        task_name=$(basename "$task_file" .md)
        github_url=$(parse_frontmatter "$task_file" "github")
        local_updated=$(parse_frontmatter "$task_file" "updated")
        local_status=$(parse_frontmatter "$task_file" "status")
        
        if [ -n "$github_url" ]; then
            issue_number=$(extract_issue_number "$github_url")
            
            if [ -n "$issue_number" ]; then
                # Check if GitHub issue exists
                github_issue=$(get_github_issue "$issue_number")
                
                if [ -z "$github_issue" ]; then
                    echo "  GitHub issue #$issue_number was deleted, archiving local task: $task_name"
                    update_frontmatter "$task_file" "status" "archived"
                    continue
                fi
                
                github_updated=$(echo "$github_issue" | jq -r '.updatedAt')
                
                # Check if local is newer than GitHub
                if [ -n "$local_updated" ] && [ -n "$github_updated" ] && is_newer "$local_updated" "$github_updated"; then
                    echo "  Updating GitHub task #$issue_number: $task_name"
                    
                    # Convert local status to GitHub state and labels
                    case "$local_status" in
                        "completed") 
                            gh issue close "$issue_number" 2>/dev/null || true
                            ;;
                        "in_progress")
                            gh issue reopen "$issue_number" 2>/dev/null || true
                            gh issue edit "$issue_number" --add-label "in progress" 2>/dev/null || true
                            ;;
                        *)
                            gh issue reopen "$issue_number" 2>/dev/null || true
                            gh issue edit "$issue_number" --remove-label "in progress" 2>/dev/null || true
                            ;;
                    esac
                    
                    # Update issue body
                    if gh issue edit "$issue_number" --body-file "$task_file" 2>/dev/null; then
                        update_frontmatter "$task_file" "last_sync" "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
                        PUSHED_UPDATED=$((PUSHED_UPDATED + 1))
                    else
                        SYNC_FAILURES+=("Failed to update task #$issue_number")
                    fi
                fi
            fi
        else
            # No GitHub URL - create new issue
            echo "  Creating new GitHub task: $task_name"
            
            # Create issue with task label
            new_issue=$(gh issue create --title "$task_name" --body-file "$task_file" --label "task" 2>/dev/null)
            
            if [ -n "$new_issue" ]; then
                # Extract issue number from URL
                issue_number=$(echo "$new_issue" | grep -o '[0-9]*$')
                
                # Update local file with GitHub URL
                update_frontmatter "$task_file" "github" "$new_issue"
                update_frontmatter "$task_file" "last_sync" "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
                
                # Set initial labels based on status
                case "$local_status" in
                    "in_progress") gh issue edit "$issue_number" --add-label "in progress" 2>/dev/null || true ;;
                    "completed") gh issue close "$issue_number" 2>/dev/null || true ;;
                esac
                
                PUSHED_CREATED=$((PUSHED_CREATED + 1))
            else
                SYNC_FAILURES+=("Failed to create task: $task_name")
            fi
        fi
    done
done

echo

# Output summary
echo -e "${GREEN}🔄 Sync Complete${NC}"
echo
echo "Pulled from GitHub:"
echo "  Updated: $PULLED_UPDATED files"
echo "  Closed: $PULLED_CLOSED issues"
echo
echo "Pushed to GitHub:"
echo "  Updated: $PUSHED_UPDATED issues"
echo "  Created: $PUSHED_CREATED new issues"
echo
echo "Conflicts resolved: $CONFLICTS_RESOLVED"
echo

if [ ${#SYNC_FAILURES[@]} -eq 0 ]; then
    echo -e "${GREEN}Status: ✅ All files synced${NC}"
else
    echo -e "${YELLOW}Status: ⚠️  Some sync failures:${NC}"
    for failure in "${SYNC_FAILURES[@]}"; do
        echo -e "${RED}  ❌ $failure${NC}"
    done
fi

echo
echo -e "${BLUE}Sync completed at $(date)${NC}"