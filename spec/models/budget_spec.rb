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

require 'rails_helper'

RSpec.describe Budget, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
