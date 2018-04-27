class ActivationCall < ApplicationRecord
  
  has_paper_trail
  validates_presence_of :sid
  validates_presence_of :card_activation_id
  belongs_to :card_activations, dependent: :destroy

  def transcript_check
    transcript == type_transcript # this will be very different.
  end
 
  def type_transcript
    case type
    when 'activate'
      'your card has been activated'
    when 'check'
      'please hold while we access your account'
    when 'balance'
      'the available balance'
    end
  end

end
