# == Schema Information
#
# Table name: activation_calls
#
#  id                 :integer          not null, primary key
#  card_activation_id :integer
#  sid                :string(255)
#  transcript         :string(255)
#  audio_url          :string(255)
#  call_type          :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  status             :string(255)      default("created")
#

require 'rails_helper'

RSpec.describe ActivationCall, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
