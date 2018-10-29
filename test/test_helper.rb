ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'coveralls'
Coveralls.wear_merged!('rails')

class ActiveSupport::TestCase

  ActiveRecord::Migration.check_pending!

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

end

class ActionController::TestCase

  include Devise::TestHelpers

  def setup
    @user = users(:admin)
    sign_in @user
  end

end

# keep this at the bottom, pls
require 'mocha/setup'
