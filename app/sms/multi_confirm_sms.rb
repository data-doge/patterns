# frozen_string_literal: true

# TODO: needs a spec.
# but a unit test would make coverage more robust
class MultiConfirmSms < ApplicationSms
  attr_reader :to, :invitations, :inv_hash

  def initialize(to:, invitations:, inv_hash:)
    super
    @to = to
    @invitations = invitations
    @inv_hash = inv_hash
  end

  def body
    msg = "You have #{inv_count} session#{inv_count > 1 ? 's': ''} soon.\n"
    @invitations.each do |inv|
      msg += "##{id_lookup(inv)}: #{inv.start_datetime_human}\n"
      msg += "            with #{inv.user.name}\n"
      msg += "-\n"
    end

    msg += "Confirm by replying with the # of the session\n"
    msg += "like '1' to confirm session #1)\n"
    msg += "Reply 'All' to confirm all.\n"
    msg += "Reply 'None' if you don't want to confirm now.\n"
  end

  def inv_count
    @invitations.size
  end

  def id_lookup(inv)
    @inv_hash.key(inv.id)
  end
end
