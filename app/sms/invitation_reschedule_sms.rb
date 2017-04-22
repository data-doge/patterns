# TODO: needs a spec. The spec for SmsinvitationsController covers it,
# but a unit test would make coverage more robust
class InvitationRescheduleSms < ApplicationSms
  attr_reader :to, :invitation

  def initialize(to:, invitation:)
    super
    @to = to # only really people here.
    @invitation = invitation
  end

  def body
    "It looks like we'll need to reschedule the #{duration} minute interview for #{selected_time}.\n#{invitation.user.name} will get in touch with you soon.\nTheir number is #{invitation.user.phone_number}"
  end

  private

    def selected_time
      invitation.time_slot.start_datetime_human
    end

    def duration
      invitation.duration / 60
    end
end
