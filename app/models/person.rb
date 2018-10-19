# frozen_string_literal: true

# == Schema Information
#
# Table name: people
#
#  id                               :integer          not null, primary key
#  first_name                       :string(255)
#  last_name                        :string(255)
#  email_address                    :string(255)
#  address_1                        :string(255)
#  address_2                        :string(255)
#  city                             :string(255)
#  state                            :string(255)
#  postal_code                      :string(255)
#  geography_id                     :integer
#  primary_device_id                :integer
#  primary_device_description       :string(255)
#  secondary_device_id              :integer
#  secondary_device_description     :string(255)
#  primary_connection_id            :integer
#  primary_connection_description   :string(255)
#  phone_number                     :string(255)
#  participation_type               :string(255)
#  created_at                       :datetime
#  updated_at                       :datetime
#  signup_ip                        :string(255)
#  signup_at                        :datetime
#  voted                            :string(255)
#  called_311                       :string(255)
#  secondary_connection_id          :integer
#  secondary_connection_description :string(255)
#  verified                         :string(255)
#  preferred_contact_method         :string(255)
#  token                            :string(255)
#  active                           :boolean          default(TRUE)
#  deactivated_at                   :datetime
#  deactivated_method               :string(255)
#  neighborhood                     :string(255)
#  referred_by                      :string(255)
#  low_income                       :boolean
#  rapidpro_uuid                    :string(255)
#

