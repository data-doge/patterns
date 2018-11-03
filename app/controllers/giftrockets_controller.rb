# frozen_string_literal: true

class GiftrocketsController < ApplicationController
  before_action :set_giftrocket, only: %i[show edit update destroy]

  # GET /giftrockets
  # GET /giftrockets.json
  def index
    @giftrockets = Giftrocket.all
  end

  # GET /giftrockets/1
  # GET /giftrockets/1.json
  def show; end

  # GET /giftrockets/new
  def new
    @giftrocket = Giftrocket.new
  end

  # GET /giftrockets/1/edit
  def edit; end

  # POST /giftrockets
  # POST /giftrockets.json
  def create
    @giftrocket = Giftrocket.new(giftrocket_params)

    respond_to do |format|
      if @giftrocket.save
        format.html { redirect_to @giftrocket, notice: 'Giftrocket was successfully created.' }
        format.json { render :show, status: :created, location: @giftrocket }
      else
        format.html { render :new }
        format.json { render json: @giftrocket.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /giftrockets/1
  # PATCH/PUT /giftrockets/1.json
  def update
    respond_to do |format|
      if @giftrocket.update(giftrocket_params)
        format.html { redirect_to @giftrocket, notice: 'Giftrocket was successfully updated.' }
        format.json { render :show, status: :ok, location: @giftrocket }
      else
        format.html { render :edit }
        format.json { render json: @giftrocket.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /giftrockets/1
  # DELETE /giftrockets/1.json
  def destroy
    @giftrocket.destroy
    respond_to do |format|
      format.html { redirect_to giftrockets_url, notice: 'Giftrocket was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_giftrocket
      @giftrocket = Giftrocket.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def giftrocket_params
      params.fetch(:giftrocket, {})
    end
end
