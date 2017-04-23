# == Schema Information
#
# Table name: invitations
#
#  id                  :integer          not null, primary key
#  person_id           :integer
#  created_at          :datetime
#  updated_at          :datetime
#  research_session_id :integer
#  aasm_state          :string(255)
#

# FIXME: Refactor and re-enable cop
class Invitation < ActiveRecord::Base
  has_paper_trail

  include AASM
  include Calendarable

  belongs_to :person
  belongs_to :research_session

  # so users can take notes.
  has_many :comments, as: :commentable, dependent: :destroy

  # this is how we give gift cards for sessions.

  has_many :gift_cards, as: :giftable, dependent: :destroy
  validates :person, presence: true

  # unclear
  # can't have the same time slot id twice.
  # validates :time_slot, uniqueness: true, presence: true

  # one person can't have multiple invitations for the same event
  validates :person, uniqueness: { scope: :research_session }

  # these overlap validations are super tricksy.
  # do we check this here?
  # User can't book over themselves.

  # validates 'v2_time_slots.start_time', 'v2_time_slots.end_time',
  #   overlap: {
  #     query_options: { includes: [:time_slot] },
  #     scope: 'user_id',
  #     exclude_edges: %w[v2_time_slots.start_time v2_time_slots.end_time],
  #     message_title:  'Sorry!',
  #     message_content: 'This time is no longer available.'
  #   }

  # # person can only have one invitation at a time.
  # validates 'v2_time_slots.start_time', 'v2_time_slots.end_time',
  #   overlap: {
  #     query_options: { includes: :time_slot },
  #     scope: 'person_id',
  #     exclude_edges: %w[v2_time_slots.start_time v2_time_slots.end_time],
  #     message_title:  'Sorry!',
  #     message_content: 'This time is no longer available.'
  #   }

  # not sure about all these delegations.
  delegate :user,
    :start_datetime,
    :end_datetime,
    :title,
    :description,
    :sms_description,
    :duration, to: :research_session

  # invitations can move through states
  aasm do
    state :created, initial: true
    state :reminded
    state :confirmed
    state :cancelled
    state :rescheduled
    state :missed
    state :attended

    event :remind do
      transitions from: :created, to: :reminded
    end

    event :confirm, after_commit: :notify_about_confirmation do
      transitions from: %i[created reminded], to: :confirmed
    end

    event :cancel, after_commit: :notify_about_cancellation do
      transitions from: %i[created reminded confirmed], to: :cancelled
    end

    event :reschedule, after_commit: :notify_about_reschedule do
      transitions from: %i[created reminded confirmed], to: :rescheduled
    end

    event :attend do
      transitions to: :attended
    end

    event :miss do
      transitions from: %i[created reminded confirmed], to: :missed
    end
  end

  def owner_or_invitee?(person_or_user)
    # both people and users can own a invitation.
    return true if user == person_or_user
    return true if person == person_or_user
    return false if person_or_user.nil?
    false
  end

  # these three could definitely be refactored. too much copy-paste
  # also rename for nomenclature convention
  def notify_about_confirmation
    InvitationNotifier.confirm(email_address: user.email, invitation: self).deliver_later
    case person.preferred_contact_method.upcase
    when 'SMS'
      ::InvitationConfirmSms.new(to: person, invitation: self).send
    when 'EMAIL'
      InvitationNotifier.confirm(email_address: person.email_address, invitation: self).deliver_later
    end
  end

  def notify_about_cancellation
    InvitationNotifier.cancel(email_address: user.email, invitation: self).deliver_later
    case person.preferred_contact_method.upcase
    when 'SMS'
      ::InvitationCancelSms.new(to: person, invitation: self).send
    when 'EMAIL'
      InvitationNotifier.cancel(email_address: person.email_address, invitation: self).deliver_later
    end
  end

  def notify_about_reschedule
    InvitationNotifier.reschedule(email_address: user.email, invitation: self).deliver_later
    case person.preferred_contact_method.upcase
    when 'SMS'
      ::InvitationRescheduleSms.new(to: person, invitation: self).send
    when 'EMAIL'
      InvitationNotifier.reschedule(email_address: person.email_address, invitation: self).deliver_later
    end
  end

  def permitted_events
    aasm.events.map(&:name).map(&:to_s)
  end

  def permitted_states
    aasm.states(permitted: true).map(&:name).map(&:to_s)
  end

  def state_action_array
    permitted_events.each_with_index.map do |e, i|
      [permitted_states[i], e]
    end
  end

  def human_state
    case aasm_state
    when 'created' || 'reminded'
      'Unconfirmed'
    when 'rescheduled'
      'Rescheduling'
    else
      aasm_state.capitalize
    end
  end

end
# rubocop:enable ClassLength
