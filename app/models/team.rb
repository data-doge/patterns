# frozen_string_literal: true

# == Schema Information
#
# Table name: teams
#
#  id           :bigint(8)        not null, primary key
#  name         :string(255)
#  finance_code :string(255)
#  description  :text(65535)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Team < ApplicationRecord
  has_many :users
  has_many :research_sessions, through: :users
  has_many :gift_cards
  validates_inclusion_of :finance_code, in: %w[BRL CATA1 CATA2 FELL]
  
  def self.finance_codes
    %w[BRL CATA1 CATA2 FELL]
  end

  def gift_card_total(since = Time.zone.today.beginning_of_year - 1.day)
    raise ArgumentError if since.class != Date
    total = gift_cards.where('created_at > ?', since).sum(:amount_cents)
    Money.new(total, 'USD')
  end

end
