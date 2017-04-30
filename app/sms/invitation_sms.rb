# TODO: needs a spec. The spec for SmsinvitationsController covers it,
# but a unit test would make coverage more robust
class InvitationSms < ApplicationSms
  attr_reader :to, :invitation

  def initialize(to:, invitation:)
    super
    @to = to
    @invitation = invitation
  end

  private

    def body
      msg = "A #{duration} minute session has been scheduled:\n"
      msg += "When: #{selected_time}\n"
      msg += "Where: #{invitation.location}\n"
      msg += "With: #{invitation.user.name}, \n"
      msg += "Tel: #{invitation.user.phone_number}\n."
      msg += "\n"
      msg += "Reply 'OK' to confirm\n"
      msg += "Reply 'No' to cancel\n"
      msg += "Reply 'Calendar' to see your upcoming sessions\n"
    end

    def selected_time
      invitation.start_datetime_human
    end

    def duration
      invitation.duration
    end

end
