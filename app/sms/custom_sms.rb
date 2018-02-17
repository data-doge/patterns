

# frozen_string_literal: true

# TODO: needs a spec. The spec for SmsinvitationsController covers it,
# but a unit test would make coverage more robust
class CustomSms < ApplicationSms
  attr_reader :to, :body

  def initialize(to:, msg:)
    super
    @to = to
    @msg = msg
  end

  def body
    @msg
  end
end
