# frozen_string_literal: true
# == Schema Information
#
# Table name: budgets
#
#  id              :bigint(8)        not null, primary key
#  amount_cents    :integer          default(0), not null
#  amount_currency :string(255)      default("USD"), not null
#  team_id         :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Budget < ApplicationRecord
  has_paper_trail
  monetize :amount_cents

  has_many :credits, -> { where(from_type: 'Budget') },
    class_name: 'Transaction',
    foreign_key: 'from_id',
    dependent: :nullify,
    inverse_of: :debits

  has_many :debits, -> { where(to_type: 'Budget') },
    class_name: 'Transaction',
    foreign_key: 'to_id',
    dependent: :nullify,
    inverse_of: :credits

  def transactions
    Transactions.where(to_type: 'Budget', to_id: id).or(Transactions.where(to_type: 'Budget', from_id: id))
  end
end
