# frozen_string_literal: true

# app/jobs/twilio/send_messages.rb
#
# module TwilioSender
# Send twilio messages to a list of phone numbers
#
# FIXME: Refactor and re-enable cop
# rubocop:disable Style/StructInheritance
#
class SendInvitationsSmsJob < Struct.new(:to, :invitation)

  def enqueue(job)
    Rails.logger.info '[SendInvitationsSms] job enqueued'
    job.save!
  end

  def max_attempts
    1
  end

  # FIXME: Refactor and Enable Cops!

  def perform
    # TODO: all texts should consider the persons' state with a ttl.
    # step 1: check to see if we already have a conversation for the person
    #   yes: get ttl and re-enque for after ttl
    #   no: go to step 2
    # step 2: check if we are after hours
    #   yes: requeue for 8:30am
    #   no: set context with expire and send!
    if time_requeue?
      Delayed::Job.enqueue(SendInvitationsSmsJob.new(to, invitation), run_at: run_in_business_hours)
    else # person is locked, wait till the lock times out.
      InvitationSms.new(to: to, invitation: invitation).send
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  def before(job); end

  def after(job); end

  def success(job); end

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
