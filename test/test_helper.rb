ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/mock"
require "active_job/test_helper"

module ActiveSupport
  class TestCase
    include ActiveJob::TestHelper
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

module ActionDispatch
  class IntegrationTest
    def sign_in_as(user, account = nil)
      post sign_in_url, params: {email: user.email, password: "Secret1*3*5*"}
      if account
        session = user.sessions.last
        session.update!(account: account) if session
      end
      user
    end
  end
end
