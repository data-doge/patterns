class V2::CartController < ApplicationController
  include ApplicationHelper
  before_action :cart_init
  # a cart of user ids. stored in session.
  # Index
  def index
    respond_to do |format|
      format.html { @people = Person.where(id: session[:cart]) }
      format.json { render json: session[:cart].to_json }
    end
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def add
    to_add = cart_params[:person_id]
    people = Person.where(id: to_add) # only people ids here.
    people.each do |person|
      session[:cart] << person.id unless session[:cart].include?(person.id)
    end
    # don't update if we don't find a persons
    @added = people.blank? ? [] : people.map(&:id)
    respond_to do |format|
      format.js
      format.json { render json: session[:cart].to_json }
      format.html { render json: session[:cart].to_json }
    end
  end

  # Delete
  def delete
    if cart_params[:person_id].blank?
      @deleted = session[:cart]
      session[:cart] = []
    else
      @deleted = []
      Person.where(id: cart_params[:person_id]).find_each do |to_delete|
        @deleted << session[:cart].delete(to_delete.id)
      end
    end

    respond_to do |format|
      format.js
      format.json { render json: session[:cart].to_json }
      format.html { render json: session[:cart].to_json }
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  private

    def cart_params
      # person id is a single int.
      params.permit(:person_id, :all)
    end

    def cart_init
      # this is a bit of a hack here.
      # before filter seems to break things. I don't know why
      session[:cart] = (session[:cart] ||= []).map(&:to_i).uniq - [0]
    end
end
