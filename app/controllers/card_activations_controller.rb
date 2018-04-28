class CardActivationsController < ApplicationController
  before_action :set_card_activation, only: [:show, :edit, :update, :destroy]

  # GET /card_activations
  # GET /card_activations.json
  def index
    @card_activations = CardActivation.where(user_id: current_user.id).all
  end

  def template
    respond_to do |format|
      format.csv do
        response.headers['Content-Type'] = 'text/csv'
        output = CSV.generate do |csv|
          csv << %w( full_card_number expiration_date amount sequence_number secure_code batch_id)
        end
        send_data output, filename: "ActivationTemplate.csv"
      end
    end
  end

  # GET /card_activations/1
  # GET /card_activations/1.json
  def show
  end

  # GET /card_activations/new
  def new
    @card_activation = CardActivation.new
  end

  # GET /card_activations/1/edit
  def edit
  end

  def assign
    
    @card_activation.gift_card_id = params[:gift_card_id]
    @card_activation.save
    respond_to do |format|
      if @card_activation.errors.empty?
        format.html { redirect_to @card_activation, notice: 'Card activation was successfully created.' }
        format.json { render :show, status: :created, location: @card_activation }
        format.js {render :assign, status: :created, notice: 'Card Assigned'}
      else
         format.html { render :new }
        format.json { render json: @card_activation.errors, status: :unprocessable_entity }
      end
    end
  end
  # POST /card_activations
  # POST /card_activations.json
  def create
    @card_activation = CardActivation.new(card_activation_params)
    @card_activation.save
    # this is where we do the whole starting calls thing.
    # create activation calls type=activate
    # use after_save_commit hook to do background task.
    # 
    respond_to do |format|
      if @card_activation.errors.empty?
        format.html { redirect_to @card_activation, notice: 'Card activation was successfully created.' }
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_card_activation
      @card_activation = CardActivation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def card_activation_params
      params.fetch(:card_activation, {})
    end
end