# FIXME: Refactor and re-enable cop
# rubocop:disable ClassLength
class Person < ApplicationRecord
  has_paper_trail

  acts_as_taggable

  page 50

  # include Searchable
  include ExternalDataMappings
  include Neighborhoods

  phony_normalize :phone_number, default_country_code: 'US'
  phony_normalized_method :phone_number, default_country_code: 'US'

  has_many :comments, as: :commentable, dependent: :destroy

  has_many :submissions, dependent: :destroy

  has_many :gift_cards
  accepts_nested_attributes_for :gift_cards, reject_if: :all_blank
  attr_accessor :gift_cards_attributes

  has_many :reservations, dependent: :destroy
  has_many :events, through: :reservations

  has_many :invitations
  has_many :research_sessions, through: :invitations

  # TODO: remove people from carts on deactivation
  has_many :carts_people
  has_many :carts, through: :carts_people, foreign_key: :person_id

  has_secure_token :token

  if ENV['RAILS_ENV'] == 'production'
    after_commit :send_to_mailchimp, on: %i[update create] if ENV['MAILCHIMP_API_KEY']

    after_commit :update_rapidpro, on: %i[update create] if ENV['RAPIDPRO_TOKEN']
    before_destroy :delete_from_rapidpro  if ENV['RAPIDPRO_TOKEN']
  end

  after_create  :update_neighborhood
  after_commit  :send_new_person_notifications, on: :create

  validates :first_name, presence: true
  validates :last_name, presence: true

  validates :postal_code, presence: true
  validates :postal_code, zipcode: { country_code: :us }

  # phony validations and normalization
  phony_normalize :phone_number, default_country_code: 'US'
  phony_normalize :landline, default_country_code: 'US'

  # validates :phone_number, presence: true, length: { in: 9..15 },
  #   unless: proc { |person| person.email_address.present? }
  validates :phone_number, allow_blank: true, uniqueness: true
  validates :landline, allow_blank: true, uniqueness: true

  # validates :email_address, presence: true,gc
  #   unless: proc { |person| person.phone_number.present? }
  validates :email_address, email: true, allow_blank: true, uniqueness: true

  scope :no_signup_card, -> { where('id NOT IN (SELECT DISTINCT(person_id) FROM gift_cards where gift_cards.reason = 1)') }
  scope :signup_card_needed, -> { joins(:gift_cards).where('gift_cards.reason !=1') }

  scope :verified, -> { where('verified like ?', '%Verified%') }
  scope :not_verified, -> { where.not('verified like ?', '%Verified%') }
  scope :active, -> { where(active: true) }
  scope :deactivated, -> { where(active: false) }

  scope :order_by_giftcard_sum, -> { joins(:gift_cards).includes(:research_sessions).where('gift_cards.created_at >= ?', Time.current.beginning_of_year).select('people.id, people.first_name,people.last_name, people.active,sum(gift_cards.amount_cents) as total_gc').group('people.id').order('total_gc desc') }
  # no longer using this. now managing active elsewhere
  # default_scope { where(active:

  ransacker :full_name, formatter: proc { |v| v.mb_chars.downcase.to_s } do |parent|
    Arel::Nodes::NamedFunction.new('lower',
      [Arel::Nodes::NamedFunction.new('concat_ws',
        [Arel::Nodes.build_quoted(' '), parent.table[:first_name], parent.table[:last_name]])])
  end

  scope :ransack_tagged_with, ->(*tags) { tagged_with(tags) }

  def self.ransackable_scopes(_auth_object = nil)
    %i[no_signup_card ransack_tagged_with]
  end

  def self.locale_name_to_locale(locale_name)
    obj = { 'english': 'en', 'spanish': 'es', 'chinese': 'zh' }
    obj[locale_name.downcase]
  end

  ransack_alias :comments, :comments_content
  ransack_alias :nav_bar_search, :full_name_or_email_address_or_phone_number_or_comments_content

  def self.send_all_reminders
    # this is where reservation_reminders
    # called by whenever in /config/schedule.rb
    Person.active.all.find_each(&:send_invitation_reminder)
  end

  def self.update_all_participation_levels
    @results = []
    Person.active.all.find_each {|person| @results << person.update_participation_level }
    @results.compact!
    if @results.length.positive?
      User.approved.admin.all.find_each do |u|
        AdminMailer.participation_level_change(results: @results, to: u.email_address).deliver_later
      end
    end
  end

  def self.participation_levels
    # * Active DIG member =“Participated in 3+ sessions” = invited to join FB group;
    # * [Need another name for level 2] = “Participated in at least one season--
    #     (could code as 6 months active) OR at least 2 different projects/teams
    #     (could code based on being tagged in a session by at least 2 different teams)
    # * DIG Ambassador = “active for at least one year, 2+ projects/teams
    # if there’s any way to automate that info to flow into dashboard/pool —
    # and notify me when new person gets added-- that would be amazing
    %w[new inactive participant active ambassador]
  end

  def inactive_criteria
    # have gotten a gift card, but not in the past year.
    gift_cards.where('created_at < ?', 1.year.ago).size >= 1
  end

  def participant_criteria
    # gotten a gift card in the past year.
    gift_cards.where('created_at > ?', 1.year.ago).map { |g| g&.research_session&.id }.compact.uniq.size >= 1
  end

  def active_criteria
    # gotten a gift card for a research session in the past 6 months
    # and two teams
    gift_cards.where('created_at > ?', 6.months.ago).map { |g| g&.research_session&.id }.compact.uniq.size >= 1 || gift_cards.where('created_at > ?', 6.months.ago).map(&:team).uniq.size >= 2
  end

  def ambassador_criteria
    # older than a year and 2 or more sessions with two teams and
    # either 3 research sessions or 6 cards in the last year
    if tag_list.include?('brl special ambassador')
      true
    else
      gift_cards.where('created_at > ?', 1.year.ago).map(&:team).uniq.size >= 2 && gift_cards.map { |g| g&.research_session&.id }.compact.uniq.size >= 3
    end
  end

  def calc_participation_level
    pl = 'new' # needs outreach
    pl = 'inactive'    if inactive_criteria
    pl = 'participant' if participant_criteria
    pl = 'active'      if active_criteria
    pl = 'ambassador'  if ambassador_criteria
    pl
  end

  def update_participation_level
    return if tag_list.include? 'not dig'

    new_level = calc_participation_level

    if self.participation_level != new_level
      old_level = self.participation_level
      self.participation_level = new_level

      self.tag_list.remove(old_level)
      self.tag_list.add(new_level)
      self.save
      Cart.where(name: Person.participation_levels).find_each do |cart|
        if cart.name == new_level
          cart.people << self rescue ActiveRecord::RecordInvalid
        else
          cart.remove_person_id(self.id) # no-op if person not in cart
        end
      end # end cart update
      return { pid: id, old: old_level, new: new_level }
    end
  end

  def self.verified_types
    Person.distinct.pluck(:verified).select(&:present?)
  end

  def signup_gc_sent
    signup_cards = gift_cards.where(reason: 1)
    return true unless signup_cards.empty?

    false
  end

  def verified?
    verified&.start_with?('Verified')
  end

  def gift_card_total
    end_of_last_year = Time.zone.today.beginning_of_year - 1.day
    total = gift_cards.where('created_at > ?', end_of_last_year).sum(:amount_cents)
    Money.new(total, 'USD')
  end

  def gift_card_count
    gift_cards.size
  end

  WUFOO_FIELD_MAPPING = {
    'Field1'   => :first_name,
    'Field2'   => :last_name,
    'Field10'  => :email_address,
    'Field276' => :voted,
    'Field277' => :called_311,
    'Field39'  => :primary_device_id, # type of primary
    'Field21'  => :primary_device_description, # desc of primary
    'Field40'  => :secondary_device_id,
    'Field24'  => :secondary_device_description, # desc of secondary
    'Field41'  => :primary_connection_id, # connection type
    # 'Field41' =>  :primary_connection_description, # description of connection
    'Field42'  => :secondary_connection_id, # connection type
    # 'Field42' =>  :secondary_connection_description, # description of connection
    'Field268' => :address_1, # address_1
    'Field269' => :city, # city
    # 'Field47' =>  :state, # state
    'Field271' => :postal_code, # postal_code
    'Field9'   => :phone_number, # phone_number
    'IP'       => :signup_ip, # client IP, ignored for the moment

  }.freeze

  def tag_values
    tags.collect(&:name)
  end

  def tag_count
    tag_list.size
  end

  def screened?
    tag_list.include?('screened')
  end

  def submission_values
    submissions.collect(&:submission_values)
  end

  # FIXME: Refactor and re-enable cop
  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Rails/TimeZone
  #
  def self.initialize_from_wufoo_sms(params)
    new_person = Person.new

    # Save to Person
    new_person.first_name = params['Field275']
    new_person.last_name = params['Field276']
    new_person.address_1 = params['Field268']
    new_person.postal_code = params['Field271']
    new_person.email_address = params['Field279']
    new_person.phone_number = params['field281']
    new_person.primary_device_id = case params['Field39'].upcase
                                   when 'A'
                                     Person.map_device_to_id('Desktop computer')
                                   when 'B'
                                     Person.map_device_to_id('Laptop')
                                   when 'C'
                                     Person.map_device_to_id('Tablet')
                                   when 'D'
                                     Person.map_device_to_id('Smart phone')
                                   else
                                     params['Field39']
                                   end

    new_person.primary_device_description = params['Field21']

    new_person.primary_connection_id = case params['Field41'].upcase
                                       when 'A'
                                         Person.primary_connection_id('Broadband at home')
                                       when 'B'
                                         Person.primary_connection_id('Phone plan with data')
                                       when 'C'
                                         Person.primary_connection_id('Public wi-fi')
                                       when 'D'
                                         Person.primary_connection_id('Public computer center')
                                       else
                                         params['Field41']
                                       end

    new_person.preferred_contact_method = if params['Field278'].casecmp('TEXT')
                                            'SMS'
                                          else
                                            'EMAIL'
                                          end

    new_person.verified = 'Verified by Text Message Signup'
    new_person.signup_at = Time.now

    new_person
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Rails/TimeZone

  def send_to_mailchimp
    status = active? ? 'subscribed' : 'unsubscribed'
    MailchimpUpdateJob.perform_async(id, status)
  end

  def delete_from_rapidpro
    RapidproDeleteJob.perform_async(id) unless active
  end

  def update_rapidpro
    if active && !tag_list.include?('not dig')
      RapidproUpdateJob.perform_async(id)
    elsif !active || tag_list.include?('not dig')
      delete_from_rapidpro
    end
  end

  # FIXME: Refactor and re-enable cop
  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/PerceivedComplexity
  #
  def self.initialize_from_wufoo(params)
    new_person = Person.new
    params.each_pair do |k, v|
      new_person[WUFOO_FIELD_MAPPING[k]] = v if WUFOO_FIELD_MAPPING[k].present?
    end

    # Special handling of participation type. New form uses 2 fields where old form used 1. Need to combine into one. Manually set to "Either one" if both field53 & field54 are populated.
    new_person.participation_type = if params['Field53'] != '' && params['Field54'] != ''
                                      'Either one'
                                    elsif params['Field53'] != ''
                                      params['Field53']
                                    else
                                      params['Field54']
                                    end

    new_person.preferred_contact_method = if params['Field273'] == 'Email'
                                            'EMAIL'
                                          else
                                            'SMS'
                                          end

    # Copy connection descriptions to description fields
    new_person.primary_connection_description = new_person.primary_connection_id
    new_person.secondary_connection_description = new_person.secondary_connection_id

    # rewrite the device and connection identifiers to integers
    new_person.primary_device_id        = Person.map_device_to_id(params[WUFOO_FIELD_MAPPING.rassoc(:primary_device_id).first])
    new_person.secondary_device_id      = Person.map_device_to_id(params[WUFOO_FIELD_MAPPING.rassoc(:secondary_device_id).first])
    new_person.primary_connection_id    = Person.map_connection_to_id(params[WUFOO_FIELD_MAPPING.rassoc(:primary_connection_id).first])
    new_person.secondary_connection_id  = Person.map_connection_to_id(params[WUFOO_FIELD_MAPPING.rassoc(:secondary_connection_id).first])

    # FIXME: this is a hack, since we need to initialize people
    # with a city/state, but don't ask for it in the Wufoo form
    # new_person.city  = "Chicago" With update we ask for city
    new_person.state = 'Illinois'

    new_person.signup_at = params['DateCreated']

    new_person
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/PerceivedComplexity

  def primary_device_type_name
    if primary_device_id.present?
      Logan::Application.config.device_mappings.rassoc(primary_device_id)[0].to_s
    end
  end

  def secondary_device_type_name
    if secondary_device_id.present?
      Logan::Application.config.device_mappings.rassoc(secondary_device_id)[0].to_s
    end
  end

  def primary_connection_type_name
    if primary_connection_id.present?
      Logan::Application.config.connection_mappings.rassoc(primary_connection_id)[0].to_s
    end
  end

  def secondary_connection_type_name
    if secondary_connection_id.present?
      Logan::Application.config.connection_mappings.rassoc(secondary_connection_id)[0].to_s
    end
  end

  def lat_long
    ::ZIP_LAT_LONG[postal_code.to_s]
  end

  def full_name
    [first_name, last_name].join(' ')
  end

  def address_fields_to_sentence
    [address_1, address_2, city, state, postal_code].reject(&:blank?).join(', ')
  end

  def send_invitation_reminder
    # called by whenever in /config/schedule.rb
    invs = invitations.remindable.upcoming(2)
    case preferred_contact_method.upcase
    when 'SMS'
      ::InvitationReminderSms.new(to: person, invitations: invs).send
    when 'EMAIL'
      ::PersonMailer.remind(
        invitations:  invs,
        email_address: email_address
      ).deliver_later
    end

    invs.each do |inv|
      if inv.aasm_state == 'invited'
        inv.aasm_state = 'reminded'
        inv.save
      end
    end
  end

  def to_a
    fields = Person.column_names
    fields.push('tags')
    fields.map do |f|
      field_value = send(f.to_sym)
      if f == 'phone_number'
        if field_value.present?
          field_value.phony_formatted(format: :national, spaces: '-')
        else
          ''
        end
      elsif f == 'email_address'
        field_value.presence || ''
      elsif f == 'tags'
        tag_values.present? ? tag_values.join('|') : ''
      else
        field_value
      end
    end
  end

  def deactivate!(type = nil)
    self.active = false
    self.deactivated_at = Time.current
    self.deactivated_method = type if type

    save! # sends background mailchimp update
    delete_from_rapidpro # remove from rapidpro
  end

  def reactivate!
    self.active = true
    save!
    update_rapidpro
  end

  def md5_email
    Digest::MD5.hexdigest(email_address.downcase) if email_address.present?
  end

  def update_neighborhood
    n = zip_to_neighborhood(postal_code)
    self.signup_at = created_at if signup_at.nil?
    if n.present?
      self.neighborhood = n
      save
    end
  end

  def send_new_person_notifications
    User.where(new_person_notification: true).find_each do |user|
      email = user.email_address
      ::UserMailer.new_person_notify(email_address: email, person: self).deliver_later
    end
  end

  # FIXME: Refactor and re-enable cop
  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  #
  # Compare to other records in the database to find possible duplicates.
  def possible_duplicates
    @duplicates = {}
    if last_name.present?
      last_name_duplicates = Person.where(last_name: last_name).where.not(id: id)
      last_name_duplicates.each do |duplicate|
        duplicate_hash = {}
        duplicate_hash['person'] = duplicate
        duplicate_hash['match_count'] = 1
        duplicate_hash['last_name_match'] = true
        duplicate_hash['matches_on'] = ['Last Name']
        @duplicates[duplicate.id] = duplicate_hash
      end
    end
    if email_address.present?
      email_address_duplicates = Person.where(email_address: email_address).where.not(id: id)
      email_address_duplicates.each do |duplicate|
        if @duplicates.key? duplicate.id
          @duplicates[duplicate.id]['match_count'] += 1
          @duplicates[duplicate.id]['matches_on'].push('Email Address')
        else
          @duplicates[duplicate.id] = {}
          @duplicates[duplicate.id]['person'] = duplicate
          @duplicates[duplicate.id]['match_count'] = 1
          @duplicates[duplicate.id]['matches_on'] = ['Email Address']
        end
        @duplicates[duplicate.id]['email_address_match'] = true
      end
    end
    if phone_number.present?
      phone_number_duplicates = Person.where(phone_number: phone_number).where.not(id: id)
      phone_number_duplicates.each do |duplicate|
        if @duplicates.key? duplicate.id
          @duplicates[duplicate.id]['match_count'] += 1
          @duplicates[duplicate.id]['matches_on'].push('Phone Number')
        else
          @duplicates[duplicate.id] = {}
          @duplicates[duplicate.id]['person'] = duplicate
          @duplicates[duplicate.id]['match_count'] = 1
          @duplicates[duplicate.id]['matches_on'] = ['Phone Number']
        end
        @duplicates[duplicate.id]['phone_number_match'] = true
      end
    end
    if address_1.present?
      address_1_duplicates = Person.where(address_1: address_1).where.not(id: id)
      address_1_duplicates.each do |duplicate|
        if @duplicates.key? duplicate.id
          @duplicates[duplicate.id]['match_count'] += 1
          @duplicates[duplicate.id]['matches_on'].push('Address_1')
        else
          @duplicates[duplicate.id] = {}
          @duplicates[duplicate.id]['person'] = duplicate
          @duplicates[duplicate.id]['match_count'] = 1
          @duplicates[duplicate.id]['matches_on'] = ['Address_1']
        end
        @duplicates[duplicate.id]['address_1_match'] = true
      end
    end
    @duplicates
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  private

end
# rubocop:enable ClassLength
