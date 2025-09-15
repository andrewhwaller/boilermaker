# Frontmatter Operations Rules

This document outlines the rules and patterns for frontmatter handling in the PM sync system.

## Frontmatter Format

### Required Structure
```yaml
---
title: "Issue Title"
type: "epic" | "task"
state: "open" | "closed"
created: "2024-01-01T12:00:00Z"
updated: "2024-01-01T12:00:00Z"
last_sync: "2024-01-01T12:00:00Z"
github_url: "https://github.com/owner/repo/issues/123"
---
```

### Optional Fields
```yaml
epic: "epic-name"           # For tasks belonging to an epic
priority: "high" | "medium" | "low"
assignee: "username"
labels: "label1, label2"
archived: true              # For deleted GitHub issues
archived_at: "2024-01-01T12:00:00Z"
```

## File Structure

### Epic Files
- Location: `epics/epic-name.md`
- Type: `epic`
- Required: `title`, `created`, `state`

### Task Files
- Location: `tasks/task-name.md` or `epics/epic-name/task-name.md`
- Type: `task`
- Required: `title`, `created`, `state`
- Optional: `epic` (reference to parent epic)

## Parsing Rules

### YAML Extraction
```ruby
def parse_frontmatter(content)
  lines = content.lines
  return {} unless lines.first&.strip == '---'
  
  yaml_end = lines[1..-1].find_index { |line| line.strip == '---' }
  return {} unless yaml_end
  
  yaml_content = lines[1..yaml_end].join
  YAML.safe_load(yaml_content) || {}
rescue
  {}
end
```

### Content Extraction
- Skip frontmatter delimiters (`---`)
- Skip YAML content
- Return remaining lines as body content

## Update Rules

### Timestamp Management
- `created`: Set once, never changed
- `updated`: Update on any content change
- `last_sync`: Update after successful sync

### State Synchronization
- Local state follows GitHub state
- `open` -> `closed`: Archive locally
- `closed` -> `open`: Restore locally

### Title Synchronization
- GitHub title is authoritative
- Update local title from GitHub
- Preserve local title when pushing to GitHub

## Conflict Detection

### Change Detection
```ruby
def both_changed?(local_file, github_issue)
  frontmatter = parse_frontmatter(File.read(local_file))
  local_updated = Time.parse(frontmatter['updated'])
  github_updated = Time.parse(github_issue['updatedAt'])
  last_sync = Time.parse(frontmatter['last_sync'] || '1970-01-01')
  
  local_updated > last_sync && github_updated > last_sync
end
```

### Resolution Priority
1. User choice (local/github/merge)
2. Default to local version
3. Update `last_sync` after resolution

## File Generation

### Content Assembly
```ruby
def generate_file_content(frontmatter, body)
  yaml_content = YAML.dump(frontmatter).sub(/^---\n/, '')
  "---\n#{yaml_content}---\n\n#{body}"
end
```

### YAML Formatting
- Use `YAML.dump` for consistency
- Remove extra `---` header from YAML output
- Ensure proper newline separation

## Error Handling

### Invalid YAML
- Return empty hash `{}`
- Continue with default values
- Log warning for debugging

### Missing Frontmatter
- Treat as non-PM file
- Skip during sync operations
- No error or warning needed

### Corrupted Files
- Attempt to preserve content
- Create backup before modification
- Provide recovery instructions