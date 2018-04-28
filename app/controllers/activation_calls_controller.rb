class ActivationCallsController < ApplicationController
  before_action :set_activation_call, only: [:show, 
                                             :check, 
                                             :activate,
                                             :callback]

  # GET /activation_calls
  # GET /activation_calls.json
  def index
    @activation_calls = ActivationCall.all
  end

  # GET /activation_calls/1
  # GET /activation_calls/1.json
  def show
  end

  # # GET /activation_calls/new
  # def new
  #   @activation_call = ActivationCall.new
  # end

  # # GET /activation_calls/1/edit
  # def edit
  # end

  def activate
    respond_to do |format|
      format.xml
    end
  end

  # def activate_response # this is where the gather endpoint it.
  #   # sets card to active
  # end

  def check
    respond_to do |format|
      format.xml
    end
  end

  def callback
    speech_results = params[:SpeechResult]
    @activation_call.transcript = speech_results
    if @activation_call.transcript_check
      # pass
      @activation_call.status = "success"
      @card_activation.success
    else
      # fail
      @activation_call.status = 'fail'
      if @card_activation.activation_calls.where(type:check).size < 5
        ActivationCall.create(type:'check', activation_card: @card_activation)
      else
        # noping out. 
        # count check calls, and if less than 5 do check call.
      end
    end
    @activation_call.save
    # twilio sends us the results of the gather here and we update
    # activation and call appropriately.
    # where we kick off a check if need be.
  end

  # POST /activation_calls
  # POST /activation_calls.json
  # def create
  #   @activation_call = ActivationCall.new(activation_call_params)

  #   respond_to do |format|
  #     if @activation_call.save
  #       format.html { redirect_to @activation_call, notice: 'Activation call was successfully created.' }
  #       format.json { render :show, status: :created, location: @activation_call }
  #     else
  #       format.html { render :new }
  #       format.json { render json: @activation_call.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # PATCH/PUT /activation_calls/1
  # # PATCH/PUT /activation_calls/1.json
  # def update  
  #   @activation_call.update(activation_call_params)
  #   respond_to do |format|
  #     if @activation_call.errors.empty?
  #       format.html { redirect_to @activation_call, notice: 'Activation call was successfully updated.' }
  #       format.json { render :show, status: :ok, location: @activation_call }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @activation_call.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # DELETE /activation_calls/1
  # # DELETE /activation_calls/1.json
  # def destroy
  #   @activation_call.destroy
  #   respond_to do |format|
  #     format.html { redirect_to activation_calls_url, notice: 'Activation call was successfully destroyed.' }
  #     format.json { head :no_content }
  #   end
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_activation_call
      @activation_call = ActivationCall.find(params[:id])
      @card_activation = @activation_call.card_activation
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def activation_call_params
      params.fetch(:activation_call, {})
    end
end
