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
  before_action :parse_dates, only: [:create, :update]

  def new
    if session[:person_id].present?
      @people_ids =  params[:person_id]
    elsif session[:cart].present?
      @people_ids = session[:cart]
    end
    @research_session = ResearchSession.new
  end

  def create
    people_ids = params[:research_session][:people_ids]

    @research_session = ResearchSession.new(research_session_params)
    if @research_session.save

      #@research_session.tag_list(research_session_params[:tags])

      # need to handle case when the invitation is invalid
      # i.e. timing overlaps, etc.
      p_params = people_ids.map do |pid|
        { person_id: pid, research_session_id: @research_session.id }
      end

      Invitation.create(p_params)

      # sends all of the invitations.
      @research_session.invitations.each(&:invite)

      render edit_research_session_path
    else
      errors = @research_session.errors.full_messages.join(', ')
      flash[:error] = 'There were problems with some of the fields: ' + errors
      render new_research_session_path
    end
  end

  def index
    @research_sessions = ResearchSession.all.order(id: :desc).page(params[:page])
  end

  def show
    @research_session =  ResearchSession.find(params[:id])
  end

  def update
    # the usual
  end

  def add_person
    # allow new people to be added to research session.
  end

  private

    def parse_dates
      if params[:end_datetime].present? && params[:start_datetime].present?
        params[:end_datetime] = Time.zone.parse(params[:end_datetime])
        params[:start_datetime] = Time.zone.parse(params[:start_datetime])
      end
    end

    # rubocop:disable Metrics/MethodLength
    def research_session_params
      params.require(:research_session).permit(
        :description,
        :sms_description,
        :session_type,
        :start_datetime,
        :end_datetime,
        :buffer,
        :title,
        :user_id
      ).merge(user_id: current_user.id).symbolize_keys
    end
  # rubocop:enable Metrics/MethodLength
end
