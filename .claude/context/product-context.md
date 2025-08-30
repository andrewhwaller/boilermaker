---
created: 2025-08-30T20:18:02Z
last_updated: 2025-08-30T20:18:02Z
version: 1.0
author: Claude Code PM System
---

# Product Context

## Product Definition
**Boilermaker** is a modern Rails application template designed to accelerate web application development with a carefully curated technology stack and architectural patterns.

## Target Users

### Primary Users
- **Ruby on Rails Developers** - Looking for modern development patterns
- **Startup Teams** - Need rapid MVP development capabilities  
- **Freelancers/Consultants** - Require reliable, scalable project foundation
- **Development Agencies** - Want consistent project architecture across clients

### User Personas
#### The Modern Rails Developer
- Values clean architecture and modern patterns
- Prefers Ruby-first solutions over JavaScript-heavy approaches
- Wants authentication and common features out-of-the-box
- Appreciates comprehensive documentation and clear conventions

#### The Startup Founder/CTO
- Needs to move fast without sacrificing code quality
- Values proven patterns over experimental approaches
- Requires scalable architecture from day one
- Wants to focus on business logic, not boilerplate

#### The Development Consultant  
- Manages multiple projects with similar requirements
- Needs consistent patterns across different clients
- Values maintainable code for long-term client relationships
- Requires clear documentation for team handoffs

## Core Functionality

### Authentication System
- **User Registration/Login** - Complete user lifecycle management
- **Two-Factor Authentication** - TOTP-based 2FA with QR codes
- **Recovery Codes** - Backup authentication methods
- **Session Management** - Secure, database-backed sessions
- **Password Security** - Breach checking and secure hashing

### Multi-Tenant Architecture
- **Account Scoping** - Built-in multi-tenancy support
- **User-Account Relationships** - Flexible user-to-account mapping
- **Context Management** - Thread-safe current user/account access

### View Layer Excellence
- **Phlex Components** - Pure Ruby view layer
- **Component Kit System** - Organized, reusable UI components
- **Scaffolding Integration** - Generate Phlex views automatically
- **Tailwind Integration** - Utility-first styling system

### Developer Experience Features
- **Custom Scaffolding** - Generate complete CRUD with Phlex views
- **Comprehensive Documentation** - Architecture and usage guides
- **Development Tools** - Overmind process management
- **Code Quality Tools** - RuboCop, Brakeman, and testing setup

## Use Cases

### Rapid Prototyping
```bash
# Generate complete CRUD interface with Phlex views
bin/rails generate scaffold Product name:string price:decimal description:text
```

### Multi-Tenant SaaS Applications
- Account-scoped data models
- User invitation and management
- Billing and subscription readiness

### Content Management Systems  
- Rich component library for layouts
- Form handling with validation
- Asset management integration

### Internal Business Tools
- Authentication with 2FA for security
- Role-based access patterns
- Reporting and dashboard components

## Feature Categories

### Core Infrastructure
- **Authentication & Authorization** - Complete user management
- **Multi-Tenancy** - Account scoping and isolation
- **Background Processing** - Solid Queue integration
- **Caching Strategy** - Multi-layer caching with Solid Cache

### UI/UX Features
- **Component Library** - Comprehensive Phlex components
- **Responsive Design** - Tailwind CSS implementation
- **Form Handling** - Rich form components with validation
- **Navigation Systems** - Dynamic navigation components

### Developer Productivity
- **Code Generation** - Custom Phlex scaffolding
- **Development Environment** - Complete dev toolchain
- **Testing Framework** - System and unit testing setup
- **Code Quality** - Linting and security scanning

### Deployment & Operations
- **Docker Support** - Complete containerization
- **Kamal Deployment** - Modern Rails deployment
- **Database Strategy** - SQLite with Litestream
- **Asset Pipeline** - Optimized asset delivery

## Success Metrics

### Developer Adoption
- **Time to First CRUD** - Under 5 minutes from clone to working interface
- **Documentation Completeness** - All major features documented with examples
- **Community Contribution** - Pull requests and issue engagement
- **Fork/Star Ratio** - GitHub community engagement metrics

### Technical Excellence
- **Performance Benchmarks** - Sub-200ms average response times
- **Security Compliance** - Clean Brakeman scans
- **Test Coverage** - Comprehensive test suite coverage
- **Code Quality** - Clean RuboCop adherence

### Product Readiness
- **Feature Completeness** - Authentication, multi-tenancy, UI components
- **Scalability Preparation** - Database design and caching strategy
- **Maintainability** - Clear architecture and documentation
- **Upgrade Path** - Rails and dependency update compatibility

## Competitive Advantages

### Pure Ruby Philosophy
- Minimal JavaScript dependency
- Consistent language across stack
- Easier debugging and maintenance
- Better IDE support and tooling

### Modern Rails Patterns
- Rails 8 features and conventions
- Solid foundation gems (Queue, Cache, Cable)
- Contemporary authentication approaches
- Component-based view architecture

### Comprehensive Developer Experience
- Complete development environment setup
- Extensive documentation and examples
- Custom tooling for productivity
- Clear upgrade and migration paths