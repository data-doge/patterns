# == Schema Information
#
# Table name: activation_calls
#
#  id           :bigint(8)        not null, primary key
#  gift_card_id :integer
#  sid          :string(255)
#  transcript   :text(16777215)
#  audio_url    :string(255)
#  call_type    :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  call_status  :string(255)      default("created")
#  token        :string(255)
#

require 'rails_helper'

RSpec.describe ActivationCall, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
