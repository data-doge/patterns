#

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
  has_many :comments, as: :commentable, dependent: :destroy
  before_create :update_missing_attributes

  accepts_nested_attributes_for :invitations, reject_if: :all_blank, allow_destroy: true

  validates :description,
    :title,
    :start_datetime,
    :duration,
    :user_id,
    presence: true

  default_scope { includes(:invitations).order(start_datetime: :desc) }

  scope :today, -> { where(start_datetime: Time.zone.today.beginning_of_day..Time.zone.today.end_of_day) }

  scope :future, -> {
    where('start_datetime > ?',
      Time.zone.today.end_of_day)
  }
  scope :past, -> {
    where('start_datetime < ?',
      Time.zone.today.beginning_of_day)
  }

  scope :upcoming, ->(d = 7) { where(start_datetime: Time.zone.today.beginning_of_day..Time.zone.today.end_of_day + d.days) }

  ransacker :person_name, formatter: proc { |v| v.mb_chars.downcase.to_s } do |_parent|
    Arel::Nodes::NamedFunction.new('lower',
      [Arel::Nodes::NamedFunction.new('concat_ws',
        [Arel::Nodes.build_quoted(' '), Person.table[:first_name], Person.table[:last_name]])])
  end

  scope :ransack_tagged_with, ->(*tags) { tagged_with(tags) }

  def self.ransackable_scopes(_auth = nil)
    %i[ransack_tagged_with]
  end

  def people_name_and_id
    people.map do |i|
      { id: i.id,
        name: i.full_name,
        label: i.full_name,
        value: i.id }
    end
  end

  def send_invitation_notifications
    invitations.where(aasm_state: 'created').find_each(&:invite!)
  end

  private

    def update_missing_attributes
      self.end_datetime = start_datetime + duration.minutes
    end

end
