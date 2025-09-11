---
name: stripe-integration
status: backlog
created: 2025-08-30T15:46:10Z
progress: 0%
prd: .claude/prds/stripe-integration.md
github: https://github.com/andrewhwaller/boilermaker/issues/35
updated: 2025-09-11T15:30:00Z
last_sync: 2025-09-11T15:30:00Z
---

# Epic: Stripe Integration for Payments

## Overview

Implement comprehensive Stripe payment processing system enabling secure one-time payments and recurring subscriptions. The system will include customer management, webhook processing, billing portal integration, and complete test/production environment support for SaaS monetization.

## Architecture Decisions

- **Payment Abstraction**: Use Pay gem v11.1+ for Rails-native payment processing with Stripe backend
- **Model Integration**: Add `pay_customer` to User model for automatic customer management and syncing
- **Security Strategy**: Pay gem handles all Stripe API communication, credentials managed via Rails encrypted credentials
- **Webhook Architecture**: Pay gem provides automatic webhook handling at `/pay/webhooks/stripe` with custom processors for business logic
- **Testing Focus**: Comprehensive testing of our business logic, controllers, and UI - not Pay gem internals

## Technical Approach

### Pay Gem Integration Foundation
Leverage Pay gem's unified payment interface:
- Add `pay_customer` to User model for automatic Stripe customer management
- Configure Pay initializer with Stripe credentials and webhook endpoints
- Use Pay's built-in customer syncing and payment method management
- Implement custom business logic on top of Pay's abstractions

### Payment Processing Controllers
Build Rails controllers for payment workflows:
- PaymentsController for one-time payment processing with Pay methods
- SubscriptionsController for subscription lifecycle management
- Proper authentication, authorization, and error handling
- Success/failure redirects with user feedback and flash messages

### Subscription Business Logic
Implement subscription management with Pay abstractions:
- Service objects wrapping Pay's subscription methods
- User model helpers for subscription status checking (`subscribed?`, `on_trial?`)
- Plan-based feature access control throughout application
- Custom validation and business rules on top of Pay functionality

### Custom Webhook Processing
Extend Pay's webhook handling for business logic:
- Custom webhook processors for payment and subscription events
- Email notifications on payment success/failure using ActionMailer
- Subscription status updates and user access control changes
- Integration with existing notification and audit systems

### Customer Portal Integration
Integrate Stripe Customer Portal through Pay:
- PortalController using Pay's customer portal methods
- Secure portal session creation and return URL handling
- Custom portal configuration for branding and feature access
- Integration with existing user dashboard and account management

## Implementation Strategy

### Development Phases
1. **Pay Installation**: Install Pay gem, run migrations, configure Stripe integration
2. **User Integration**: Add `pay_customer` to User model with custom name methods
3. **Payment Controllers**: Build PaymentsController and SubscriptionsController with full test coverage
4. **Business Logic**: Implement subscription services and User model helpers with extensive testing
5. **Webhook Processors**: Create custom webhook processors for business events with test coverage
6. **Customer Portal**: Integrate Pay's portal functionality with custom controller logic
7. **UI Components**: Build Phlex components for payment forms and subscription management

### Testing Strategy
Comprehensive testing focused on our implementation code:
- **Model Tests**: User extensions, subscription helpers, business logic validation
- **Controller Tests**: Authentication, parameter validation, redirects, error handling
- **Service Tests**: Subscription operations, plan management, business rules
- **Integration Tests**: Complete payment workflows, webhook processing, portal flows
- **Component Tests**: Phlex payment forms, plan selection, subscription status display
- **No Pay Gem Testing**: Focus only on our business logic, not Pay's internal functionality

### Security Implementation
- PCI DSS compliance through Pay gem's Stripe integration
- No sensitive payment data stored in application database
- Pay gem handles webhook signature verification automatically
- Secure credential management using Rails encrypted credentials

## Task Breakdown Preview

