# TODO: needs a spec. The spec for SmsinvitationsController covers it,
# but a unit test would make coverage more robust
class IinvitationConfirmSms < ApplicationSms
  attr_reader :to, :invitation

  def initialize(to:, invitation:)
    super
    @to = to # only really people here.
    @invitation = invitation
  end

  def body
    "You have confirmed a #{duration} minute interview for #{selected_time}, with #{invitation.user.name}. \nTheir number is #{invitation.user.phone_number}"
  end

  def selected_time
    invitation.start_datetime_human
  end

  def duration
    invitation.duration / 60
  end
end
