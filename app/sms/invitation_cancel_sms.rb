# TODO: needs a spec. The spec for SmsinvitationsController covers it,
# but a unit test would make coverage more robust
class InvitationCancelSms < ApplicationSms
  attr_reader :to, :invitation

  def initialize(to:, invitation:)
    super
    @to = to # only really people here.
    @invitation = invitation
  end

  def body
    %Q(You have cancelled your session with #{usename} at #{selected_time}.\n Thanks for the heads-up!)
  end

  def selected_time
    invitation.start_datetime_human
  end

  def username
    invitation.user.name
  end
end
