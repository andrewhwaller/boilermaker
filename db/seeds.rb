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

# Create default admin account
admin_account = Account.create!(name: "Default")

admin_user = User.create!(
  email: "admin@example.com",
  password: "password1234",
  first_name: "Admin",
  last_name: "User",
  verified: true,
  admin: true,
  account: admin_account
)
AccountMembership.create!(user: admin_user, account: admin_account, roles: { admin: true, member: true })

# Create additional non-admin users for testing
john = User.create!(
  email: "john.doe@example.com",
  password: "password1234",
  first_name: "John",
  last_name: "Doe",
  verified: true,
  admin: false,
  account: admin_account
)
AccountMembership.create!(user: john, account: admin_account, roles: { member: true, admin: false })

jane = User.create!(
  email: "jane.smith@example.com",
  password: "password1234",
  first_name: "Jane",
  last_name: "Smith",
  verified: true,
  admin: false,
  account: admin_account
)
AccountMembership.create!(user: jane, account: admin_account, roles: { member: true, admin: false })

bob = User.create!(
  email: "bob.wilson@example.com",
  password: "password1234",
  first_name: "Bob",
  last_name: "Wilson",
  verified: false,
  admin: false,
  account: admin_account
)
AccountMembership.create!(user: bob, account: admin_account, roles: { member: true, admin: false })

alice = User.create!(
  email: "alice.johnson@example.com",
  password: "password1234",
  first_name: "Alice",
  last_name: "Johnson",
  verified: true,
  admin: true,
  account: admin_account
)
AccountMembership.create!(user: alice, account: admin_account, roles: { admin: true, member: true })
