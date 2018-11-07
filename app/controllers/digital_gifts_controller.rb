# frozen_string_literal: true

class DigitalGiftsController < ApplicationController
  before_action :set_digital_gift, only: %i[show edit update destroy]

  # GET /digital_gifts
  # GET /digital_gifts.json
  def index
    @digital_gifts = DigitalGift.order(id: 'desc').includes(:reward).page(params[:page])
  end

  # GET /digital_gifts/1
  # GET /digital_gifts/1.json
  def show; end

  # GET /digital_gifts/new
  def new
    @digital_gift = DigitalGift.new
  end

  def create
    # this is kinda horrific
    klass = GIFTABLE_TYPES.fetch(params[:giftable_type])
    @giftable = klass.find(params[:giftable_id])
    @success = true
    if @giftable.nil?
      flash[:error] = 'No giftable object present'
      @success = false
    end

    if params[:giftable_type] == 'Invitation' && !@giftable&.attended?
      flash[:error] = "#{@giftable.person.full_name} isn't marked as 'attended'."
      @success = false
    end

    if params[:giftable_type] == 'Invitation' && @giftable.rewards.find {|r| r.rewardable_type == 'DigitalGift'}.present?
      flash[:error] = "#{@giftable.person.full_name} Already has a digital gift"
      @success = false
    end

    if params[:amount].to_money >= current_user.available_budget
      flash[:error] = 'Insufficient Team Budget'
      @success = false # placeholder for now
    end

    # so, the APIs are wonky
    # if params[:amount].to_money >= DigitalGift.current_budget
    #   flash[:error] = 'Insufficient Gift Rocket Budget'
    #   @success = false # placeholder for now
    # end
    if @success
      @dg = DigitalGift.new(user_id: current_user.id,
                          created_by: current_user.id,
                          amount: dg_params['amount'],
                          person_id: dg_params['person_id'],
                          giftable_type: dg_params['giftable_type'],
                          giftable_id: dg_params['giftable_id'])

      @reward = Reward.new(user_id: current_user.id,
                         created_by: current_user.id,
                         person_id: dg_params['person_id'],
                         amount: dg_params['amount'],
                         reason: dg_params['reason'],
                         notes: dg_params['notes'],
                         giftable_type: dg_params['giftable_type'],
                         giftable_id: dg_params['giftable_id'],
                         finance_code: current_user&.team&.finance_code,
                         team: current_user&.team,
                         rewardable_type: 'DigitalGift')

      @transaction = TransactionLog.new(transaction_type: 'DigitalGift',
                           from_id: current_user.budget.id,
                           user_id: current_user.id,
                           amount: dg_params['amount'],
                           from_type: 'Budget',
                           recipient_type: 'DigitalGift')

      if @transaction.valid? && @dg.valid? # if it's not valid, error out
        @dg.request_link # do the thing!
        if @dg.save
          @transaction.recipient_id = @dg.id
          @transaction.save
          @reward.rewardable_id = @dg.id
          @success = @reward.save
          @dg.reward_id = @reward.id # is this necessary?
          @dg.save
        end
      else
        flash[:error] = @dg.errors
        @success = false
      end
    end

    respond_to do |format|
      format.js {}
    end
  end
  # GET /digital_gifts/1/edit
  # def edit; end

  # we don't create, destroy or update these via controller

  # # POST /digital_gifts
  # # POST /digital_gifts.json
  # def create
  #   @digital_gift = DigitalGift.new(digital_gift_params)

  #   respond_to do |format|
  #     if @digital_gift.save
  #       format.html { redirect_to @digital_gift, notice: 'DigitalGift was @successfully created.' }
  #       format.json { render :show, status: :created, location: @digital_gift }
  #     else
  #       format.html { render :new }
  #       format.json { render json: @digital_gift.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # PATCH/PUT /digital_gifts/1
  # # PATCH/PUT /digital_gifts/1.json
  # def update
  #   respond_to do |format|
  #     if @digital_gift.update(digital_gift_params)
  #       format.html { redirect_to @digital_gift, notice: 'DigitalGift was @successfully updated.' }
  #       format.json { render :show, status: :ok, location: @digital_gift }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @digital_gift.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # DELETE /digital_gifts/1
  # DELETE /digital_gifts/1.json
  # def destroy
  #   @digital_gift.destroy
  #   respond_to do |format|
  #     format.html { redirect_to digital_gifts_url, notice: 'DigitalGift was @successfully destroyed.' }
  #     format.json { head :no_content }
  #   end
  # end

  private

    def dg_params
      params.permit(:person_id,
        :user_id,
        :notes,
        :reason,
        :amount,
        :giftable_type,
        :giftable_id)
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_digital_gift
      @digital_gift = DigitalGift.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def digital_gift_params
      params.fetch(:digital_gift, {})
    end
end
