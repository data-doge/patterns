# == Schema Information
#
# Table name: users
#
#  id                      :integer          not null, primary key
#  email                   :string(255)      default(""), not null
#  encrypted_password      :string(255)      default(""), not null
#  reset_password_token    :string(255)
#  reset_password_sent_at  :datetime
#  remember_created_at     :datetime
#  sign_in_count           :integer          default(0)
#  current_sign_in_at      :datetime
#  last_sign_in_at         :datetime
#  current_sign_in_ip      :string(255)
#  last_sign_in_ip         :string(255)
#  password_salt           :string(255)
#  invitation_token        :string(255)
#  created_at              :datetime
#  updated_at              :datetime
#  approved                :boolean          default(FALSE), not null
#  name                    :string(255)
#  token                   :string(255)
#  phone_number            :string(255)
#  new_person_notification :boolean          default(FALSE)
#

class User < ActiveRecord::Base
  has_paper_trail
  # acts_as_tagger #if we want owned tags.

  devise :database_authenticatable,
    :registerable,
    :recoverable,
    :rememberable,
    :trackable,
    :validatable,
    stretches: Rails.env.production? ? 1 : 10

  has_many :research_sessions
  has_many :invitations, through: :research_sessions
  has_many :gift_cards, foreign_key: :created_by

  phony_normalize :phone_number, default_country_code: 'US'
  phony_normalized_method :phone_number, default_country_code: 'US'

  has_secure_token # for calendar feeds

  # for sanity's sake
  alias_attribute :email_address, :email

  def active_for_authentication?
    if super && approved?
      true
    else
      Rails.logger.warn("[SEC] User #{email} is not approved but attempted to authenticate.")
      false
    end
  end

  def inactive_message
    if !approved?
      :not_approved
    else
      super # Use whatever other message
    end
  end

  def approve!
    update_attributes(approved: true)
    Rails.logger.info("Approved user #{email}")
  end

  def unapprove!
    update_attributes(approved: false)
    Rails.logger.info("Unapproved user #{email}")
  end

  def full_name # convienence for calendar view.
    name
  end

  def gift_card_total
    end_of_last_year = Time.zone.today.beginning_of_year - 1.day
    total = gift_cards.where('created_at > ?', end_of_last_year).sum(:amount_cents)
    Money.new(total, 'USD')
  end

  def self.send_all_reminders
    # this is where reservation_reminders
    # called by whenever in /config/schedule.rb
    User.all.find_each(&:send_session_reminder)
  end

  def send_session_reminder
    return if research_sessions.for_today.size.zero?
    ::PersonMailer.remind(
      sessions:  research_sessions.upcoming,
      person: email
    ).deliver_later
  end
end