Detailed tasks with implementation and testing focus:
- [ ] **Pay Installation & User Integration**: Install Pay gem, configure Stripe, add `pay_customer` to User model
- [ ] **Payment & Subscription Controllers**: Build controllers with authentication, validation, and comprehensive test coverage
- [ ] **Subscription Business Logic**: Implement service objects and User helpers with extensive model/service testing
- [ ] **Custom Webhook Processors**: Create business logic processors for payment events with webhook testing
- [ ] **Customer Portal Integration**: Build portal controller and flows with integration testing
- [ ] **Plan Management & Authorization**: Implement feature access control with authorization testing
- [ ] **Payment UI Components**: Build Phlex components for forms and displays with component testing

## Dependencies

### Internal Dependencies
- Existing User authentication and authorization system ✅
- Phlex component library for payment form integration ✅
- ActionMailer configured for payment notification emails ✅
- Rails encrypted credentials for API key storage ✅
- Existing test framework (Minitest/RSpec) for comprehensive testing

### External Dependencies
- Active Stripe account with API keys (test and production)
- Pay gem v11.1+ and Stripe gem dependencies
- Webhook endpoint accessibility from Stripe servers (HTTPS required)
- Stripe CLI for local webhook testing during development

## Success Criteria (Technical)

### Implementation Quality
- All 7 tasks completed with comprehensive implementation and testing
- 78+ hours of development with 46% dedicated to testing our code
- Pay gem integration seamlessly works with existing User model
- Controllers properly handle authentication, validation, and error cases

### Testing Coverage
- **Model Tests**: User extensions, subscription helpers, business logic (100% coverage)
- **Controller Tests**: All payment/subscription endpoints with edge cases (100% coverage) 
- **Service Tests**: Subscription operations, plan management, validation rules (100% coverage)
- **Integration Tests**: Complete payment workflows, webhook processing (key paths covered)
- **Component Tests**: All Phlex payment components render and function correctly
- **Focus**: Zero testing of Pay gem internals - only our business logic

### System Reliability
- Payment processing integrates smoothly with Pay gem abstractions
- Custom webhook processors handle business events correctly
- Subscription lifecycle operations work reliably through Pay methods
- Customer portal integration provides seamless user experience
- Feature access control enforces plan-based permissions throughout app

### Business Integration
- User subscription status accurately reflects Stripe subscription state
- Plan-based feature access control works across entire application
- Email notifications sent appropriately for payment events
- Customer portal allows self-service subscription management
- Upgrade/downgrade flows handle billing changes correctly

## Detailed Task Breakdown

### Task 1: Pay Installation & User Model Integration (8 hours)
**Implementation (3 hours):**
- Add Pay gem (~11.1) and Stripe gem to Gemfile
- Run `pay:install:migrations` and configure Pay initializer
- Add `pay_customer` to User model
- Implement `pay_customer_name` method on User
- Configure Stripe API credentials in Rails encrypted credentials

**Testing Requirements (5 hours):**
- User model tests: `pay_customer_name` returns correct format
- User factory compatibility with pay_customer integration
- Customer creation on User creation (integration test)
- Email change triggers customer sync to Stripe (integration test)
- User deletion handles Pay customer cleanup properly

### Task 2: Payment & Subscription Controllers (16 hours)
**Implementation (8 hours):**
- PaymentsController: create action, success/failure handling
- SubscriptionsController: create, show, update, cancel actions
- Strong parameters, authentication requirements
- Flash message handling and redirect logic
- Error handling for payment failures

**Testing Requirements (8 hours):**
- PaymentsController tests: POST /payments with valid/invalid params
- Authentication required for all payment actions
- Success redirects to correct path with success message
- Payment failure renders form with error messages
- SubscriptionsController tests: CRUD operations, parameter validation
- Subscription not found error handling
- JSON response handling where applicable

### Task 3: Subscription Business Logic Services (12 hours)
**Implementation (6 hours):**
- SubscriptionService for subscription lifecycle operations
- User model subscription helper methods
- Plan validation and business rules
- Integration with Pay's subscription methods

**Testing Requirements (6 hours):**
- SubscriptionService tests: create_subscription with valid/invalid plans
- change_plan operations and proration calculations
- cancel_subscription and reactivate_subscription logic
- User helper method tests: subscribed_to?(plan), subscription_active?
- days_until_trial_ends calculations
- can_access_feature?(feature) based on current plan

