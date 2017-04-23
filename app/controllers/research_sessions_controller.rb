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
  def new
    @research_session = ResearchSession.new
  end

  def create
    people_ids = research_session_params.delete(:people_ids)
    @research_session = ResearchSession.new(research_session_params)
    if @research_session.save

      # need to handle case when the invitation is invalid
      # i.e. timing overlaps, etc.
      p_params = people_ids.map { |p| { person_id: p } }

      @research_session.invitations << Invitation.create(p_params)
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

    # rubocop:disable Metrics/MethodLength
    def session_params
      params.require(:research_session).permit(
        :people_ids,
        :description,
        :sms_description,
        :session_type,
        :start_datetime,
        :end_datetime,
        :buffer,
        :title,
        :tags,
        :user_id
      ).merge(user_id: current_user.id)
    end
  # rubocop:enable Metrics/MethodLength
end
