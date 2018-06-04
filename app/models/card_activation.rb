# frozen_string_literal: true

# == Schema Information
#
# Table name: card_activations
#
#  id               :bigint(8)        not null, primary key
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
#  created_by       :integer
#

# records card details for activation and check calls
class CardActivation < ApplicationRecord
  include AASM
  page 20
  monetize :amount_cents
  attr_accessor :old_user_id

  has_paper_trail

  validate :luhn_number_valid
  validates_presence_of :expiration_date
  validates_presence_of :batch_id
  validates_presence_of :sequence_number
  validates_presence_of :expiration_date
  validates_presence_of :user_id
  validates_presence_of :secure_code
  validates :gift_card_id, uniqueness: true, allow_nil: true

  validates_format_of :expiration_date,
    with:  %r{\A(0|1)([0-9])\/([0-9]{2})\z}i

  validates_format_of :batch_id, with: /[0-9]*/
  validates_format_of :secure_code, with: /[0-9]*/
  validates_format_of :sequence_number, with: /[0-9]*/
  # sequences are per batch
  validates_uniqueness_of :sequence_number, scope: :batch_id

  scope :unassigned, -> { where(gift_card_id: nil) }
  scope :assigned, -> { where.not(gift_card_id: nil) }
  default_scope { order(sequence_number: :asc) }
  # see force_immutable below. do we not want to allow people to
  # change the assigned activation to gift card? unclear
  # IMMUTABLE = %w{gift_card_id}
  # validate :force_immutable

  has_many :activation_calls, dependent: :destroy
  alias_attribute :calls, :activation_calls

  belongs_to :gift_card, optional: true
  belongs_to :user

  before_create :scrub_input
  before_create :set_created_by

  # starts activation call process on create after commit happens
  # only hook we're using here
  # after_commit :create_activation_call, on: :create

  # uses action cable to update card.
  after_commit :update_front_end, on: :update

  def self.import(file, user)
    errors = []
    xls =  Roo::Spreadsheet.open(file)
    cols = {full_card_number:'full_card_number',expiration_date:'expiration_date',amount:'amount',sequence_number:'sequence_number',secure_code:'secure_code',batch_id:'batch_id'}
    xls.sheet(0).each(cols) do |row|
      next if row[:full_card_number].blank? ||  row[:full_card_number] == 'full_card_number'# empty rows
      ca = CardActivation.new(cleaned_row)
      ca.user_id = user.id
      ca.created_by = user.id
      # results is an array of errored card activatoins
      if ca.save
        ca.start_activate!
      else
         if ca.errors.present?
          err_msg = "Card Error: sequence: #{ca.sequence_number}, #{ca.full_card_number}, #{ca.errors[:base]}"
          Airbrake.notify(err_msg)
          logger.info(err_msg)
          errors << ca
        end
      end
    end
    errors
  end

  aasm column: 'status', requires_lock: true do
    state :created, initial: true
    state :activate_started
    state :activate_errored
    state :check_started
    state :check_errored
    state :active

    event :start_activate, after_commit: :create_activation_call do
      transitions from: %i[created activate_started], to: :activate_started
    end

    event :activate_error, after_commit: :activation_error_report do
      transitions from: [:activate_started,:activate_errored], to: :activate_errored
    end

    event :start_check, after_commit: :create_check_call do
      transitions from: %i[activate_errored check_errored active],
                  to: :check_started
    end

    # after_commit here because we want to ensure that
    # the history is present
    event :check_error, after_commit: :create_check_call do
      transitions from: %i[activate_started check_started activate_errored active check_errored], to: :check_errored
    end

    event :success, after_commit: :do_success_notification do
      transitions to: :active
    end
  end

  def create_activation_call
    ActivationCall.create(card_activation_id: id, call_type: 'activate')
  end

  # override allows manual check calls
  def create_check_call(override: false)
    if override || activation_calls.where(call_type: 'check').size < 5
      ActivationCall.create(card_activation_id: id, call_type: 'check')
    end
  end

  def do_success_notification
    # action cable update to front end.
    true
  end

  def activation_error_report
    # transition into start check
    start_check
  end

  # almost always backend
  def update_front_end
    # if assigned, delete.
    # otherwise, update
    if gift_card_id.nil?
      User.admin.each { |u|  broadcast_update(u) }
      broadcast_update
    else
      User.admin.each { |u|  broadcast_delete(u) }
      broadcast_delete
    end
  end

  def last_balance
    ca = calls.checks.order(created_at: 'DESC').first
    ca.nil? ? amount : ca.balance
  end

  def last_4
    full_card_number.to_s.last(4)
  end

  def sort_helper
    case status
    when 'active'
      5
    when 'activate_started'
      4
    when 'check_started'
      3
    when 'created'
      2
    when 'activate_errored'
      1
    when 'check_errored'
      0
    end
  end

  def label
    case status
    when 'active'
      'success'
    when 'activate_started'
      'warning'
    when 'check_started'
      'warning'
    when 'created'
      'warning'
    when 'activate_errored'
      'important'
    when 'check_errored'
      'important'
    end
  end

  def update_balance
    create_check_call(override: true)
  end

  def ongoing_call?
    return false if active? # there may be, but we don't care.
    calls.ongoing.size.positive?
  end

  def can_run_check?
    return false if active? # don't run any more checks if active
    !active? && !ongoing_call?
  end

  private

    def Scrub_input # sometimes we drop leading 0's in csv
      secure_code = secure_code.gsub('.0', '')
      sequence_number = sequence_number.gsub('.0', '')
      batch_id = batch_id.gsub('.0', '')
      secure_code.prepend('0') while secure_code.length < 3
    end

    def set_created_by
      self.created_by = user_id
    end

    def broadcast_update(c_user = nil)
      current_user = c_user.nil? ? user : c_user
      ActionCable.server.broadcast "activation_event_#{current_user.id}_channel",
        type: :update,
        id: id,
        large: render_large_card_activation(current_user),
        mini: render_mini_card_activation(current_user)
    end

    def broadcast_delete(c_user = nil)
      current_user = c_user.nil? ? user : c_user
      ActionCable.server.broadcast "activation_event_#{current_user.id}_channel",
        type: :delete,
        id: id
    end

    def render_large_card_activation(c_user = nil)
      current_user = c_user.nil? ? user : c_user
      ApplicationController.render partial: 'card_activations/single_card_activation',
        locals: { card_activation: self, current_user: current_user }
    end

    def render_mini_card_activation(c_user = nil)
      current_user = c_user.nil? ? user : c_user
      ApplicationController.render partial: 'card_activations/card_activation_mini',
      locals: { card_activation: self, current_user: current_user }
    end

    def luhn_number_valid
      errors[:base].push('Must include a card number.') if full_card_number.blank?
      errors[:base].push('Card Number is not long enough.') if full_card_number.length != 16
      unless CreditCardValidations::Luhn.valid?(full_card_number)
        errors[:base].push("Card number #{full_card_number} is not valid.")
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
