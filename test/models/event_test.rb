# == Schema Information
#
# Table name: events
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  description    :text(65535)
#  start_datetime :datetime
#  end_datetime   :datetime
#  location       :text(65535)
#  address        :text(65535)
#  capacity       :integer
#  application_id :integer
#  created_at     :datetime
#  updated_at     :datetime
#  created_by     :integer
#  updated_by     :integer
#

require 'test_helper'

class EventTest < ActiveSupport::TestCase

  test 'should know about reservations' do
    assert_equal 2, events(:one).people.count
  end

end
