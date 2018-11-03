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

class Giftrocket < ApplicationRecord
  include Rewardable
  has_paper_trail
  monetize :amount_cents
  has_one :reward, as: :rewardable, dependent: :nullify
  belongs_to :user
  belongs_to :person
end
