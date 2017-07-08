#

class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  after_action :flash_to_headers

  # this is so that json requests don't redirect without a user
  before_action :authenticate_user!
  # before_action :authenticate_user!, unless: request.format == :json
  # before_action :user_needed, if: request.format == :json

  before_action :set_paper_trail_whodunnit
  before_action :set_global_search_variable

  def set_global_search_variable
    @q = Person.ransack(params[:q])
  end

  def user_needed
    unless current_user
      render json: { 'error' => 'authentication error' }, status: 401
    end
  end

  def current_cart
    current_user.current_cart(session[:cart_id])
  end

  def flash_to_headers
    return unless request.xhr?
    response.headers['X-Message'] = flash_message if flash_message
    response.headers['X-Message-Type'] = flash_type.to_s if flash_type
    flash.discard # don't want the flash to appear when you reload page
  end

  private

    def flash_message
      %i[error warning notice].each do |type|
        return flash[type] if flash[type].present?
      end
      nil
    end

    def flash_type
      %i[error warning notice].each do |type|
        return type if flash[type].present?
      end
      nil
    end

end
