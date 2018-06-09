# frozen_string_literal: true

# == Schema Information
#
# Table name: reservations
#
#  id           :integer          not null, primary key
#  person_id    :integer
#  event_id     :integer
#  confirmed_at :datetime
#  created_by   :integer
#  attended_at  :datetime
#  created_at   :datetime
#  updated_at   :datetime
#  updated_by   :integer
#

class Reservation < ApplicationRecord
  has_paper_trail
  validates :person_id, :event_id, presence: true

  belongs_to :person
  belongs_to :event
  delegate :name, to: :event
end
