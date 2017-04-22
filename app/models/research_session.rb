# == Schema Information
#
# Table name: session
#
#  id          :integer          not null, primary key
#  v2_event_id :integer
#  people_ids  :string(255)
#  description :string(255)
#  slot_length :string(255)
#  date        :string(255)
#  start_time  :string(255)
#  end_time    :string(255)
#  buffer      :integer          default(0), not null
#  created_at  :datetime
#  updated_at  :datetime
#  user_id     :integer
#  title       :string(255)
#

class ResearchSession < ActiveRecord::Base
  has_paper_trail
  acts_as_taggable # new, better tagging system
  include Calendarable

  # different types # breaks stuff
  #  enum session_type: %i[interview focus_group social test]

  belongs_to :user
  has_many :invitations
  has_many :people, through: :invitations

  validates :description,
    :title,
    :start_datetime,
    :end_datetime,
    :user_id,
    presence: true

  default_scope { includes(:invitations) }

  def people_name_and_id
    return [] if people_ids.nil?
    people.map { |i| { id: i.id, name: i.full_name, label: i.full_name, value: i.id } }
  end

end
