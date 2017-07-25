# == Schema Information
#
# Table name: researchsession
#
#  id              :integer          not null, primary key
#  email_addresses :string(255)
#  description     :string(255)
#  slot_length     :string(255)
#  date            :string(255)
#  start_time      :string(255)
#  end_time        :string(255)
#  buffer          :integer          default(0), not null
#  created_at      :datetime
#  updated_at      :datetime
#  user_id         :integer
#

class ResearchSessionsController < ApplicationController
  before_action :parse_dates, only: %i[create update]

  def new
    @research_session = ResearchSession.new
  end

  def create
    @research_session = ResearchSession.new(research_session_params)
    if @research_session.save

      @research_session.tag_list.add(params['tags'])

      # need to handle case when the invitation is invalid
      # i.e. timing overlaps, etc.
      i_params = params['research_session']['invitations_attributes']

      if i_params.present?
        people = i_params.values.map do |v|
          { person_id: v['person_id'],
            research_session_id: @research_session.id }
        end

        Invitation.create(people) # auto associates
      end

      if @research_session.location.blank?
        @research_session.location = "Call #{current_user.name} at #{current_user.phone_number}"
      end
      @research_session.save

      # sends all of the invitations.
      if params[:send_invites][:boolean_attribute] != 'false'
        @research_session.invitations.each(&:invite!)
      end

      redirect_to research_session_path(@research_session)
    else
      errors = @research_session.errors.full_messages.join(', ')
      flash[:error] = 'There were problems with some of the fields: ' + errors
      redirect_to new_research_session_path
    end
  end

  def index
    @s = ResearchSession.ransack(params[:q])

    @research_sessions = @s.result(distinct: true).includes(:people, :tags, :user).page(params[:page])
  end

  def show
    @research_session = ResearchSession.find(params[:id])
  end

  def invitations_panel
    @research_session =  ResearchSession.find(params[:research_session_id])
    render partial: 'invitations_panel',
      locals: { invitations: @research_session.invitations }
  end

  def update
    respond_to do |format|
      if @research_session.update(research_session_params)
        format.html { redirect_to(@research_session, notice: 'Session was successfully updated.') }
        format.json { respond_with_bip(@research_session) }
      else
        format.html { render :edit }
        format.json { respond_with_bip(@research_session) }
      end
    end
  end

  def add_person
    @research_session =  ResearchSession.find(params[:research_session_id])
    state = params[:invited].present? ? params[:invited] : 'created'
    inv = Invitation.new(person_id: params[:person_id], aasm_state: state)
    @research_session.invitations << inv
    if @research_session.save
      flash[:notice] = "#{Person.find(inv.person_id).full_name} added to session!"
    end
    respond_to do |format|
      format.js
    end
  end

  private

    def parse_dates
      if params[:end_datetime].present? && params[:start_datetime].present?
        params[:end_datetime] = Time.zone.parse(params[:end_datetime])
        params[:start_datetime] = Time.zone.parse(params[:start_datetime])
      end
    end

    def research_session_params
      params.require(:research_session).permit(
        :description,
        :sms_description,
        :session_type,
        :duration,
        :location,
        :start_datetime,
        :end_datetime,
        :buffer,
        :title,
        :user_id
      ).to_h.symbolize_keys
    end

  # rubocop:enable Metrics/MethodLength
end
