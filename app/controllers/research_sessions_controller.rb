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

    @session = Session.new(people: @people_ids)
    @people = @session.people
  end

  def create
    @session = Session.new(session_params)
    if @session.save
      send_notifications(@session)
      session[:cart] = []
      flash[:notice] = "#{@session.people.size} invitations sent!"
    else
      errors = @session.errors.full_messages.join(', ')
      flash[:error] = 'There were problems with some of the fields: ' + errors
    end

    render new_v2_session_path
  end

  def index
    @sessions = Session.all.order(id: :desc).page(params[:page])
  end

  def show
    @sessions =  Session.find(params[:id])
  end

  private

    def send_notifications(session)
      session.people.each do |invitee|
        case invitee.preferred_contact_method.upcase
        when 'SMS'
          send_sms(invitee, session)
        when 'EMAIL'
          send_email(invitee, session)
        end
      end
    end

    def send_email(person, session)
      EventInvitationMailer.invite(
        email_address: person.email_address,
        session:  session,
        person: person
      ).deliver_later
    end

    def send_sms(person, session)
      # we send a bunch at once, delay it. Plus this has extra logic
      Delayed::Job.enqueue(SendEventInvitationsSmsJob.new(person, session))
    end

    # TODO: add a nested :event
    # rubocop:disable Metrics/MethodLength
    def session_params
      params.require(:v2_session).permit(
        :people_ids,
        :description,
        :slot_length,
        :date,
        :start_time,
        :end_time,
        :buffer,
        :title,
        :user_id
      ).merge(user_id: current_user.id)
    end
  # rubocop:enable Metrics/MethodLength
end
