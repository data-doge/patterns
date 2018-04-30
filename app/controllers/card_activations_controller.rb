# frozen_string_literal: true

class CardActivationsController < ApplicationController
  before_action :set_card_activation, only: %i[show edit update destroy change_user]
  before_action :admin?, only: :change_user

  # GET /card_activations
  # GET /card_activations.json
  def index
    @card_activations = CardActivation.where(user_id: current_user.id).page(params[:page])
  end

  def template
    respond_to do |format|
      format.csv do
        response.headers['Content-Type'] = 'text/csv'
        output = CSV.generate do |csv|
          csv << %w[full_card_number expiration_date amount sequence_number secure_code batch_id]
        end
        send_data output, filename: 'ActivationTemplate.csv'
      end
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
    # receive csv file, check each card for luhn, save card activations
    #
    cards_count = CSV.read(params[:file], headers: true).count
    flash[:notice] = "Import started for #{cards_count} cards."
    @errors = CardActivation.import(params[:file], current_user)
    if @errors.empty?
      redirect_to card_activations_path
    else
      flash[:error] = "Error! #{errors.size} cards not valid."
      # show individual erros in ui
    end
  end

  # POST /card_activations
  # POST /card_activations.json
  def create
    @card_activation = CardActivation.new(card_activation_params)
    @card_activation.user = current_user
    @card_activation.save
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
      if @card_activation.update(card_activation_params)
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
    @card_activation.destroy
    respond_to do |format|
      format.html { redirect_to card_activations_url, notice: 'Card activation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def change_user
    # only admins can swap user for card activations
  end

  private

    def admin?
      current_user.admin?
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_card_activation
      @card_activation = CardActivation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def card_activation_params
      params.fetch(:card_activation, {})
    end
end
