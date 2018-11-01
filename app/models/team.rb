# frozen_string_literal: true

# == Schema Information
#
# Table name: teams
#
#  id           :bigint(8)        not null, primary key
#  name         :string(255)
#  finance_code :string(255)
#  description  :text(16777215)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Team < ApplicationRecord
  has_many :users
  has_many :research_sessions, through: :users
  has_many :rewards
  validates :finance_code, inclusion: { in: %w[BRL CATA1 CATA2 FELL] }

  def self.finance_codes
    %w[BRL CATA1 CATA2 FELL]
  end

  def rewards_total(since = Time.zone.today.beginning_of_year - 1.day)
    raise ArgumentError if since.class != Date

    total = rewards.where('created_at > ?', since).sum(:amount_cents)
    Money.new(total, 'USD')
  end

end
