# frozen_string_literal: true
require 'csv'
class CardActivationsController < ApplicationController
  before_action :set_card_activation, only: %i[show edit update destroy change_user check]

  # GET /card_activations
  # GET /card_activations.json
  def index
    @errors = []
    @new_card = CardActivation.new
    if current_user.admin?
      @card_activations = CardActivation.unassigned.page(params[:page])
    else
      @card_activations = CardActivation.unassigned.where(user_id: current_user.id).page(params[:page])
    end
  end

  def template
    respond_to do |format|
      format.csv do
        response.headers['Content-Type'] = 'text/csv'
        response.headers['Content-Disposition'] = 'attachment; filename=CardActivationTemplate.csv'
        output = CSV.generate do |csv|
          csv << %w[full_card_number expiration_date amount sequence_number secure_code batch_id]
        end
        send_data output, filename: 'CardActivationTemplate.csv'
      end
    end
  end

  def check
    @card_activation.create_check_call(override: true)
    flash[:notice] = "Checking Card ##{@card_activation.last_4}"
    respond_to do |format|
      format.json { render json: { success: true }, status: :ok }
    end
  end

  # GET /card_activations/1
  # GET /card_activations/1.json
  def show; end

  # GET /card_activations/new
  def new
    @card_activation = CardActivation.new
  end

  # GET /card_activations/1/edit
  def edit; end

  # assignment happens in gift_card_controller

  def upload
    cards_count = CSV.read(params[:file].path, headers: true).count
    flash[:notice] = "Import started for #{cards_count} cards."
    @errors = CardActivation.import(params[:file].path, current_user)
    if @errors.empty?
      redirect_to card_activations_path
    else
      flash[:error] = "Error! #{@errors.size} cards not valid."
      # show individual erros in ui
    end
  end

  # POST /card_activations
  # POST /card_activations.json
  def create
    @card_activation = CardActivation.new(card_activation_params)
    @card_activation.user = current_user
    @card_activation.start_activate! if @card_activation.save


    # this is where we do the whole starting calls thing.
    # create activation calls type=activate
    # use after_save_commit hook to do background task.
    #
    respond_to do |format|
      if @card_activation.errors.empty?
        format.html { redirect_to @card_activation, notice: 'Card Activation process started.' }
        format.json { render :show, status: :created, location: @card_activation }
      else
        format.html { render :new }
        format.json { render json: @card_activation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /card_activations/1
  # PATCH/PUT /card_activations/1.json
  def update
    respond_to do |format|
      if @card_activation.update(card_activation_params) && current_user.admin?
        format.html { redirect_to @card_activation, notice: 'Card activation was successfully updated.' }
        format.json { render :show, status: :ok, location: @card_activation }
      else
        format.html { render :edit }
        format.json { render json: @card_activation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /card_activations/1
  # DELETE /card_activations/1.json
  def destroy
    @card_activation.destroy if current_user.admin?
    respond_to do |format|
      if current_user.admin?
        format.html { redirect_to card_activations_url, notice: 'Card activation was successfully destroyed.' }
        format.json { head :no_content }
      else
        format.json { render json: @card_activation, status: :unauthorized }
        format.html { redirect_to card_activations_url, notice: 'Not Authorized' }
      end
    end
  end

  def change_user
    if current_user.admin?
      # https://stackoverflow.com/questions/18358717/ruby-elegantly-convert-variable-to-an-array-if-not-an-array-already
      ca = Array.wrap(@card_activation)
      ca.each { |c| c.user_id = params[:user_id] }
      ca.each(&:save)
      flash[:notice] = "#{ca.size } Cards owner changed to #{ca.first.user.name}"
    end
    respond_to do |format|
      format.json { render json:{success: true}.to_json, status: :ok}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_card_activation
      if params[:id].include? ','
        ca_id = params[:id].split(',')
      else
        ca_id = params[:id]
      end

      @card_activation = CardActivation.find(ca_id)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def card_activation_params
      allowed = %i(amount batch_id expiration_date full_card_number secure_code sequence_number)
       
      params.fetch(:card_activation, {}).permit(allowed)
    end
end
