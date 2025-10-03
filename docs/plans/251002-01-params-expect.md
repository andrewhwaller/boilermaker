# Update Controllers to Rails 8 params.expect Pattern

## Objective
Update all controllers to use Rails 8 `params.expect` pattern instead of `params.require().permit()` or `params.permit()`.

## Pattern
- Nested params: `params.require(:account).permit(:name)` → `params.expect(account: [:name])`
- Flat params without defaults: `params.permit(:password, :password_confirmation)` → Keep using `params.permit()` (expect() doesn't work well for flat params)
- Flat params with defaults: Keep using `params.permit().with_defaults()` (expect() returns array, can't chain with_defaults)

## Tasks

### Controller Updates
- [x] app/controllers/accounts_controller.rb:66
- [x] app/controllers/account/users_controller.rb:90
- [x] app/controllers/account/dashboards_controller.rb:25
- [x] app/controllers/account/settings_controller.rb:27
- [x] app/controllers/passwords_controller.rb:36
- [x] app/controllers/identity/emails_controller.rb:45
- [x] app/controllers/identity/invitation_acceptances_controller.rb:36
- [x] app/controllers/identity/password_resets_controller.rb:40

### Testing
- [x] Review test coverage for parameter handling
- [x] Write tests for any controllers missing parameter handling tests
- [x] Add test for Identity::InvitationAcceptancesController
- [x] Add unverified_user fixture for testing

## Restructure to Nested Params (New Tasks)

### Phase 2: Convert Flat Params to Nested Params
The following controllers use flat params with `params.expect()`. They will be converted to use nested params under `user:` key so they can consistently use `params.expect(user: [...])`:

- [x] PasswordsController: Convert to `params.expect(user: [:password, :password_confirmation, :password_challenge])`
  - [x] Update controller user_params method
  - [x] Update view form field names to `user[field]`
  - [x] Update test params to nest under `user:`

- [x] Identity::EmailsController: Convert to `params.expect(user: [:email, :password_challenge])`
  - [x] Update controller user_params method
  - [x] Update view form field names to `user[field]`
  - [x] Update test params to nest under `user:`

- [x] Identity::PasswordResetsController: Convert to `params.expect(user: [:password, :password_confirmation])`
  - [x] Update controller user_params method
  - [x] Update view form field names to `user[field]`
  - [x] Update test params to nest under `user:`

## Implementation Notes

### Controllers Now Using params.expect with Nested Params:
- **AccountsController**: `params.expect(account: [:name])`
- **Account::UsersController**: `params.expect(user: [:email, :first_name, :last_name])`
- **Account::DashboardsController**: `params.expect(account: [:name])`
- **Account::SettingsController**: `params.expect(account: [:name])`
- **Identity::InvitationAcceptancesController**: `params.expect(user: [:password, :password_confirmation])`
- **PasswordsController**: `params.expect(user: [:password, :password_confirmation, :password_challenge]).with_defaults(password_challenge: "")`
- **Identity::EmailsController**: `params.expect(user: [:email, :password_challenge]).with_defaults(password_challenge: "")`
- **Identity::PasswordResetsController**: `params.expect(user: [:password, :password_confirmation])`

### Key Changes in Phase 2:
All three controllers now consistently use:
- Nested params under `user:` key
- `params.expect(user: [...])` for strong parameters
- Form field names like `user[password]` instead of flat `password`
- Test params nested under `user:` key
- `.with_defaults()` still works with nested params (unlike flat params)

### Tests Added:
- Created comprehensive test suite for Identity::InvitationAcceptancesController
- Added unverified_user fixture to support invitation acceptance testing
- All controller tests updated to use nested params structure
