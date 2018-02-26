

# frozen_string_literal: true

# TODO: needs a spec.
# but a unit test would make coverage more robust
class InvitationReminderSms < ApplicationSms
  attr_reader :to, :invitations

  def initialize(to:, invitations:)
    super
    @to = to
    @invitations = invitations
  end

  def generate_res_msgs
    msg = "You have #{inv_count} session#{inv_count > 1 ? 's': ''} soon.\n"
    msg += "--------------------\n"
    invitations.each do |inv|
      next if inv.end_datetime < Time.current # don't remind people of past events
      msg += "What: #{inv.sms_description}\n\n"
      msg += "When: #{inv.start_datetime_human}\n"
      msg += "Where: #{inv.location}\n"
      msg += "With #{inv.user.name}, tel: #{inv.user.phone_number}\n"
      msg += "--------------------\n"
    end
    msg += "\n"
    msg += "Reply 'OK' to confirm\n"
    msg += "Reply 'No' to cancel\n"
    msg += "Reply 'Calendar' to see your upcoming sessions\n"
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def inv_count
    @invitations.size
  end

  def body
    if @invitations.blank?
      %(You have no upcoming sessions. Reply 'Calendar' to check again!)
    else
      generate_res_msgs
    end
  end

end
