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
      "A #{duration} minute interview has been booked for:\n#{selected_time}\nWith: #{invitation.user.name}, \nTel: #{invitation.user.phone_number}\n.You'll get a reminder that morning."
    end

    def selected_time
      invitation.time_slot.start_datetime_human
    end

    def duration
      invitation.duration / 60
    end

end
