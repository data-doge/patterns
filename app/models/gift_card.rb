# frozen_string_literal: true

#
# == Schema Information
#
# Table name: gift_cards
#
#  id               :integer          not null, primary key
#  gift_card_number :string(255)
#  expiration_date  :string(255)
#  person_id        :integer
#  notes            :string(255)
#  created_by       :integer
#  reason           :integer
#  amount_cents     :integer          default(0), not null
#  amount_currency  :string(255)      default("USD"), not null
#  giftable_id      :integer
#  giftable_type    :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  batch_id         :string(255)
#  sequence_number  :integer
#  active           :boolean          default(FALSE)
#  secure_code      :string(255)
#  team_id          :bigint(8)
#  finance_code     :string(255)
#

class GiftCard < ApplicationRecord
  attr_accessor :card_activation_id
  has_paper_trail
  page 50
  monetize :amount_cents

  before_destroy :unassign_card_activation
  after_create :assign_card_activation

  enum reason: {
    unknown: 0,
    signup: 1,
    user_test: 2,
    referral: 3,
    interview: 4,
    other: 5,
    focus_group: 6
  }

  belongs_to :giftable, polymorphic: true, touch: true
  belongs_to :person
  belongs_to :user, foreign_key: :created_by
  belongs_to :team

  has_one :card_activation

  validates :amount, presence: true
  validates :reason, presence: true
  validates :batch_id, presence: true
  validates :sequence_number, presence: true

  validates :expiration_date,
    format: { with:  %r{\A(0|1)([0-9])\/([0-9]{2})\z}i,
              unless: proc { |c| c.expiration_date.blank? } }

  validates :sequence_number, length: { minimum: 1, maximum: 7, unless: proc { |c| c.sequence_number.blank? } }

  validates :sequence_number,
    uniqueness: { scope: %i[batch_id gift_card_number],
                  unless: proc { |c| c.sequence_number.blank? } }

  validates :gift_card_number,
    uniqueness: { scope: %i[batch_id sequence_number],
                  unless: proc { |c| c.gift_card_number.blank? } }

  validates :gift_card_number,
    format: { with:  /\A([0-9]){4,5}\z/i,
              unless: proc { |c| c.gift_card_number.blank? } }

  # Validation to limit 1 signup per person
  validates :reason, uniqueness: { scope: :person_id, if: :reason_is_signup? }

  validate :giftable_person_ownership
  # ransacker :created_at, type: :date do
  #   Arel.sql('date(created_at)')
  # end

  def reason_is_signup?
    reason == 'signup'
  end

  def research_session
    return nil if giftable.nil? && giftable_type != 'Invitation'
    giftable&.research_session # double check unnecessary, but I like it.
  end

  def self.batch_create(post_content)
    # begin exception handling

    # begin a transaction on the gift card model
    GiftCard.transaction do
      # for each gift card record in the passed json
      JSON.parse(post_content).each do |gift_card_hash|
        # create a new gift card
        GiftCard.create!(gift_card_hash)
      end # json.parse
    end # transaction
  rescue StandardError
    Rails.logger('There was a problem.')
    # exception handling
  end  # batch_create

  # rubocop:disable Metrics/MethodLength
  def self.export_csv
    CSV.generate do |csv|
      csv_column_names =  ['Gift Card ID', 'Given By', 'Team', 'FinanceCode', 'Session Title', 'Session Date', 'Sign Out Date', 'Batch ID', 'Sequence ID', 'Amount', 'Reason', 'Person ID', 'Name', 'Address', 'Phone Number', 'Email', 'Notes']
      csv << csv_column_names
      all.find_each do |gift_card|
        this_person = Person.unscoped.find gift_card.person_id
        row_items = [gift_card.id,
                     gift_card.user.name,
                     gift_card.team&.name || '',
                     gift_card.team&.finance_code || '',
                     gift_card.research_session&.title || '',
                     gift_card.research_session&.created_at&.to_date&.to_s || '',
                     gift_card.created_at.to_s(:rfc822),
                     gift_card.batch_id.to_s,
                     gift_card.sequence_number.to_s,
                     gift_card.amount.to_s,
                     gift_card.reason.titleize,
                     this_person.id || '',
                     this_person.full_name || '',
                     this_person.address_fields_to_sentence || '']
        if this_person.phone_number.present?
          row_items.push(this_person.phone_number.phony_formatted(format: :national, spaces: '-'))
        else
          row_items.push('')
        end
        row_items.push(this_person.email_address)
        row_items.push(gift_card.notes)
        csv << row_items
      end
    end
  end

  private

    def assign_card_activation
      # tricksy: must allow creation of cards without activations
      # but must check to see if card has activation
      # AND throw error if we are duplicating.
      return true if card_activation_id.blank?
      if card_activation.nil?
        # first check if we have an activation id, then a search
        ca = CardActivation.find card_activation_id unless card_activation_id.nil?
        ca ||= CardActivation.where(sequence_number: sequence_number, batch_id: batch_id).first

        if ca.present? && ca.gift_card_id.nil?
          self.card_activation = ca
          return true
        elsif ca.gift_card_id.present?
          # error case, duplicating
          errors.add(:base, 'This card as already been assigned')
          raise ActiveRecord::RecordInvalid.new(self)
        else
          return true # no card activation for this gift card
        end
      end
    end

    def unassign_card_activation
      if card_activation.present?
        card_activation.gift_card_id = nil
        card_activation.save
      end
    end

    def giftable_person_ownership
      # if there is no giftable object, means this card was given directly. no invitation/session, etc.
      return true if giftable.nil?

      giftable.respond_to?(:person_id) ? person_id == giftable.person_id : false
    end
  # rubocop:enable Metrics/MethodLength
end
