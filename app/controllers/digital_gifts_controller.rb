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

  # GET /digital_gifts/1/edit
  # def edit; end

  # we don't create, destroy or update these via controller

  # # POST /digital_gifts
  # # POST /digital_gifts.json
  # def create
  #   @digital_gift = DigitalGift.new(digital_gift_params)

  #   respond_to do |format|
  #     if @digital_gift.save
  #       format.html { redirect_to @digital_gift, notice: 'DigitalGift was successfully created.' }
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
  #       format.html { redirect_to @digital_gift, notice: 'DigitalGift was successfully updated.' }
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
  #     format.html { redirect_to digital_gifts_url, notice: 'DigitalGift was successfully destroyed.' }
  #     format.json { head :no_content }
  #   end
  # end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_digital_gift
      @digital_gift = DigitalGift.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def digital_gift_params
      params.fetch(:digital_gift, {})
    end
end
