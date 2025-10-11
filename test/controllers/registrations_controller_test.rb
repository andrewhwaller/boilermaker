require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    ActionMailer::Base.deliveries.clear
  end

  test "should get new registration form" do
    get sign_up_url
    assert_response :success
  end

  test "creates user with personal account when personal_accounts is enabled" do
    Boilermaker::Config.stub :personal_accounts?, true do
      perform_enqueued_jobs do
        assert_difference("User.count", 1) do
          assert_difference("Account.count", 1) do
            assert_difference("AccountMembership.count", 1) do
              post sign_up_url, params: {
                user: {
                  email: "newuser@example.com",
                  password: "SecurePassword123!",
                  password_confirmation: "SecurePassword123!"
                },
                account_name: "My Personal Account"
              }
            end
          end
        end
      end

      assert_redirected_to root_url
      assert_equal "Welcome! You have signed up successfully", flash[:notice]

      user = User.find_by(email: "newuser@example.com")
      assert_not_nil user
      assert_equal "newuser@example.com", user.email

      account = user.owned_accounts.first
      assert_not_nil account
      assert_equal "My Personal Account", account.name
      assert account.personal?
      assert_equal user, account.owner

      membership = AccountMembership.find_by(user: user, account: account)
      assert_not_nil membership
      assert membership.admin?
      assert membership.member?
      assert_equal({ "admin" => true, "member" => true }, membership.roles)

      session_record = user.sessions.last
      assert_not_nil session_record
      assert_equal account, session_record.account

      assert_equal 1, ActionMailer::Base.deliveries.size
      email = ActionMailer::Base.deliveries.last
      assert_equal [ "newuser@example.com" ], email.to
    end
  end

  test "creates user with default 'Personal' account name when personal_accounts is enabled and no name provided" do
    Boilermaker::Config.stub :personal_accounts?, true do
      post sign_up_url, params: {
        user: {
          email: "defaultname@example.com",
          password: "SecurePassword123!",
          password_confirmation: "SecurePassword123!"
        }
      }

      assert_redirected_to root_url

      user = User.find_by(email: "defaultname@example.com")
      account = user.owned_accounts.first
      assert_equal "Personal", account.name
      assert account.personal?
    end
  end

  test "creates user with default 'Personal' account name when personal_accounts is enabled and empty name provided" do
    Boilermaker::Config.stub :personal_accounts?, true do
      post sign_up_url, params: {
        user: {
          email: "emptyname@example.com",
          password: "SecurePassword123!",
          password_confirmation: "SecurePassword123!"
        },
        account_name: "   "
      }

      assert_redirected_to root_url

      user = User.find_by(email: "emptyname@example.com")
      account = user.owned_accounts.first
      assert_equal "Personal", account.name
      assert account.personal?
    end
  end

  test "creates user with team account when personal_accounts is disabled" do
    Boilermaker::Config.stub :personal_accounts?, false do
      assert_difference("User.count", 1) do
        assert_difference("Account.count", 1) do
          assert_difference("AccountMembership.count", 1) do
            post sign_up_url, params: {
              user: {
                email: "teamuser@example.com",
                password: "SecurePassword123!",
                password_confirmation: "SecurePassword123!"
              },
              account_name: "My Team Account"
            }
          end
        end
      end

      assert_redirected_to root_url

      user = User.find_by(email: "teamuser@example.com")
      assert_not_nil user

      account = user.owned_accounts.first
      assert_not_nil account
      assert_equal "My Team Account", account.name
      assert account.team?
      assert_equal user, account.owner

      membership = AccountMembership.find_by(user: user, account: account)
      assert_not_nil membership
      assert membership.admin?
      assert membership.member?

      session_record = user.sessions.last
      assert_not_nil session_record
      assert_equal account, session_record.account
    end
  end

  test "creates user with default team name when personal_accounts is disabled and no name provided" do
    Boilermaker::Config.stub :personal_accounts?, false do
      post sign_up_url, params: {
        user: {
          email: "defaultteam@example.com",
          password: "SecurePassword123!",
          password_confirmation: "SecurePassword123!"
        }
      }

      assert_redirected_to root_url

      user = User.find_by(email: "defaultteam@example.com")
      account = user.owned_accounts.first
      assert_equal "defaultteam@example.com's Team", account.name
      assert account.team?
    end
  end

  test "creates user with default team name when personal_accounts is disabled and empty name provided" do
    Boilermaker::Config.stub :personal_accounts?, false do
      post sign_up_url, params: {
        user: {
          email: "emptyteam@example.com",
          password: "SecurePassword123!",
          password_confirmation: "SecurePassword123!"
        },
        account_name: ""
      }

      assert_redirected_to root_url

      user = User.find_by(email: "emptyteam@example.com")
      account = user.owned_accounts.first
      assert_equal "emptyteam@example.com's Team", account.name
      assert account.team?
    end
  end

  test "creates session and sets cookie on successful registration" do
    Boilermaker::Config.stub :personal_accounts?, true do
      post sign_up_url, params: {
        user: {
          email: "cookietest@example.com",
          password: "SecurePassword123!",
          password_confirmation: "SecurePassword123!"
        }
      }

      user = User.find_by(email: "cookietest@example.com")
      session_record = user.sessions.last

      assert_not_nil session_record
      assert_equal user.owned_accounts.first, session_record.account
      assert_not_nil cookies[:session_token]
    end
  end

  test "does not create user when email is missing" do
    Boilermaker::Config.stub :personal_accounts?, true do
      assert_no_difference([ "User.count", "Account.count", "AccountMembership.count" ]) do
        post sign_up_url, params: {
          user: {
            email: "",
            password: "SecurePassword123!",
            password_confirmation: "SecurePassword123!"
          }
        }
      end

      assert_response :unprocessable_entity
      assert_equal 0, ActionMailer::Base.deliveries.size
    end
  end

  test "does not create user when email is invalid" do
    Boilermaker::Config.stub :personal_accounts?, true do
      assert_no_difference([ "User.count", "Account.count", "AccountMembership.count" ]) do
        post sign_up_url, params: {
          user: {
            email: "not-an-email",
            password: "SecurePassword123!",
            password_confirmation: "SecurePassword123!"
          }
        }
      end

      assert_response :unprocessable_entity
      assert_equal 0, ActionMailer::Base.deliveries.size
    end
  end

  test "does not create user when email already exists" do
    existing_user = users(:app_admin)

    Boilermaker::Config.stub :personal_accounts?, true do
      assert_no_difference([ "User.count", "Account.count", "AccountMembership.count" ]) do
        post sign_up_url, params: {
          user: {
            email: existing_user.email,
            password: "SecurePassword123!",
            password_confirmation: "SecurePassword123!"
          }
        }
      end

      assert_response :unprocessable_entity
      assert_equal 0, ActionMailer::Base.deliveries.size
    end
  end

  test "does not create user when password is too short" do
    Boilermaker::Config.stub :personal_accounts?, true do
      assert_no_difference([ "User.count", "Account.count", "AccountMembership.count" ]) do
        post sign_up_url, params: {
          user: {
            email: "shortpass@example.com",
            password: "Short1!",
            password_confirmation: "Short1!"
          }
        }
      end

      assert_response :unprocessable_entity
      assert_equal 0, ActionMailer::Base.deliveries.size
    end
  end

  test "does not create user when password confirmation does not match" do
    Boilermaker::Config.stub :personal_accounts?, true do
      assert_no_difference([ "User.count", "Account.count", "AccountMembership.count" ]) do
        post sign_up_url, params: {
          user: {
            email: "mismatch@example.com",
            password: "SecurePassword123!",
            password_confirmation: "DifferentPassword123!"
          }
        }
      end

      assert_response :unprocessable_entity
      assert_equal 0, ActionMailer::Base.deliveries.size
    end
  end

  test "does not create user when password is missing" do
    Boilermaker::Config.stub :personal_accounts?, true do
      assert_no_difference([ "User.count", "Account.count", "AccountMembership.count" ]) do
        post sign_up_url, params: {
          user: {
            email: "nopassword@example.com",
            password: "",
            password_confirmation: ""
          }
        }
      end

      assert_response :unprocessable_entity
      assert_equal 0, ActionMailer::Base.deliveries.size
    end
  end

  test "rolls back all changes when account creation fails" do
    Boilermaker::Config.stub :personal_accounts?, true do
      initial_user_count = User.count
      initial_account_count = Account.count
      initial_membership_count = AccountMembership.count

      post sign_up_url, params: {
        user: {
          email: "invalid-email",
          password: "SecurePassword123!",
          password_confirmation: "SecurePassword123!"
        }
      }

      assert_response :unprocessable_entity
      assert_equal initial_user_count, User.count
      assert_equal initial_account_count, Account.count
      assert_equal initial_membership_count, AccountMembership.count
      assert_nil User.find_by(email: "invalid-email")
      assert_equal 0, ActionMailer::Base.deliveries.size
    end
  end

  test "user becomes owner of created account" do
    Boilermaker::Config.stub :personal_accounts?, true do
      post sign_up_url, params: {
        user: {
          email: "owner@example.com",
          password: "SecurePassword123!",
          password_confirmation: "SecurePassword123!"
        }
      }

      user = User.find_by(email: "owner@example.com")
      account = Account.last

      assert_equal user, account.owner
      assert_includes user.owned_accounts, account
      assert user.can_access?(account)
      assert user.account_admin_for?(account)
    end
  end

  test "sends email verification to correct address" do
    Boilermaker::Config.stub :personal_accounts?, true do
      perform_enqueued_jobs do
        post sign_up_url, params: {
          user: {
            email: "emailverify@example.com",
            password: "SecurePassword123!",
            password_confirmation: "SecurePassword123!"
          }
        }
      end

      assert_equal 1, ActionMailer::Base.deliveries.size
      email = ActionMailer::Base.deliveries.last

      assert_equal [ "emailverify@example.com" ], email.to
      assert_match /verify.*email/i, email.subject.to_s
    end
  end

  test "newly created user is not verified" do
    Boilermaker::Config.stub :personal_accounts?, true do
      post sign_up_url, params: {
        user: {
          email: "unverified@example.com",
          password: "SecurePassword123!",
          password_confirmation: "SecurePassword123!"
        }
      }

      user = User.find_by(email: "unverified@example.com")
      assert_not user.verified?
    end
  end

  test "account membership has both admin and member roles set to true" do
    Boilermaker::Config.stub :personal_accounts?, true do
      post sign_up_url, params: {
        user: {
          email: "roles@example.com",
          password: "SecurePassword123!",
          password_confirmation: "SecurePassword123!"
        }
      }

      user = User.find_by(email: "roles@example.com")
      membership = user.account_memberships.first

      assert_equal true, membership.roles["admin"]
      assert_equal true, membership.roles["member"]
      assert_equal 2, membership.roles.keys.size
    end
  end

  test "handles email normalization correctly" do
    Boilermaker::Config.stub :personal_accounts?, true do
      post sign_up_url, params: {
        user: {
          email: "  UPPERCASE@EXAMPLE.COM  ",
          password: "SecurePassword123!",
          password_confirmation: "SecurePassword123!"
        }
      }

      assert_redirected_to root_url

      user = User.find_by(email: "uppercase@example.com")
      assert_not_nil user
      assert_equal "uppercase@example.com", user.email
    end
  end

  test "creates distinct accounts for each user registration" do
    Boilermaker::Config.stub :personal_accounts?, true do
      post sign_up_url, params: {
        user: {
          email: "user1@example.com",
          password: "SecurePassword123!",
          password_confirmation: "SecurePassword123!"
        }
      }

      user1 = User.find_by(email: "user1@example.com")
      account1 = user1.owned_accounts.first

      post sign_up_url, params: {
        user: {
          email: "user2@example.com",
          password: "SecurePassword123!",
          password_confirmation: "SecurePassword123!"
        }
      }

      user2 = User.find_by(email: "user2@example.com")
      account2 = user2.owned_accounts.first

      assert_not_equal account1.id, account2.id
      assert_not_equal user1.id, user2.id
      assert user1.can_access?(account1)
      assert_not user1.can_access?(account2)
      assert user2.can_access?(account2)
      assert_not user2.can_access?(account1)
    end
  end

  test "user has exactly one owned account after registration" do
    Boilermaker::Config.stub :personal_accounts?, true do
      post sign_up_url, params: {
        user: {
          email: "singleaccount@example.com",
          password: "SecurePassword123!",
          password_confirmation: "SecurePassword123!"
        }
      }

      user = User.find_by(email: "singleaccount@example.com")
      assert_equal 1, user.owned_accounts.count
      assert_equal 1, user.accounts.count
      assert_equal 1, user.account_memberships.count
    end
  end
end
