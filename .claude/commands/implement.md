# Implement a feature from a spec

You will implement a feature following an existing specification and using the specialized sub-agents.

## Steps

Here is the specification to implement: $ARGUMENT

### 1. Read and understand the spec

Read the provided specification file thoroughly. If the spec references other documentation, read those files as well.

### 2. Use Rails Programmer for backend implementation

Use the Rails Programmer sub-agent to implement the Rails backend components:
- Models, controllers, and routes
- Database migrations if needed
- Rails tests (controller and model tests)

Pass the specification and any relevant documentation to the Rails Programmer agent.

### 3. Use Stimulus Turbo Developer for frontend implementation

Use the Stimulus Turbo Developer sub-agent to implement the frontend components:
- Phlex components for the UI
- Stimulus controllers for interactive behavior
- Turbo Frames/Streams for dynamic updates

Pass the specification and any relevant documentation to the Stimulus Turbo Developer agent.

### 4. Review with DHH Code Reviewer

Once implementation is complete, use the DHH Code Reviewer sub-agent to review all the code that was written and ensure it meets Rails standards.

### 5. Write comprehensive tests

Use the Test Writer sub-agent to create additional tests:
- System tests for end-to-end user flows
- Phlex component tests
- Any integration tests that weren't covered by the Rails Programmer

### 6. Final verification

Run all tests to ensure the implementation works correctly and meets the specification requirements.

### 7. Summary

Provide a summary of what was implemented, which files were created/modified, and confirm that all tests pass.