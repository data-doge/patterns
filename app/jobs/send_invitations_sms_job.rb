# frozen_string_literal: true

# FIXME: Refactor and re-enable cop
#
class SendInvitationsSmsJob
  include Sidekiq::Worker
  sidekiq_options retry: 1

  # FIXME: Refactor and Enable Cops!

  def perform(person_id, invitation_id, type)
    person = Person.find person_id
    invitation = Invitation.find invitation_id
    Rails.logger.info '[SendInvitationsSms] job enqueued'
    # TODO: all texts should consider the persons' state with a ttl.
    # step 1: check to see if we already have a conversation for the person
    #   yes: get ttl and re-enque for after ttl
    #   no: go to step 2
    # step 2: check if we are after hours
    #   yes: requeue for 8:30am
    #   no: set context with expire and send!
    if time_requeue?
      Rails.logger.info '[SendInvitationsSms] job re-enqueued for business hours'
      SendInvitationsSmsJob.perform_at(run_in_business_hours, person.id, invitation.id, type)
    else # person is locked, wait till the lock times out.
      case type.to_sym
      when :invite
        ::InvitationSms.new(to: person, invitation: invitation).send
      when :cancel
        ::InvitationCancelSms.new(to: person, invitation: invitation).send
      when :confirm
        ::InvitationConfirmSms.new(to: person, invitation: invitation).send
      when :remind
        ::InvitationReminderSms.new(to: person, invitations: [invitation]).send
      end

    end
  end
  # rubocop:enable

  private

    def time_requeue?
      # yes if before 8:30am and yes if after 8pm
      return true if Time.current < DateTime.current.change({ hour: 8, minute: 30 })
      return true if Time.current > DateTime.current.change({ hour: 20, minute: 0 })
      false
    end

    def run_in_business_hours   # different run_at times
      if Time.current > Time.zone.parse('20:00')
        DateTime.tomorrow.change({ hour: 8, minute: 30 })
      elsif Time.current < Time.zone.parse('8:00')
        DateTime.current.change({ hour: 8, minute: 30 })
      end
    end
end
# rubocop:enable Style/StructInheritance
