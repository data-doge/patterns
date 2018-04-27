# records card details for activation and check calls
class CardActivation < ApplicationRecord
  include AASM
  
  has_paper_trail
  validate :luhn_number_valid
  validates_presence_of :expiration_date
  validates_presence_of :batch_id
  validates_presence_of :sequence_number
  validates_presence_of :expiration_date
  validates_presence_of :user_id
  validates_presence_of :secure_code
  validates :gift_card_id, uniqueness: true, allow_nil: true

  # see force_immutable below. do we not want to allow people to
  # change the assigned activation to gift card? unclear
  #IMMUTABLE = %w{gift_card_id}
  #validate :force_immutable

  has_many :activation_calls, dependant: :destroy
  has_one  :gift_card

  after_create :do_activate_call
  after_update :do_check_call

  aasm column: 'status', requires_lock: true do
    state :created, initial: true
    state :start_activation
    state :activation_errored
    state :check_started
    state :check_errored
    state :active

    event :start_activation, before_commit: :do_activate_call do
      transitions from: :created, to: :start_activation
    end
   
    event :activation_success do
      transitions from: :start_activation, to: :active
    end
    
    event :activation_error, after_commit: :actition_error_report do
      transitions from: :start_activation, to: :activation_errored
    end

    event :start_check, before_commit: :do_check do
      transitions from: %i[activation_error,check_errored,active], 
                  to: :check_started
    end
    
    event :check_error do
      transitions from: :check_started, to: :check_errored 
    end

    event :check_success do
      transitions from: :check_started, to: :active
    end
  end
  

  def do_activate_call
    
  end

  def do_check_call
    
  end

  def activation_error_report
    # call back to front end with actioncable about error
    # transition into start check
    self.start_check
  end

  private

    def luhn_number_valid
      errors.add('Must include a card number') if full_card_number.blank?
      unless CreditCardValidations::Luhn.valid?(full_card_number)    
        errors.add('card number is not valid')
      end
    end

    # gift_card_id can't change one set.
    # dunno if we really want it.
    def force_immutable
      if self.persisted?
        IMMUTABLE.each do |attr|
          next if self[attr].nil? # allow updates to nil
          self.changed.include?(attr) &&
            errors.add(attr, :immutable) &&
            self[attr] = self.changed_attributes[attr]
        end
      end
    end
end
