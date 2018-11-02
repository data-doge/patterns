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

require 'rails_helper'

RSpec.describe Giftrocket, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
