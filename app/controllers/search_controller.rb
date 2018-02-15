# rubocop:disable ClassLength
class SearchController < ApplicationController

  include PeopleHelper
  include GsmHelper
  include SearchHelper



  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/BlockLength
  def index_ransack
    if params[:q].present? && params[:q][:ransack_tagged_with].present?
      t = params[:q][:ransack_tagged_with].split(',').map(&:strip)
      @tags = Person.tag_counts.where(name: t).order(taggings_count: :desc)
    else
      @tags = []

    end
    @q = Person.ransack(params[:q])
    @results = @q.result.includes(:tags).page(params[:page])


    # Need to better define these
    @participation_list = Person.pluck(:participation_type).uniq
    @verified_list = Person.pluck(:verified).uniq
    @mailchimp_result = 'Mailchimp export not attempted with this search'

    respond_to do |format|
      format.json { @results }
      format.html do
        if params[:segment_name].present?
          list_name = params.delete(:segment_name)
          @q = Person.ransack(params[:q])
          @results_mailchimp = @q.result.includes(:tags)
          @mce = MailchimpExport.new(name: list_name, recipients: @results_mailchimp.collect(&:email_address), created_by: current_user.id)
          if @mce.with_user(current_user).save
            Rails.logger.info("[SearchController#export] Sent #{@mce.recipients.size} email addresses to a static segment named #{@mce.name}")
            @success = "Sent #{@mce.recipients.size} email addresses to a static segment named #{@mce.name}"
            flash[:success] = "Successfully sent to mailchimp: #{@mce.errors.inspect}"
          else
            Rails.logger.error("[SearchController#export] failed to send event to mailchimp: #{@mce.errors.inspect}")
            @error = "failed to send search to mailchimp: #{@mce.errors.inspect}"
            flash[:failure] = "failed to send search to mailchimp: #{@mce.errors.inspect}"
          end
        end
      end
      format.csv do
        @results = @q.result.includes(:tags)
        fields = Person.column_names
        fields.push('tags')
        output = CSV.generate do |csv|
          # Generate the headers
          csv << fields.map(&:titleize)

          # Some fields need a helper method
          human_devices = %w[primary_device_id secondary_device_id]
          human_connections = %w[primary_connection_id secondary_connection_id]

          # Write the results
          @results.each do |person|
            csv << fields.map do |f|
              field_value = person[f]
              if human_devices.include? f
                human_device_type_name(field_value)
              elsif human_connections.include? f
                human_connection_type_name(field_value)
              elsif f == 'phone_number'
                if field_value.present?
                  field_value.phony_formatted(format: :national, spaces: '-')
                else
                  ''
                end
              elsif f == 'tags'
                if person.tag_values.blank?
                  ''
                else
                  person.tag_values.join('|')
                end
              else
                field_value
              end
            end
          end
        end
        send_data output,  filename: "Search-#{Time.zone.today}.csv"
      end
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/BlockLength

  # FIXME: Refactor and re-enable cop
  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  #
  def export_ransack
    list_name = params.delete(:segment_name)
    @q = Person.ransack(params[:q])
    @results = @q.result.includes(:tags)
    @mce = MailchimpExport.new(name: list_name, recipients: @results.collect(&:email_address), created_by: current_user.id)
    if @mce.with_user(current_user).save
      Rails.logger.info("[SearchController#export] Sent #{@mce.recipients.size} email addresses to a static segment named #{@mce.name}")
      respond_to do |format|
        format.js {}
      end
    else
      Rails.logger.error("[SearchController#export] failed to send event to mailchimp: #{@mce.errors.inspect}")
      format.all { render text: "failed to send event to mailchimp: #{@mce.errors.inspect}", status: 400 }
    end
  end

  def export
    # send all results to a new static segment in mailchimp
    list_name = params.delete(:segment_name)
    @q = Person.ransack(params[:q])
    @people = @q.result.includes(:tags)
    @mce = MailchimpExport.new(name: list_name, recipients: @people.collect(&:email_address), created_by: current_user.id)

    if @mce.with_user(current_user).save
      Rails.logger.info("[SearchController#export] Sent #{@mce.recipients.size} email addresses to a static segment named #{@mce.name}")
      respond_to do |format|
        format.js {}
      end
    else
      Rails.logger.error("[SearchController#export] failed to send event to mailchimp: #{@mce.errors.inspect}")
      format.all { render text: "failed to send event to mailchimp: #{@mce.errors.inspect}", status: 400 }
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  # FIXME: Refactor and re-enable cop
  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Style/MethodName, Style/VariableName
  #
  def exportTwilio
    # send messages to all people
    message1 = params.delete(:message1)
    message2 = params.delete(:message2)
    message1 = to_gsm0338(message1)
    message2 = to_gsm0338(message2) if message2.present?
    messages = Array[message1, message2]
    smsCampaign = params.delete(:twiliowufoo_campaign)
    @q = Person.ransack(params[:q])
    @people = @q.result.includes(:tags)
    Rails.logger.info("[SearchController#exportTwilio] people #{@people}")
    phone_numbers = @people.collect(&:phone_number)
    Rails.logger.info("[SearchController#exportTwilio] people #{phone_numbers}")
    phone_numbers = phone_numbers.reject { |e| e.to_s.blank? }
    @job_enqueue = Delayed::Job.enqueue SendTwilioMessagesJob.new(messages, phone_numbers, smsCampaign)
    if @job_enqueue.save
      Rails.logger.info("[SearchController#exportTwilio] Sent #{phone_numbers} to Twilio")
      respond_to do |format|
        format.js {}
      end
    else
      Rails.logger.error('[SearchController#exportTwilio] failed to send text messages')
      format.all { render text: 'failed to send text messages', status: 400 }
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Style/MethodName, Style/VariableName

  def advanced
    @search = ransack_params
    @search.build_grouping unless @search.groupings.any?
    @people  = ransack_result
  end

  private

    def ransack_params
      Person.includes(:tags,:comments).ransack(params[:q])
    end

    def ransack_result
      @search.result(distinct: user_wants_distinct_results?)
    end

    # lotta params...
    # rubocop:disable Metrics/MethodLength,
    def index_params
      params.permit(:q,
        :adv,
        :active,
        :first_name,
        :last_name,
        :email_address,
        :postal_code,
        :phone_number,
        :verified,
        :device_description,
        :connection_description,
        :device_id_type,
        :connection_id_type,
        :geography_id,
        :event_id,
        :address,
        :city,
        :submissions,
        :tags,
        :preferred_contact_method,
        :page)
    end
  # rubocop:enable Metrics/MethodLength
end
# rubocop:enable ClassLength
