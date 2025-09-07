#!/bin/bash

# PM Issue Close - Mark an issue as complete and sync to GitHub
set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <issue_number>"
    echo "Example: $0 38"
    exit 1
fi

ISSUE_NUMBER="$1"
EPICS_DIR=".claude/epics"
CURRENT_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🎯 Closing Issue #${ISSUE_NUMBER}...${NC}"
echo

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

# Find the task file for the issue
echo "🔍 Finding local task file for issue #${ISSUE_NUMBER}..."
TASK_FILE=$(find "$EPICS_DIR" -name "${ISSUE_NUMBER}.md" 2>/dev/null | head -1)

if [ -z "$TASK_FILE" ]; then
    echo -e "${RED}❌ Task file for issue #${ISSUE_NUMBER} not found${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Found task file: $TASK_FILE${NC}"

# Get current task info
TASK_NAME=$(parse_frontmatter "$TASK_FILE" "name")
CURRENT_STATUS=$(parse_frontmatter "$TASK_FILE" "status")
GITHUB_URL=$(parse_frontmatter "$TASK_FILE" "github")

echo "📝 Task: $TASK_NAME"
echo "📊 Current status: $CURRENT_STATUS"

# Check if already completed
if [ "$CURRENT_STATUS" = "completed" ]; then
    echo -e "${YELLOW}⚠️  Issue #${ISSUE_NUMBER} is already marked as completed${NC}"
else
    echo "🔄 Updating local status to completed..."
    update_frontmatter "$TASK_FILE" "status" "completed"
    update_frontmatter "$TASK_FILE" "updated" "$CURRENT_TIME"
    echo -e "${GREEN}✅ Local task status updated to completed${NC}"
fi

# Update epic progress
EPIC_DIR=$(dirname "$TASK_FILE")
EPIC_FILE="$EPIC_DIR/epic.md"

if [ -f "$EPIC_FILE" ]; then
    echo "📈 Updating epic progress..."
    
    # Count total tasks and completed tasks
    TOTAL_TASKS=$(find "$EPIC_DIR" -name "*.md" -not -name "epic.md" -not -name "execution-status.md" | wc -l | tr -d ' ')
    COMPLETED_TASKS=$(find "$EPIC_DIR" -name "*.md" -not -name "epic.md" -not -name "execution-status.md" -exec grep -l "^status: completed" {} \; | wc -l | tr -d ' ')
    
    if [ "$TOTAL_TASKS" -gt 0 ]; then
        PROGRESS=$((COMPLETED_TASKS * 100 / TOTAL_TASKS))
        update_frontmatter "$EPIC_FILE" "progress" "${PROGRESS}%"
        update_frontmatter "$EPIC_FILE" "updated" "$CURRENT_TIME"
        echo -e "${GREEN}✅ Epic progress updated to ${PROGRESS}% (${COMPLETED_TASKS}/${TOTAL_TASKS} tasks completed)${NC}"
    fi
fi

# Sync to GitHub if we have a GitHub URL
if [ -n "$GITHUB_URL" ]; then
    echo "🔗 Syncing to GitHub..."
    
    # Check if gh CLI is available and authenticated
    if ! command -v gh &> /dev/null; then
        echo -e "${RED}❌ GitHub CLI (gh) not found. Please install it first.${NC}"
        echo -e "${YELLOW}⚠️  Local task marked as completed, but not synced to GitHub${NC}"
    elif ! gh auth status &> /dev/null; then
        echo -e "${RED}❌ Not authenticated with GitHub. Run 'gh auth login' first.${NC}"
        echo -e "${YELLOW}⚠️  Local task marked as completed, but not synced to GitHub${NC}"
    else
        # Close the GitHub issue
        if gh issue close "$ISSUE_NUMBER" --comment "Task completed and closed automatically." 2>/dev/null; then
            echo -e "${GREEN}✅ GitHub issue #${ISSUE_NUMBER} closed successfully${NC}"
            
            # Update last_sync timestamp
            update_frontmatter "$TASK_FILE" "last_sync" "$CURRENT_TIME"
        else
            echo -e "${RED}❌ Failed to close GitHub issue #${ISSUE_NUMBER}${NC}"
            echo -e "${YELLOW}⚠️  Local task marked as completed, but GitHub sync failed${NC}"
        fi
    fi
else
    echo -e "${YELLOW}⚠️  No GitHub URL found, skipping GitHub sync${NC}"
fi

echo
echo -e "${GREEN}🎉 Issue #${ISSUE_NUMBER} completed successfully!${NC}"
echo
echo "Summary:"
echo "  📁 Local file: $TASK_FILE"
echo "  📊 Status: completed"
echo "  🕐 Updated: $CURRENT_TIME"
if [ -n "$GITHUB_URL" ]; then
    echo "  🔗 GitHub: $GITHUB_URL (closed)"
fi
echo

exit 0