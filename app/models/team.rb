class Team < ApplicationRecord
  has_many :users
  has_many :research_sessions, through: :users
  has_many :gift_cards

  def gift_card_total(since = Time.zone.today.beginning_of_year - 1.day)
    raise ArgumentError if since.class != Date
    total = gift_cards.where('created_at > ?', since).sum(:amount_cents)
    Money.new(total, 'USD')
  end

end
