# frozen_string_literal: true

# TODO: needs a spec. The spec for SmsinvitationsController covers it,
# but a unit test would make coverage more robust
class InvitationConfirmSms < ApplicationSms
  attr_reader :to, :invitation

  def initialize(to:, invitation:)
    super
    @to = to # only really people here.
    @invitation = invitation
  end

  def body
    msg = "You are confirmed! \n"
    msg +="When: #{selected_time}\n"
    msg +="Where: #{invitation.location}\n"
    msg +="Who: #{invitation.user.name}\n"
    msg +="Phone: #{invitation.user.phone_number}\n"
    msg += "\n"
    msg += "Reply 'No' to cancel\n"
    msg += "Reply 'Calendar' to see your upcoming sessions\n"
  end

  def selected_time
    invitation.start_datetime_human
  end

end
