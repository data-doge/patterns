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
#  proxy_id         :string(255)
#  active           :boolean          default(FALSE)
#  secure_code      :string(255)
#  team_id          :integer
#  finance_code     :string(255)
#

class GiftCard < ApplicationRecord
  has_paper_trail
  page 20
  monetize :amount_cents

  enum reason: {
    unknown: 0,
    signup: 1,
    test: 2,
    referral: 3,
    interview: 4,
    other: 5
  }

  belongs_to :giftable, polymorphic: true, touch: true
  belongs_to :person
  belongs_to :user, foreign_key: :created_by
  belongs_to :team
  has_one :card_activation

  validates_presence_of :amount
  validates_presence_of :reason
  validates_presence_of :batch_id
  validates_presence_of :proxy_id

  validates_format_of :expiration_date,
    with:  %r{\A(0|1)([0-9])\/([0-9]{2})\z}i,
    unless: proc { |c| c.expiration_date.blank? }

  validates_length_of :proxy_id, minimum: 2, maximum: 7, unless: proc { |c| c.proxy_id.blank? }

  validates_uniqueness_of :proxy_id,
    scope: %i[batch_id gift_card_number],
    unless: proc { |c| c.proxy_id.blank? }

  validates_uniqueness_of :gift_card_number,
    scope: %i[batch_id proxy_id],
    unless: proc { |c| c.gift_card_number.blank? }

  validates_format_of :gift_card_number,
    with:  /\A([0-9]){4,5}\z/i,
    unless: proc { |c| c.gift_card_number.blank? }

  # Validation to limit 1 signup per person
  validates_uniqueness_of :reason, scope: :person_id, if: :reason_is_signup?

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
                     gift_card.proxy_id.to_s,
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
    def giftable_person_ownership
      # if there is no giftable object, means this card was given directly. no invitation/session, etc.
      return true if giftable.nil?

      giftable.respond_to?(:person_id) ? person_id == giftable.person_id : false
    end
  # rubocop:enable Metrics/MethodLength
end
