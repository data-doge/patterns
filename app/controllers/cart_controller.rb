# frozen_string_literal: true

class CartController < ApplicationController
  include ApplicationHelper
  before_action :cart_init

  # Index
  def index
    @people = @cart.people
    
    respond_to do |format|
      format.html {  @people }
      format.json { render json: @people.map(&:id) }
    end
  end

  # rubocop:disable Metrics/MethodLength
  def add
    people = Person.where(id: cart_params[:person_id])
    @added = []
    people.each do |person|
      @added << person.id unless @cart.people.include? person
      @cart.people << person
    end
    @cart.save
    respond_to do |format|
      format.js
      format.json { render json: @cart.people.map(&:id) }
      format.html { render json: @cart.people.map(&:id) }
    end
  end
  # rubocop:enable Metrics/MethodLength

  # Delete
  # rubocop:disable Metrics/MethodLength
  def delete
    if cart_params[:person_id].blank?
      @deleted = @cart.people.map(&:id)
      @cart.people = []
    else
      @deleted = [cart_params[:person_id]]
      person = Person.find(cart_params[:person_id])
      @cart.people.delete(person) if person.present?
    end
    @cart.save

    respond_to do |format|
      format.js
      format.json { render json: @cart.to_json }
      format.html { render json: @cart.to_json }
    end
  end
  # rubocop:enable Metrics/MethodLength

  def carts
    current_user.reload
    @carts = current_user.carts.map { |c| { id: c.id, name: c.name }}

    respond_to do |format|
      # format.js
      format.json { render json: @carts }
      format.html { render json: @carts }
    end
  end

  def change_cart
    session[:cart_id] = cart_params[:id]
    cart_init
    respond_to do |format|
      # format.js
      format.json { render json: { success: true,
                                   cart_id: @cart.id,
                                   cart_name: cart_name }
                                 }
    end
  end

  private

    def cart_params
      params.permit(:person_id, :all, :type, :name, :id, :user)
    end

    def cart_init
      @type = cart_params[:type].blank? ? 'full' : cart_params[:type]

      @cart = current_user.current_cart(session[:cart_id])
      session[:cart_id] = @cart.id
    end
end
