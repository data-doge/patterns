# frozen_string_literal: true

class RewardsController < ApplicationController
  before_action :set_gift_card, only: %i[show edit update destroy]
  helper_method :sort_column, :sort_direction

  GIFTABLE_TYPES = {
    'Person'     => Person,
    'Invitation' => Invitation
  }.freeze

  # GET /gift_cards
  # GET /gift_cards.csv
  def index
    @q_rewards = if current_user.admin?
                   Reward.ransack(params[:q])
                  else
                    Reward.where(created_by: current_user.id).ransack(params[:q])
                  end
    @q_rewards.sorts = [sort_column + ' ' + sort_direction] if @q_Rewards.sorts.empty?
    respond_to do |format|
      format.html do
        @rewards = @q_rewards.result.includes(:person, :giftable).order(id: :desc).page(params[:page])
        # @recent_signups = Person.no_signup_card.paginate(page: params[:page]).where('signup_at > :startdate', { startdate: 3.months.ago }).order('signup_at DESC')
      end
      format.csv do
        @rewards = @q_rewards.result.includes(:person, :giftable)
        send_data @rewards.export_csv,  filename: "Rewards-#{Time.zone.today}.csv"
      end
    end
  end

  # GET /recent_signups
  # GET /recent_signups.csv
  def recent_signups
    @q_recent_signups = Person.no_signup_card.ransack(params[:q_signups], search_key: :q_signups)

    unless params[:q_signups]
      @q_recent_signups.created_at_date_gteq = 3.weeks.ago.strftime('%Y-%m-%d')
    end

    @recent_signups = @q_recent_signups.result.order(id: :desc).page(params[:page_signups])

    @new_rewards = []
    @recent_signups.length.times do
      @new_grewards << Reward.new
    end
  end

  # GET /gift_cards/1
  # GET /gift_cards/1.json
  def show; end

  # GET /gift_cards/new
  def new
    @last_reward = Reward.where.not(batch_id: '5555').last # default scope is id: :desc
    @gift_reward = Reward.new
  end

  # GET /gift_cards/1/edit
  def edit; end

  # POST /gift_cards
  # POST /gift_cards.json
  def create # this is gonna be a doozy
    @reward = Reward.new(reward_params)

    @total = @gift_card.person.blank? ? @gift_card.amount : @gift_card.person.gift_card_total

    @gift_card.created_by = current_user.id
    @gift_card.finance_code = current_user&.team&.finance_code
    @gift_card.team = current_user&.team
    @gift_card.save

    @create_result = @gift_card.save
    respond_to do |format|
      if @create_result
        format.js {}
        format.json {}
        format.html { redirect_to @gift_card, notice: 'Gift Card was successfully created.'  }
      else
        flash[:error] = "Error adding Reward! #{@gift_card.errors.full_messages.join(', ')}"
        format.js {}
        format.html { render action: 'edit' }
        format.json { render json: @gift_card.errors, status: :unprocessable_entity }
      end
    end
  end

  # takes an card_activation_id, person_id, and sessionid
  def assign
    @card = GiftCard.find(params[:gift_card_id])
    ca = @card # for shortness.
    @reward = Reward.new(sequence_number: ca.sequence_number,
                              batch_id: ca.batch_id,
                              gift_card_number: ca.full_card_number.last(4),
                              person_id: params[:person_id],
                              giftable_type: params[:giftable_type],
                              giftable_id: params[:giftable_id],
                              finance_code: current_user&.team&.finance_code,
                              team: current_user&.team,
                              created_by: current_user.id)

    @total = @reward.person.rewards_total
    @create_result = @reward.save

    respond_to do |format|
      if @create_result
        format.js { render action: :create }
        format.json {}
        format.html { redirect_to @rewadd, notice: 'Reward was successfully created.'  }
      else
        format.js {}
        format.html { render action: 'edit' }
        format.json { render json: @reward.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /gift_cards/1
  # PATCH/PUT /gift_cards/1.json
  def update
    respond_to do |format|
      if @reward.update(gift_card_params)
        format.html { redirect_to @reward, notice: 'Reward was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @reward.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gift_cards/1
  # DELETE /gift_cards/1.json
  def destroy
    @giftable = @reward.giftable
    @reward.destroy
    @giftable&.reload # weirdo.
    respond_to do |format|
      format.html { redirect_back(fallback_location: rewards_path) }
      format.json { head :no_content }
      format.js {}
    end
  end

  def modal
    klass = GIFTABLE_TYPES.fetch(params[:giftable_type])
    @giftable = klass.find(params[:giftable_id])
    @gift_cards = if current_user.admin?
                          GiftCard.unassigned.active
                        else
                          GiftCard.unassigned.active.where(user_id: current_user.id)
                        end
    @reward = Reward.new
    @last_gift_card = Reward.last # default scope is id: :desc
    respond_to do |format|
      format.html
      format.js
    end
  end

  def sort_column
    Reward.column_names.include?(params[:sort]) ? params[:sort] : 'people.id'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'desc'
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_reward
      @reward = Reward.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def reward_params
      params.require(:reward).permit(:gift_card_number,
        :batch_id,
        :expiration_date,
        :person_id,
        :notes,
        :sequence_number,
        :created_by,
        :reason,
        :amount,
        :giftable_id,
        :giftable_type,
        :team_id,
        :finance_code,
        :card_activation_id)
    end
end
