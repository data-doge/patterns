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
  validates :person, presence: true

  # so users can take notes.
  has_many :comments, as: :commentable, dependent: :destroy

  # this is how we give gift cards for sessions.
  has_many :gift_cards, as: :giftable, dependent: :destroy

  # one person can't have multiple invitations for the same event
  validates :person, uniqueness: { scope: :research_session }

  # not sure about all these delegations.
  delegate :user,
    :start_datetime,
    :end_datetime,
    :title,
    :description,
    :sms_description,
    :duration, to: :research_session

  scope :today, -> {
    joins(:research_session).
      where(research_sessions: { start_datetime: Time.zone.today.beginning_of_day..Time.zone.today.end_of_day })
  }

  scope :future, -> {
    joins(:research_session).
      where('research_sessions.start_datetime > ?',
        Time.zone.today.end_of_day)
  }

  scope :past, -> {
    joins(:research_session).
      where('research_sessions.start_datetime < ?',
        Time.zone.today.beginning_of_day)
  }

  scope :upcoming, ->(d = 7) {
    joins(:research_session).
      where(research_sessions: { start_datetime: Time.zone.today.beginning_of_day..Time.zone.today.end_of_day + d.days })
  }
  # invitations can move through states
  # necessary for text messaging bits in the future
  aasm do
    state :created, initial: true
    state :invited
    state :reminded
    state :confirmed
    state :cancelled # means that they cancelled ahead of time
    state :missed # means they didn't cancel
    state :attended

    event :invite, before_commit: :send_invitation, guard: :in_future? do
      transitions from: :created, to: :invited
    end

    event :remind, before_commit: :send_reminder do
      transitions from: :invited, to: :reminded
    end

    event :confirm, after_commit: :notify_about_confirmation do
      transitions from: %i[invited reminded], to: :confirmed
    end

    event :cancel, after_commit: :notify_about_cancellation do
      transitions from: %i[invited reminded confirmed], to: :cancelled
    end

    event :attend do
      transitions to: :attended
    end

    event :miss do
      # should this be able to transition from "created" ?
      transitions from: %i[invited reminded confirmed], to: :missed
    end
  end

  def owner_or_invitee?(person_or_user)
    # both people and users can own a invitation.
    return true if user == person_or_user
    return true if person == person_or_user
    return false if person_or_user.nil?
    false
  end

  def send_invitation
    case person.preferred_contact_method.upcase
    when 'SMS'
      send_invite_sms
    when 'EMAIL'
      send_invite_email
    end
  end

  def send_invite_email
    ::PersonMailer.invite(
      email_address: person.email_address,
      invitation:  self,
      person: person
    ).deliver_later
  end

  def send_invite_sms
    # we send a bunch at once, delay it. Plus this has extra logic
    Delayed::Job.enqueue(SendInvitationsSmsJob.new(person, self))
  end

  # these three could definitely be refactored. too much copy-paste
  # also rename for nomenclature convention
  def notify_about_confirmation
    ::PersonMailer.confirm(email_address: user.email, invitation: self).deliver_later
    case person.preferred_contact_method.upcase
    when 'SMS'
      ::InvitationConfirmSms.new(to: person, invitation: self).send
    when 'EMAIL'
      ::PersonMailer.confirm(email_address: person.email_address, invitation: self).deliver_later
    end
  end

  def notify_about_cancellation
    # notify the user
    ::PersonMailer.cancel(email_address: user.email, invitation: self).deliver_later

    case person.preferred_contact_method.upcase
    when 'SMS'
      ::InvitationCancelSms.new(to: person, invitation: self).send
    when 'EMAIL'
      ::PersonMailer.cancel(email_address: person.email_address, invitation: self).deliver_later
    end
  end

  def permitted_events
    aasm.events.(permitted: true).map(&:name).map(&:to_s)
  end

  def permitted_states
    aasm.states(permitted: true).map(&:name).map(&:to_s)
  end

  def state_action_array
    permitted_events.each_with_index.map do |e, i|
      [permitted_states[i], e]
    end
  end

  def in_future?
    Time.zone.now < start_datetime
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
