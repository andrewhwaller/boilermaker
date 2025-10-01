# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> Think carefully and implement the most concise solution that changes as little code as possible.

## 🚨 CRITICAL DATABASE RULES - NEVER VIOLATE THESE 🚨

### NEVER WIPE OR RESET THE DEVELOPMENT DATABASE

- **NEVER run `rails db:drop` in development**
- **NEVER run `rails db:reset` in development**
- **NEVER run `rails db:setup` on an existing database**
- **NEVER run destructive ActiveRecord commands like `User.destroy_all` in development console**
- **NEVER truncate tables in development**
- The development database contains important data that must be preserved
- Only run migrations that are additive or safely reversible
- If you need to test something destructive, use the test database only

### NEVER KILL THE DEVELOPMENT SERVER

- **NEVER kill the Rails server process (pid in tmp/pids/server.pid)**
- **NEVER kill background bash processes running `bin/dev` or `bin/rails server`**
- If you need to test something, use the existing running server

## Essential Information

This is a Rails 8 + Phlex application. **Always check the `/docs/` folder for detailed documentation before making changes.**

## Quick Start

```bash
bin/rails server # Start development server
rails db:migrate # Run pending migrations
rails test       # Run test suite
```

## Documentation Structure

📁 **`/docs/` - All detailed documentation lives here**

Start with **/docs/overview.md** which indexes all documentation:
- **[Architecture](docs/architecture.md)** - Application structure, patterns, and technology stack
- **[File System Structure](docs/file_system_structure.md)** - Directory organization and conventions

## Critical Information

### When Creating New Features

1. Check `/docs/architecture.md` for patterns and structure
2. Follow existing code conventions in similar files
3. Run tests after changes: `rails test`
4. Write tests for every new function/feature

## USE SUB-AGENTS FOR CONTEXT OPTIMIZATION

### 1. Always use the file-analyzer sub-agent when asked to read files.
The file-analyzer agent is an expert in extracting and summarizing critical information from files, particularly log files and verbose outputs. It provides concise, actionable summaries that preserve essential information while dramatically reducing context usage.

### 2. Always use the code-analyzer sub-agent when asked to search code, analyze code, research bugs, or trace logic flow.

The code-analyzer agent is an expert in code analysis, logic tracing, and vulnerability detection. It provides concise, actionable summaries that preserve essential information while dramatically reducing context usage.

### 3. Always use the test-runner sub-agent to run tests and analyze the test results.

Using the test-runner agent ensures:

- Full test output is captured for debugging
- Main conversation stays clean and focused
- Context usage is optimized
- All issues are properly surfaced
- No approval dialogs interrupt the workflow

## Philosophy

### Error Handling

- **Fail fast** for critical configuration (missing text model)
- **Log and continue** for optional features (extraction model)
- **Graceful degradation** when external services unavailable
- **User-friendly messages** through resilience layer

### Testing

- Always use the test-runner agent to execute tests.
- Do not use mock services for anything ever.
- Do not move on to the next test until the current test is complete.
- If the test fails, consider checking if the test is structured correctly before deciding we need to refactor the codebase.
- Tests to be verbose so we can use them for debugging.


## Tone and Behavior

- Criticism is welcome. Please tell me when I am wrong or mistaken, or even when you think I might be wrong or mistaken.
- Please tell me if there is a better approach than the one I am taking.
- Please tell me if there is a relevant standard or convention that I appear to be unaware of.
- Be skeptical.
- Be concise.
- Short summaries are OK, but don't give an extended breakdown unless we are working through the details of a plan.
- Do not flatter, and do not give compliments unless I am specifically asking for your judgement.
- Occasional pleasantries are fine.
- Feel free to ask many questions. If you are in doubt of my intent, don't guess. Ask.

## ABSOLUTE RULES:

- NO PARTIAL IMPLEMENTATION
- NO SIMPLIFICATION : no "//This is simplified stuff for now, complete implementation would blablabla"
- NO CODE DUPLICATION : check existing codebase to reuse functions and constants Read files before writing new functions. Use common sense function name to find them easily.
- NO DEAD CODE : either use or delete from codebase completely
- IMPLEMENT TEST FOR EVERY FUNCTIONS
- NO CHEATER TESTS : test must be accurate, reflect real usage and be designed to reveal flaws. No useless tests! Design tests to be verbose so we can use them for debuging.
- NO INCONSISTENT NAMING - read existing codebase naming patterns.
- NO OVER-ENGINEERING - Don't add unnecessary abstractions, factory patterns, or middleware when simple functions would work. Don't think "enterprise" when you need "working"
- NO MIXED CONCERNS - Don't put validation logic inside API handlers, database queries inside UI components, etc. instead of proper separation
- NO RESOURCE LEAKS - Don't forget to close database connections, clear timeouts, remove event listeners, or clean up file handles
