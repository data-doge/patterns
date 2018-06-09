# frozen_string_literal: true

#
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

class Event < ApplicationRecord

  validates :name,
    :application_id,
    :location,
    :address,
    :start_datetime,
    :end_datetime,
    :description, presence: true

  belongs_to :application

  has_many :reservations
  has_many :people, through: :reservations

  def to_param
    "#{id}-#{name.parameterize}"
  end

  def title
    name
  end
end
