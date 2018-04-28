# frozen_string_literal: true

#

# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
run Logan::Application

if Rails.env.production?
  DelayedJobWeb.use Rack::Auth::Basic do |username, password|
    ActiveSupport::SecurityUtils.secure_compare('admin', username) &&
      ActiveSupport::SecurityUtils.secure_compare(ENV['DJ_PASSWORD'], password)
  end
end