### Task 4: Custom Webhook Processors (10 hours)
**Implementation (6 hours):**
- Custom webhook processors for Stripe events
- Email notifications on payment success/failure
- Subscription status updates in our system
- Integration with existing notification systems

**Testing Requirements (4 hours):**
- stripe.invoice.payment_succeeded sends receipt email
- stripe.invoice.payment_failed sends dunning email
- stripe.customer.subscription.deleted updates user access
- stripe.customer.subscription.updated syncs plan changes
- Idempotent processing of duplicate webhook events
- Error handling when webhook processing fails

### Task 5: Customer Portal Integration (6 hours)
**Implementation (4 hours):**
- PortalController for creating Stripe portal sessions
- Return URL handling and redirect logic
- Error handling for portal creation failures
- Integration with existing user dashboard

**Testing Requirements (2 hours):**
- POST /portal creates valid portal session URL
- Authentication required for portal access
- Successful redirect to Stripe portal
- Portal return URL redirects to correct dashboard section
- Error handling when Stripe portal is unavailable

### Task 6: Plan Management & Authorization (14 hours)
**Implementation (7 hours):**
- Plan configuration service/model
- Feature access control system throughout application
- Usage limit enforcement and tracking
- Plan upgrade/downgrade eligibility rules
- Integration with existing authorization system

**Testing Requirements (7 hours):**
- can_access?(feature, plan) returns correct permissions
- usage_remaining(user, feature) calculates correctly
- enforce_limits blocks over-limit actions appropriately
- Plan upgrade/downgrade eligibility rules work correctly
- Controller integration tests: premium features blocked for basic users
- Upgrade prompts shown for restricted features
- Usage limits enforced in relevant controllers

### Task 7: Payment UI Components (12 hours)
**Implementation (8 hours):**
- Phlex payment form components with Stripe Elements
- Plan selection and comparison interface
- Subscription status and billing information display
- Payment method management components
- Loading states and error handling in UI

**Testing Requirements (4 hours):**
- PaymentFormComponent renders Stripe elements correctly
- PlanSelectionComponent shows available plans and pricing
- SubscriptionStatusComponent displays current plan information
- Components handle nil/empty states gracefully
- Integration tests: payment form submission flows
- Plan selection updates subscription correctly

## Tasks Created
- [ ] #43 - Pay Installation & User Integration (parallel: true)
- [ ] #44 - Payment & Subscription Controllers (parallel: false) 
- [ ] #45 - Subscription Business Logic Services (parallel: false)
- [ ] #46 - Custom Webhook Processors (parallel: true)
- [ ] #47 - Customer Portal Integration (parallel: true)
- [ ] #48 - Plan Management & Authorization (parallel: false)
- [ ] #49 - Payment UI Components (parallel: false)

Total tasks: 7
Parallel tasks: 3
Sequential tasks: 4
Estimated total effort: 78 hours (46% testing focus)

## Estimated Effort

**Overall Timeline**: 1.5-2 weeks (significantly reduced with Pay gem)
**Total Hours**: 78 hours (Implementation: 42 hours, Testing: 36 hours)
**Resource Requirements**: 1-2 developers with Rails experience (payment processing simplified by Pay)

**Task-by-Task Breakdown**:
- **Task 1**: Pay Installation & User Integration (8 hours: 3 impl + 5 test)
- **Task 2**: Payment & Subscription Controllers (16 hours: 8 impl + 8 test)
- **Task 3**: Subscription Business Logic Services (12 hours: 6 impl + 6 test) 
- **Task 4**: Custom Webhook Processors (10 hours: 6 impl + 4 test)
- **Task 5**: Customer Portal Integration (6 hours: 4 impl + 2 test)
- **Task 6**: Plan Management & Authorization (14 hours: 7 impl + 7 test)
- **Task 7**: Payment UI Components (12 hours: 8 impl + 4 test)

**Critical Path Items**:
- Pay gem installation and User model integration (1 day)
- Controller implementation with comprehensive testing (2 days) 
- Subscription business logic and service layer (1.5 days)
- Plan management and authorization system (2 days)
- UI components and integration testing (1.5 days)

**Testing Focus**: 46% of effort dedicated to testing our business logic, not Pay gem internals