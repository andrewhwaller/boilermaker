---
created: 2025-08-30T20:18:02Z
last_updated: 2025-08-30T20:18:02Z
version: 1.0
author: Claude Code PM System
---

# Project Brief

## What It Does
**Boilermaker** is a comprehensive Rails 8 application template that provides a modern, production-ready foundation for web applications. It combines cutting-edge Rails features with a pure Ruby view layer (Phlex), comprehensive authentication, and developer productivity tools.

## Why It Exists

### Problem Statement
Modern web development often requires developers to repeatedly implement the same foundational features:
- User authentication and authorization systems
- Multi-tenant architecture patterns  
- Component-based UI systems
- Development tooling and deployment pipelines
- Testing and code quality frameworks

### Solution Approach
Boilermaker eliminates the need to rebuild these foundations by providing:
- **Battle-tested patterns** implemented with modern Rails conventions
- **Pure Ruby approach** minimizing JavaScript complexity while maintaining interactivity
- **Comprehensive tooling** for development, testing, and deployment
- **Clear documentation** enabling team adoption and maintenance

### Market Gap
Existing Rails templates often:
- Use outdated patterns or Rails versions
- Rely heavily on JavaScript frameworks
- Lack comprehensive authentication systems
- Miss modern deployment and development tooling
- Have incomplete documentation

## Key Objectives

### Primary Goals
1. **Accelerate Development** - Reduce project bootstrap time from weeks to hours
2. **Maintain Code Quality** - Enforce consistent patterns and best practices
3. **Enable Scalability** - Build on patterns that support growth
4. **Simplify Maintenance** - Use proven, well-documented approaches

### Success Criteria
- **Bootstrap Speed** - Complete CRUD functionality in under 5 minutes
- **Pattern Consistency** - All generated code follows established conventions  
- **Documentation Completeness** - Every feature has usage examples and architecture explanation
- **Community Adoption** - Positive feedback and contributions from Rails community

## Scope Definition

### Included Features
- **Complete Authentication** - Registration, login, 2FA, password recovery
- **Multi-Tenant Foundation** - Account scoping and user management
- **Pure Ruby Views** - Phlex component system with scaffolding
- **Modern Rails Stack** - Rails 8, Solid gems, Hotwire
- **Developer Tooling** - Testing, linting, development environment
- **Deployment Ready** - Docker, Kamal, and production configuration

### Explicitly Excluded  
- **Payment Processing** - Billing systems (can be added by users)
- **Complex Business Logic** - Domain-specific features
- **JavaScript Frameworks** - React, Vue, Angular integrations
- **Multiple Databases** - PostgreSQL, MySQL (SQLite focus)
- **Microservices Architecture** - Monolith-first approach

## Technical Constraints

### Technology Decisions
- **Ruby on Rails 8+** - Latest Rails features and conventions
- **SQLite Database** - Simplicity with Litestream for production
- **Phlex Views** - Pure Ruby instead of ERB templates  
- **Tailwind CSS** - Utility-first styling approach
- **Docker Deployment** - Container-based deployment strategy

### Architectural Principles
- **Convention over Configuration** - Follow Rails conventions
- **Pure Ruby Priority** - Minimize JavaScript where possible
- **Component Composition** - Build UIs from reusable components
- **Test-Driven Development** - Comprehensive testing strategy
- **Security First** - Built-in security best practices

## Success Metrics

### Development Velocity
- **Setup Time** - From clone to running application: < 5 minutes
- **First Feature** - Add authenticated CRUD: < 10 minutes  
- **Team Onboarding** - New developer productivity: < 1 hour

### Code Quality
- **Test Coverage** - Maintain > 90% code coverage
- **Security Score** - Clean Brakeman security scans
- **Performance** - Average response times < 200ms
- **Maintainability** - Clear RuboCop compliance

### Community Impact
- **Documentation Quality** - All features documented with examples
- **Issue Resolution** - Community issues addressed within 1 week
- **Contribution Activity** - Regular community contributions and improvements
- **Adoption Rate** - Growing usage across Rails community

## Risk Management

### Technical Risks
- **Rails Version Updates** - Maintain compatibility with Rails evolution
- **Dependency Management** - Keep gem dependencies current and secure
- **Performance Scaling** - Ensure patterns support application growth
- **Browser Compatibility** - Maintain cross-browser functionality

### Mitigation Strategies
- **Regular Updates** - Quarterly dependency and Rails version reviews
- **Automated Testing** - Comprehensive CI/CD pipeline for validation
- **Performance Monitoring** - Regular performance benchmarking
- **Community Engagement** - Active response to user feedback and issues

## Long-term Vision
Transform Boilermaker from a project template into a comprehensive Rails development platform that:
- **Sets Industry Standards** for modern Rails application architecture
- **Educates Developers** through comprehensive documentation and examples  
- **Evolves with Rails** maintaining cutting-edge feature adoption
- **Builds Community** fostering collaboration and contribution

The project serves as both a practical development accelerator and a reference implementation of modern Rails best practices.