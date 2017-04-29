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
    invitations.each do |inv|
      next if inv.end_datetime < Time.current # don't remind people of past events
      msg +=  "#{inv.sms_description} on #{inv.start_datetime_human} for #{inv.duration / 60} minutes with #{inv.user.name} tel: #{inv.user.phone_number} \n"
    end
    msg += "Reply 'OK' to confirm\n"
    msg += "Reply 'No' to cancel\n"
    msg += "Reply 'Calendar' to see your upcoming sessions\n"
    msg += 'Thanks!'
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def inv_count
    @invitations.size
  end

  def body
    if @invitations.blank?
      %(You have no upcoming sessions.)
    else
      generate_res_msgs
    end
  end

end
