# GitHub Operations Rules

This document outlines the rules and patterns for GitHub operations in the PM sync system.

## Authentication

- Use `gh` CLI for all GitHub operations
- Ensure user is authenticated: `gh auth status`
- Operations should fail gracefully if not authenticated

## Issue Fetching

### List Issues
```bash
gh issue list --label "epic" --limit 1000 --json number,title,state,body,labels,updatedAt
gh issue list --label "task" --limit 1000 --json number,title,state,body,labels,updatedAt
```

### Required Fields
- `number`: Issue number for identification
- `title`: Issue title for frontmatter
- `state`: open/closed status
- `body`: Issue description/content
- `labels`: Array of label objects with `name` property
- `updatedAt`: ISO timestamp for conflict detection

## Issue Creation

### Command Pattern
```bash
gh issue create --title "TITLE" --body-file TEMP_FILE --label "TYPE" --label "EPIC"
```

### Requirements
- Always use `--body-file` to avoid shell escaping issues
- Include type label (epic/task)
- Include epic label if applicable
- Clean up temp files after creation

### Response Handling
- Success: Returns GitHub issue URL
- Failure: Returns error message
- Extract issue number from URL for local file updates

## Issue Updates

### Command Pattern
```bash
gh issue edit ISSUE_NUMBER --body-file TEMP_FILE
```

### Requirements
- Use temp file to avoid shell escaping
- Preserve existing labels and title
- Only update body content
- Clean up temp files after operation

## Error Handling

### Network Failures
- Detect with `$?.success?` after command
- Provide user-friendly warning messages
- Continue operation for other issues

### Permission Errors
- Check `gh auth status` before operations
- Provide clear authentication instructions
- Fail gracefully without corrupting local state

### Rate Limiting
- GitHub CLI handles rate limiting automatically
- Monitor for 403 responses in error output
- Suggest retry with backoff if needed

## Repository Detection

### Get Repository Name
```bash
git remote get-url origin
```

### Parse Repository
- Extract owner/repo from Git remote URL
- Handle both SSH and HTTPS formats
- Default to 'unknown/repo' if parsing fails

## Temporary Files

### Naming Convention
- `/tmp/issue_body_NUMBER.md` for updates
- `/tmp/new_issue_body.md` for creation
- `/tmp/github_version_NUMBER.md` for conflicts

### Cleanup
- Always delete temp files after use
- Use `File.delete` with existence check
- Prevent accumulation of temp files