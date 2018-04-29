# frozen_string_literal: true

# == Schema Information
#
# Table name: activation_calls
#
#  id                 :integer          not null, primary key
#  card_activation_id :integer
#  sid                :string(255)
#  transcript         :string(255)
#  audio_url          :string(255)
#  call_type          :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  status             :string(255)      default("created")
#

class ActivationCall < ApplicationRecord
  has_paper_trail
  has_secure_token
  validates_presence_of :card_activation_id
  validates_presence_of :call_type
  validates_inclusion_of :call_type, in: %w[activate check] # balance soon
  belongs_to :card_activation, dependent: :destroy
  after_commit :enqueue_call, on: :create
  scope :checks, -> {where(call_type: 'check')}
  scope :activations, -> {where(call_type: 'activation')}

  def transcript_check
    # this will be very different.
    # needs more subtle checks for transcription errors. pehaps distance?
    transcript.downcase.include? type_transcript
  end

  def type_transcript
    case call_type
    when 'activate'
      'your card now has been activated'
    when 'check'
      'the available balance on this account'
    when 'balance' # not yet implemented. but could be
      'the available balance'
    end
  end

  def can_be_updated?
    call_status == 'started'
  end

  def balance
    if transcript.present? && call_type == 'check'
      regex = Regexp.new('\$\ ?[+-]?[0-9]{1,3}(?:,?[0-9])*(?:\.[0-9]{1,2})?')
      transcript.scan(regex)[0]&.delete("$")&.to_money || card_activation.amount
    else
      card_activation.amount
    end
  end

  def call
    sid.nil? ? nil : $twilio.calls.get(sid)
  end

  def success
    self.call_status = 'success'
    card_activation.success
  end

  def failure
    self.call_status = 'failure'
    case call_type
    when 'activate'
      card_activation.activation_error
    when 'check'
      card_activation.check_error
    end
  end

  def enqueue_call
    Delayed::Job.enqueue(ActivationCallJob.new(id)).save
  end
end
