# == Schema Information
#
# Table name: activation_calls
#
#  id                 :integer          not null, primary key
#  card_activation_id :integer
#  sid                :string(255)
#  transcript         :string(255)
#  audio_url          :string(255)
#  type               :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class ActivationCall < ApplicationRecord
  has_paper_trail
  validates_presence_of :card_activation_id
  validates_inclusion_of :type, in: %w( activate check )
  belongs_to :card_activations, dependent: :destroy

  def transcript_check
    # this will be very different.
    # needs more subtle checks for transcription errors. pehaps distance?
    transcript.include? type_transcript 
  end
 
  def type_transcript
    case type
    when 'activate'
      'your card has been activated'
    when 'check'
      'please hold while we access your account'
    when 'balance' # not yet implemented. but could be
      'the available balance'
    end
  end

end
