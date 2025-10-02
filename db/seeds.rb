# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

AccountMembership.destroy_all
User.destroy_all
Account.destroy_all

# Create admin user first (no account association on User model anymore)
admin_user = User.create!(
  email: "admin@example.com",
  password: "password1234",
  first_name: "Admin",
  last_name: "User",
  verified: true,
  app_admin: true
)

# Create default team account owned by admin
admin_account = Account.create!(
  name: "Default Team",
  owner: admin_user,
  personal: false
)

# Create membership linking admin to their account
AccountMembership.create!(
  user: admin_user,
  account: admin_account,
  roles: { admin: true, member: true }
)

# Create additional non-admin users for testing
john = User.create!(
  email: "john.doe@example.com",
  password: "password1234",
  first_name: "John",
  last_name: "Doe",
  verified: true,
  app_admin: false
)
AccountMembership.create!(
  user: john,
  account: admin_account,
  roles: { member: true, admin: false }
)

jane = User.create!(
  email: "jane.smith@example.com",
  password: "password1234",
  first_name: "Jane",
  last_name: "Smith",
  verified: true,
  app_admin: false
)
AccountMembership.create!(
  user: jane,
  account: admin_account,
  roles: { member: true, admin: false }
)

bob = User.create!(
  email: "bob.wilson@example.com",
  password: "password1234",
  first_name: "Bob",
  last_name: "Wilson",
  verified: false,
  app_admin: false
)
AccountMembership.create!(
  user: bob,
  account: admin_account,
  roles: { member: true, admin: false }
)

alice = User.create!(
  email: "alice.johnson@example.com",
  password: "password1234",
  first_name: "Alice",
  last_name: "Johnson",
  verified: true,
  app_admin: true
)
AccountMembership.create!(
  user: alice,
  account: admin_account,
  roles: { admin: true, member: true }
)

puts "✅ Seeded database with:"
puts "  - 1 team account (Default Team)"
puts "  - 5 users (2 admins, 3 regular users)"
puts "  - 5 account memberships"
puts "\nAdmin credentials:"
puts "  Email: admin@example.com"
puts "  Password: password1234"
