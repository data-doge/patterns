# frozen_string_literal: true

# == Schema Information
#
# Table name: transactions
#
#  id              :bigint(8)        not null, primary key
#  recipient_id       :bigint(8)
#  from_id         :bigint(8)
#  user_id         :integer
#  amount_cents    :integer          default(0), not null
#  amount_currency :string(255)      default("USD"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

# srecipientres all transactions in a log
class TransactionLog < ApplicationRecord
  has_paper_trail
  monetize :amount_cents
  after_create :update_budgets

  has_one :digital_gift, as: :recipient
  has_one :budget, as: [:recipient, :from]

  validate :sufficient_budget?
  validate :correct_type?

  validates :from_id, presence: true
  validates :from_type, presence: true

  validates :transaction_type, inclusion: { in: %w[DigitalGift Transfer Topup] }

  validates :recipient_type,
    inclusion: {
      in: %w[Budget DigitalGift]
    }, allow_nil: true

  validates :from_type,
    inclusion: {
      in: %w[Budget User]
    }

  validate :sufficient_budget?

  def update_budgets
    case transaction_type
    when 'Transfer'
      from.amount -= amount
      recipient.amount += amount
      from.save
      recipient.save
    when 'DigitalGift'
      from.amount -= amount
      from.save
    when 'Topup'
      recipient.amount += amount
      recipient.save
    end
  end

  def from
    @from ||= from_type.classify.constantize.find(from_id)
  end

  def recipient
    return false if recipient_type.nil? || recipient_id.nil?

    @recipient ||= recipient_type.classify.constantize.find(recipient_id)
  end

  private

    def admin?
      from.admin? if from.respond_to?(:admin?)
    end

    def correct_type?
      case transaction_type
      when 'Budget'
        recipient_type == 'Budget' && from_type == 'Budget'
      when 'Topup'
        recipient_type == 'Budget' && from_type == 'User' && admin? && from.team == recipient.team
      when 'DigitalGift'
        recipient_type == 'DigitalGift' && from_type == 'Budget'
      end
    end

    # is there sufficient budget for the transaction recipient go through
    # do we do this here?
    def sufficient_budget?
      return false if from.nil?

      return from.admin? if from.respond_to?(:admin?) # it's a user

      from.amount >= amount # should always have an amount
    end

end
