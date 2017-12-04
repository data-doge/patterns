#

class Public::PeopleController < ApplicationController
  layout false
  after_action :allow_iframe
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!

  # GET /people/new
  def new
    @referrer = false
    if params[:referrer]
      begin
        uri = URI.parse(params[:referrer])
        @referrer = params[:referrer] if uri.is_a?(URI::HTTP)
      rescue URI::InvalidURIError
        @referrer = false
      end
    end
    @person = ::Person.new
  end

  def update_tags
    if ENV['RAPIDPRO_KEY'] != update_params[:token]
      redirect_to root_path
    end

    phone_number = PhonyRails.normalize_number(update_params[:phone_number])
    @person = Person.find_by(phone_number: phone_number)
    if @person
      tags = update_params[:tags].split(',')
      @person.tag_list.add(tags)
      @person.save
      render json: { success: true }
    else
      render json: { success: false }
    end
  end

  # POST /people
  # rubocop:disable Metrics/MethodLength
  def create
    @person = ::Person.new(person_params)
    @person.signup_at = Time.current

    success_msg = 'Thanks! We will be in touch soon!'
    error_msg   = "Oops! Looks like something went wrong. Please get in touch with us at <a href='mailto:#{ENV['MAILER_SENDER']}?subject=Patterns sign up problem'>#{ENV['MAILER_SENDER']}</a> to figure it out!"

    @person.tag_list.add(params[:age_range]) if params[:age_range].present?

    if params[:referral].present?
      @person.referred_by = params[:referral][0, 100] # only 100 characters
    end

    @msg = @person.save ? success_msg : error_msg
    respond_to do |format|
      format.html { render action: 'create' }
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  def deactivate
    @person = Person.find_by(token: d_params[:token])

    if @person && @person.id == d_params[:person_id].to_i
      @person.deactivate!('email')
      @person.save
      ::AdminMailer.deactivate(person: @person).deliver_later
    else
      redirect_to root_path
    end
  end

  private

    def update_params
      params.permit(:phone_number, :tags, :token, :note)
    end

    def d_params
      params.permit(:person_id, :token)
    end

    # rubocop:disable Metrics/MethodLength
    def person_params
      params.require(:person).permit(:first_name,
        :last_name,
        :email_address,
        :phone_number,
        :preferred_contact_method,
        :low_income,
        :address_1,
        :address_2,
        :city,
        :state,
        :postal_code,
        :token,
        :primary_device_id,
        :primary_device_description,
        :secondary_device_id,
        :secondary_device_description,
        :primary_connection_id,
        :primary_connection_description,
        :secondary_connection_id,
        :secondary_connection_description,
        :participation_type,
        :referred_by)
    end
    # rubocop:enable Metrics/MethodLength

    def allow_iframe
      response.headers.except! 'X-Frame-Options'
    end
end
