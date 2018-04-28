# frozen_string_literal: true

# == Schema Information
#
# Table name: card_activations
#
#  id               :integer          not null, primary key
#  full_card_number :string(255)
#  expiration_date  :string(255)
#  sequence_number  :string(255)
#  secure_code      :string(255)
#  batch_id         :string(255)
#  status           :string(255)      default("created")
#  user_id          :integer
#  gift_card_id     :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  amount_cents     :integer          default(0), not null
#  amount_currency  :string(255)      default("USD"), not null
#

# records card details for activation and check calls
class CardActivation < ApplicationRecord
  include AASM

  monetize :amount_cents

  has_paper_trail

  validate :luhn_number_valid
  validates_presence_of :expiration_date
  validates_presence_of :batch_id
  validates_presence_of :sequence_number
  validates_presence_of :expiration_date
  validates_presence_of :user_id
  validates_presence_of :secure_code
  validates :gift_card_id, uniqueness: true, allow_nil: true

  scope :unassigned, -> { where(gift_card_id: nil) }
  scope :assigned, -> { where.not(gift_card_id: nil) }

  # see force_immutable below. do we not want to allow people to
  # change the assigned activation to gift card? unclear
  # IMMUTABLE = %w{gift_card_id}
  # validate :force_immutable

  has_many :activation_calls, dependent: :destroy
  alias_attribute :calls, :activation_calls

  belongs_to :gift_card, optional: true

  # starts activation process on create after commit happens
  after_commit :create_activation_call, on: :create

  aasm column: 'status', requires_lock: true do
    state :created, initial: true
    state :activation_started
    state :activation_errored
    state :check_started
    state :check_errored
    state :active

    event :start_activation do
      transitions from: :created, to: :activation_started
    end

    event :activation_error, after_commit: :actition_error_report do
      transitions from: :activation_started, to: :activation_errored
    end

    event :start_check, after_commit: :create_check_call do
      transitions from: %i[activation_errored check_errored active],
                  to: :check_started
    end

    # after_commit here because we want to ensure that
    # the history is present
    event :check_error, after_commit: :create_check_call do
      transitions from: [:check_started,:active,:check_errored], to: :check_errored
    end

    event :success, after_commit: :do_success_notification do
      transitions to: :active
    end
  end

  def create_activation_call
    start_activation
    ActivationCall.create(card_activation_id: id, call_type: 'activate')
  end

  # override allows manual check calls
  def create_check_call(override: false)
    if !override && activation_calls.where(call_type: 'check').size < 5
      ActivationCall.create(card_activation_id: id, call_type: 'check')
    end
  end

  def do_success_notification
    # action cable update to front end.
  end

  def activation_error_report
    # call back to front end with actioncable about error
    # transition into start check
    start_check
  end

  def check_error_report
    # action cable update to front end.
  end

  def assign(gc_id)
    gift_card_id = gc_id
    save
  end

  private

    def luhn_number_valid
      errors.add('Must include a card number.') if full_card_number.blank?
      unless CreditCardValidations::Luhn.valid?(full_card_number)
        errors.add("Card number #{full_card_number} is not valid.")
      end
    end

    # gift_card_id can't change one set.
    # dunno if we really want it.
    def force_immutable
      if persisted?
        IMMUTABLE.each do |attr|
          next if self[attr].nil? # allow updates to nil
          changed.include?(attr) &&
            errors.add(attr, :immutable) &&
            self[attr] = changed_attributes[attr]
        end
      end
    end
end
