# TODO: needs a spec.
# but a unit test would make coverage more robust
class InvitationReminderSms < ApplicationSms
  attr_reader :to, :invitations

  def initialize(to:, invitations:)
    super
    @to = to
    @invitations = invitations
  end

  def body
    msg = "You have #{inv_count} session#{inv_count > 1 ? 's': ''} soon.\n"
    invitations.each_with_index do |inv, idx|
      msg +=  "##{idx}) #{inv.start_datetime_human} with #{inv.user.name}\n"
    end

    msg += "Cancel by replying with the # of the session\n"
    msg += "like '1' to cancel session #1)\n"
    msg += "or respond 'All' to cancel all."
  end

  def inv_count
    @invitations.size
  end

end
