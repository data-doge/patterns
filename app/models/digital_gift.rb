# frozen_string_literal: true

# == Schema Information
#
# Table name: giftrockets
#
#  id            :bigint(8)        not null, primary key
#  order_details :text(65535)
#  created_by    :integer          not null
#  user_id       :integer
#  person_id     :integer
#  reward_id     :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

# first we create the giftrocket, with a person and user and created_by
# then we check budgets, local and remote
# then we try to make the order
# then if the order is successful
# we create the reward and update the front end
# if error, we update the front end with an error
class DigitalGift < ApplicationRecord
  include Rewardable
  include AASM
  page 50
  
  monetize :fee_cents
  has_one :budget, through: :user
  

  aasm requires_lock: true do
    state :initialized, initial: true
    state :insufficient_budget
    state :requested
    state :sent
    state :redeemed

    event :check_budget do
      transitions from: :initialized, to: %i[requested insufficient_budget]
    end
    event :request_gift, guard: :sufficient_budget? do 
      transitions from: :requested
    end
  end

  def self.campaigns
    Giftrocket::Campaigns.list
  end

  def self.funding_sources
    Giftrocket::FundingSource.list
  end

  def self.current_budget
    (Giftrocket.funding_sources.first.available_cents / 100).to_money
  end

  def self.orders
    Giftrocket::Order.list
  end

  def self.gifts
    Giftrocket::Gift.list
  end

  def check_status
    raise if gift_id.nil?
    gift = Giftrocket::Gift.retrieve(gift_id)
    # STATUS                          Explanation
    # SCHEDULED_FOR_FUTURE_DELIVERY   self explanatory
    # DELIVERY_ATTEMPTED              receipt not confirmed
    # EMAIL_BOUNCED                   only if we email things
    # DELIVERED                       receipt confirmed (Everytime, this)

    gift.status
  end

  # is this really how I want to do it?
  def request_link
    raise if person_id.nil?

    funding_source_id = Giftrocket::FundingSource.list.first.id
    self.external_id = generate_external_id

    my_order = Giftrocket::Order.create!(funding_source_id, gen_gifts, external_id)
    self.fee = my_order.payment.fees
    self.order_id = my_order.id

    gift = my_order.gifts.first
    self.gift_id = gift.id
    self.link = gift.raw['recipient']['link']
    self.order_details = Marshal.dump(my_order)
    save
  end

  # this is where we check if we can actually request this gift
  # first from our user's team budget
  # then from giftrocket, and then we make the request
  def budget
    amount >= user.available_budget
  end

  def create_transaction; end

  # maybe this is just a 
  def generate_external_id
    raise if reward.nil?

    { person_id: reward.person_id,
      giftable_id: reward.giftable_id,
      giftable_type: reward.giftable_type }.to_json
  end

  def gen_gifts
    raise if person.nil?

    [
      {
        amount: amount.to_s,
        recipient: {
          name: person.full_name,
          delivery_method: 'LINK'
        }
      }
    ]
  end

  # rubocop:disable Security/MarshalLoad
  # we want to save the full object. probably don't need to,
  # but it's handy
  def order
    @order ||= Marshal.load(order_details)
  end
  # rubocop:enable Security/MarshalLoad
  
  # use actioncable again to update our front end status
  def update_frontend_success
  end

  def update_frontend_failure
  end
  
end
