# == Schema Information
#
# Table name: researchsession
#
#  id              :integer          not null, primary key
#  v2_event_id     :integer
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
    # people_ids should come from a session.
    @people_ids = session[:cart].blank? ? '' : session[:cart].uniq.join(',')

    @research_session = ResearchSession.new(people: @people_ids)
    @people = @research_session.people
  end

  def create
    @research_session = ResearchSession.new(research_session_params)
    if @research_session.save
      send_notifications(@research_session)
      session[:cart] = []
      # this needs to change
      flash[:notice] = "#{@research_session.people.size} invitations sent!"
    else
      errors = @research_session.errors.full_messages.join(', ')
      flash[:error] = 'There were problems with some of the fields: ' + errors
    end

    render new_research_session_path
  end

  def index
    @research_sessions = ResearchSession.all.order(id: :desc).page(params[:page])
  end

  def show
    @research_session =  ResearchSession.find(params[:id])
  end

  private

    def send_notifications(_research_session)
      # needs fixing
      reserch_session.invitations.each do |invitee|
        case invitee.person.preferred_contact_method.upcase
        when 'SMS'
          send_sms(invitee.person, invitee)
        when 'EMAIL'
          send_email(invitee.person, invitee)
        end
      end
    end

    def send_email(person, invitation)
      InvitationMailer.invite(
        email_address: person.email_address,
        invitation:  invitation,
        person: person
      ).deliver_later
    end

    def send_sms(person, invitation)
      # we send a bunch at once, delay it. Plus this has extra logic
      Delayed::Job.enqueue(SendInvitationsSmsJob.new(person, invitation))
    end

    # TODO: add a nested :event
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
        :user_id
      ).merge(user_id: current_user.id)
    end
  # rubocop:enable Metrics/MethodLength
end
