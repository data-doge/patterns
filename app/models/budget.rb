# frozen_string_literal: true

# == Schema Information
#
# Table name: budgets
#
#  id              :bigint(8)        not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  team_id         :integer          not null
#  amount_cents    :integer          default(0), not null
#  amount_currency :integer          default(0), not null
#


class Budget < ApplicationRecord
  has_paper_trail
  monetize :amount_cents
  
  has_many :credits,
    class_name: 'Transaction',
    foreign_key: 'creditor_id',
    dependent: :destroy
  
  has_many :debits,
    class_name: 'Transaction',
    foreign_key: 'debtor_id',
    dependent: :destroy

  def transactions
    Transactions.where(creditor_id: id).or(Transactions.where(debtor_id: id))
  end
end
