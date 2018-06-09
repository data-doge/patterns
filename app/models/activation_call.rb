# frozen_string_literal: true

# == Schema Information
#
# Table name: activation_calls
#
#  id                 :bigint(8)        not null, primary key
#  card_activation_id :integer
#  sid                :string(255)
#  transcript         :text(65535)
#  audio_url          :string(255)
#  call_type          :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  call_status        :string(255)      default("created")
#  token              :string(255)
#

class ActivationCall < ApplicationRecord
  has_paper_trail
  has_secure_token

  validates :card_activation_id, presence: true
  validates :call_type, presence: true
  validates :call_type, inclusion: { in: %w[activate check] } # balance soon

  belongs_to :card_activation, dependent: :destroy
  after_commit :enqueue_call, on: :create
  after_commit :update_front_end

  alias_attribute :card, :card_activation
  scope :ongoing, -> { where(call_status: 'started') }
  scope :checks, -> { where(call_type: 'check') }
  scope :activations, -> { where(call_type: 'activation') }

  after_initialize :create_twilio

  def transcript_check
    # this will be very different.
    # needs more subtle checks for transcription errors. pehaps distance?
    return false if transcript.nil?
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
      transcript.scan(regex)[0]&.delete('$')&.to_money || card_activation.amount
    else
      card_activation.amount
    end
  end

  def call
    @call ||= sid.nil? ? nil : @twilio.calls.get(sid)
  end

  def timeout_error?
    call.status == 'completed' && (Time.current - updated_at) > 1.minute && !%w[success failure].include?(call_status)
  end

  def success
    self.call_status = 'success'
    card_activation.success!
  end

  def failure
    self.call_status = 'failure'
    card_activation.send("#{call_type}_error!".to_sym)
  end

  def enqueue_call
    ActivationCallJob.perform_async(id)
  end

  delegate :update_front_end, to: :card_activation

  private

    def create_twilio
      @twilio = Twilio::REST::Client.new
    end
end
