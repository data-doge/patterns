# == Schema Information
#
# Table name: research_sessions
#
#  id              :integer          not null, primary key
#  description     :string(255)
#  buffer          :integer          default(0), not null
#  created_at      :datetime
#  updated_at      :datetime
#  user_id         :integer
#  title           :string(255)
#  start_datetime  :datetime
#  end_datetime    :datetime
#  sms_description :string(255)
#  session_type    :integer          default(1)
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
    people.map { |i| { id: i.id, name: i.full_name, label: i.full_name, value: i.id } }
  end

end
