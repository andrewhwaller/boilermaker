---
created: 2025-08-30T20:18:02Z
last_updated: 2025-08-30T20:18:02Z
version: 1.0
author: Claude Code PM System
---

# System Patterns & Architecture

## Core Architectural Patterns

### Component-Based View Architecture
- **Phlex Components** - Pure Ruby view components instead of ERB templates
- **Inheritance Hierarchy** - Base component with specialized descendants
- **Component Composition** - Building complex UIs from simple components
- **Yield-Based Content** - Flexible component content injection

### Authentication Architecture
- **Session-Based Authentication** - Server-side session management
- **Two-Factor Authentication** - TOTP implementation with recovery codes
- **Account Scoping** - Multi-tenant architecture pattern
- **Current Context Pattern** - Thread-safe current user/account access

### Database Patterns
- **Active Record Pattern** - Rails ORM with model concerns
- **Account Scoping Concern** - Shared multi-tenant functionality
- **Migration Strategy** - Version-controlled database changes
- **Solid Adapters** - Database-backed caching, jobs, and cable

## Design Patterns in Use

### Model Layer Patterns
```ruby
# Concern Pattern - Shared functionality across models
module AccountScoped
  extend ActiveSupport::Concern
  # Shared multi-tenant logic
end

# Current Context Pattern - Thread-safe access
class Current < ActiveSupport::CurrentAttributes
  attribute :account, :user, :request_id, :user_agent, :ip_address
end
```

### Component Patterns  
```ruby
# Base Component Pattern - Shared component functionality
class ApplicationComponent < Phlex::HTML
  # Common component behavior
end

# Form Component Pattern - Consistent form building
class FormGroup < ApplicationComponent
  # Reusable form group logic
end
```

### Service Layer Patterns
- **Mailer Services** - Email handling with ApplicationMailer base
- **Background Jobs** - Solid Queue for asynchronous processing
- **Authentication Services** - Session and 2FA management

## Data Flow Architecture

### Request-Response Flow
1. **Route Resolution** - Rails routing to controllers
2. **Authentication Check** - Session validation and account scoping
3. **Controller Action** - Business logic processing
4. **Component Rendering** - Phlex component hierarchy
5. **Response Generation** - HTML output with Hotwire enhancements

### Component Data Flow
```ruby
# Data flows down through component hierarchy
ApplicationLayout
├── Navigation (receives current_user)
├── Main Content (receives @data)
└── Footer (receives global state)
```

### Authentication Flow
1. **Login Request** - Credential validation
2. **Session Creation** - Secure session establishment
3. **2FA Challenge** - Optional TOTP verification
4. **Account Scoping** - Set current account context
5. **Authorization** - Permission checking per request

## Error Handling Patterns

### Graceful Degradation
- **External Service Failures** - Continue with reduced functionality
- **Optional Features** - Log errors, don't break core features
- **User-Friendly Messages** - Resilience layer for error presentation

### Fail-Fast Patterns
- **Critical Configuration** - Stop startup if essential config missing
- **Database Connectivity** - Immediate failure for data access issues
- **Security Violations** - Immediate rejection of suspicious requests

## Caching Strategies

### Multi-Layer Caching
- **Application Cache** - Solid Cache for data caching
- **Asset Caching** - Propshaft with browser caching
- **Component Caching** - Phlex component result caching
- **Database Query Cache** - Rails built-in query caching

### Cache Invalidation
- **Time-Based** - TTL for temporary data
- **Event-Based** - Invalidate on model changes
- **Manual Invalidation** - Explicit cache clearing

## Scalability Patterns

### Horizontal Scaling Preparation
- **Stateless Sessions** - Database-backed session storage
- **Background Processing** - Queue-based job processing
- **Asset Pipeline** - CDN-ready asset organization
- **Database Design** - Account-scoped data for sharding readiness

### Performance Optimizations
- **Component Reuse** - Efficient component instantiation
- **Query Optimization** - N+1 prevention and efficient queries
- **Asset Optimization** - Tailwind purging and asset compression
- **Boot Time** - Bootsnap for faster application startup

## Security Patterns

### Defense in Depth
- **Input Validation** - Multiple validation layers
- **Authentication** - Session + 2FA requirements
- **Authorization** - Account scoping and permissions
- **Output Encoding** - XSS prevention in Phlex components

### Secure Development Practices
- **Static Analysis** - Brakeman security scanning
- **Password Security** - BCrypt + breach checking
- **Session Security** - Secure session configuration
- **CSRF Protection** - Rails built-in CSRF handling

## Testing Patterns

### Component Testing
- **Unit Tests** - Individual component testing
- **Integration Tests** - Component interaction testing
- **System Tests** - Full workflow testing with Capybara

### Test Organization
- **Mirrored Structure** - Tests mirror app directory structure
- **Shared Examples** - Reusable test patterns
- **Factory Patterns** - Test data generation strategies