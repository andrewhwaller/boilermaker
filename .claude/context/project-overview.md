---
created: 2025-08-30T20:18:02Z
last_updated: 2025-08-30T20:18:02Z
version: 1.0
author: Claude Code PM System
---

# Project Overview

## High-Level Summary
Boilermaker is a modern Rails 8 application template that serves as a comprehensive foundation for web application development. It combines proven Rails patterns with cutting-edge view components, comprehensive authentication, and a developer-first approach to rapid application development.

## Core Features

### Authentication & Security
- **Complete User Management** - Registration, login, profile management
- **Two-Factor Authentication** - TOTP-based 2FA with QR code setup
- **Recovery Systems** - Backup codes and password recovery flows  
- **Session Security** - Secure, database-backed session management
- **Password Protection** - Breach checking and secure hashing (BCrypt)
- **Security Scanning** - Brakeman integration for vulnerability detection

### Multi-Tenant Architecture
- **Account Scoping** - Built-in multi-tenancy support for SaaS applications
- **User-Account Relationships** - Flexible association patterns
- **Current Context Management** - Thread-safe access to current user/account
- **Data Isolation** - Account-scoped database queries and operations

### Pure Ruby View System
- **Phlex Components** - Modern Ruby-based view components replacing ERB
- **Component Hierarchy** - Organized inheritance structure for UI elements  
- **Scaffolding Integration** - Generate complete Phlex views automatically
- **Form Components** - Rich form handling with consistent validation patterns
- **Layout System** - Flexible layout components with yield-based content

### Developer Experience
- **Custom Scaffolding** - Rails generate commands create Phlex views
- **Development Environment** - Complete toolchain with Overmind process management
- **Code Quality Tools** - RuboCop, Brakeman, and comprehensive testing
- **Hot Reloading** - Instant feedback during development with Hotwire
- **Comprehensive Documentation** - Architecture guides and usage examples

## Current State

### Implemented Features ✅
- **Authentication System** - Complete user registration and login flows
- **Two-Factor Authentication** - TOTP implementation with recovery codes
- **Phlex Component Library** - Comprehensive UI components
- **Scaffolding System** - Custom generators for Phlex views
- **Multi-Tenant Foundation** - Account scoping and user management
- **Development Toolchain** - Testing, linting, and development environment
- **Documentation** - Architecture guides and component documentation

### Recent Accomplishments
- **ERB to Phlex Migration** - Complete conversion of view layer
- **Component Kit Architecture** - Organized component system implementation
- **Documentation Expansion** - Comprehensive Phlex architecture documentation
- **Scaffolding Enhancement** - Custom Phlex scaffolding generator

### Active Development Areas
- **Performance Optimization** - Component caching and query optimization
- **Testing Coverage** - Expanding system and integration test coverage
- **Documentation Refinement** - Usage examples and best practices
- **Component Library Growth** - Additional UI components and patterns

## Technology Integration Points

### Frontend Integration
- **Hotwire Stack** - Turbo and Stimulus for interactive experiences
- **Tailwind CSS** - Utility-first styling with typography extensions
- **Importmap** - Modern JavaScript loading without bundling
- **Asset Pipeline** - Propshaft for efficient asset management

### Backend Services  
- **Background Processing** - Solid Queue for asynchronous job handling
- **Caching Layer** - Solid Cache for database-backed caching
- **Email System** - ActionMailer with development previews
- **Database Strategy** - SQLite with Litestream for production reliability

### Development Infrastructure
- **Testing Framework** - Rails testing with Capybara for system tests
- **Code Quality** - RuboCop Rails Omakase styling and Brakeman security
- **Development Server** - Overmind process management with hot reloading
- **Deployment** - Kamal containerized deployment with Thruster acceleration

## Integration Capabilities

### External Service Integration
- **Email Services** - SMTP configuration with development previews
- **Authentication Providers** - Extensible for OAuth integration
- **Monitoring Services** - Error tracking and performance monitoring ready
- **CDN Integration** - Asset pipeline optimized for CDN delivery

### API Development
- **JSON APIs** - JBuilder for structured API responses  
- **Authentication** - Token-based API authentication patterns
- **Rate Limiting** - Built-in Rails rate limiting capabilities
- **Versioning** - API versioning patterns and conventions

### Database Flexibility
- **Migration Strategy** - Version-controlled database changes
- **Query Optimization** - N+1 prevention and efficient query patterns
- **Multi-Database** - Rails multiple database support ready
- **Backup Strategy** - Litestream integration for SQLite backup

## Operational Readiness

### Production Features
- **Container Deployment** - Complete Docker configuration
- **Performance Monitoring** - Application performance tracking
- **Error Handling** - Comprehensive error management and logging  
- **Security Headers** - Production-ready security configuration

### Scalability Preparation
- **Horizontal Scaling** - Stateless design for load balancing
- **Background Processing** - Queue-based job processing
- **Asset Optimization** - CDN-ready asset organization
- **Database Optimization** - Query caching and connection pooling

### Maintenance Support
- **Health Checks** - Application and dependency health monitoring
- **Log Management** - Structured logging for operations
- **Dependency Updates** - Automated security updates and version management
- **Backup Systems** - Database and asset backup strategies

## Future Expansion Areas
- **Advanced Component Patterns** - Complex UI component implementations
- **API Enhancement** - GraphQL integration and advanced API features  
- **Performance Features** - Caching strategies and optimization patterns
- **Integration Templates** - Common third-party service integrations
- **Advanced Testing** - Load testing and performance testing frameworks