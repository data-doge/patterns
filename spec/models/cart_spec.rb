# == Schema Information
#
# Table name: carts
#
#  id         :integer          not null, primary key
#  name       :string(255)      default("default")
#  user_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Cart, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
