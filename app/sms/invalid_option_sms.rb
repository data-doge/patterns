

# frozen_string_literal: true

# TODO: needs a spec. The spec for SmsinvitationsController covers it,
# but a unit test would make coverage more robust
class InvalidOptionSms < ApplicationSms
  attr_reader :to

  def initialize(to:)
    super
    @to = to
  end

  def body
    "Sorry, I didn't understand that! I'm just a computer..."
  end
end
