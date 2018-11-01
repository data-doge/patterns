# == Schema Information
#
# Table name: carts
#
#  id            :integer          not null, primary key
#  name          :string(255)      default("default")
#  user_id       :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  description   :text(16777215)
#  people_count  :integer          default(0)
#  rapidpro_uuid :string(255)
#  rapidpro_sync :boolean          default(FALSE)
#

require 'rails_helper'

RSpec.describe Cart, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
