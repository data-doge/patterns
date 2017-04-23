# == Schema Information
#
# Table name: invitations
#
#  id                  :integer          not null, primary key
#  time_slot_id        :integer
#  person_id           :integer
#  created_at          :datetime
#  updated_at          :datetime
#  user_id             :integer
#  event_id            :integer
#  event_invitation_id :integer
#

# FIXME: Refactor and re-enable cop
# rubocop:disable ClassLength
class InvitationsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :set_invitation_and_visitor, only: %i[show
                                                      edit
                                                      update
                                                      destroy
                                                      confirm
                                                      cancel
                                                      change
                                                      show_actions
                                                      show_invitation
                                                      show_invitation]
  # need a before action here for authentication of invitation changes
  def new
    #   @person = Person.find_by(token: person_params[:token])

    @user = current_user
    @research_session = ResearchSession.find(params[:research_session_id])
    @invitation = Invitation.new
  end

  # rubocop:disable Metrics/MethodLength
  # TODO: refactor
  def create
    @invitation = Invitation.new(invitation_params)

    if @invitation.save
      @research_session = ResearchSession.find(params[:research_session_id])
      @research_session.invitations << @invitation
      @research_session.invitations.each(&:invite!)
      flash[:notice] = "A session has been booked for #{@invitation.start_datetime_human}"

    else
      flash[:error] = "No time slot was selected, couldn't create the invitation"
    end

    @person = @invitation.person
    respond_to do |format|
      format.js {}
      format.html { render :new }
    end
  end
  # rubocop:enable Metrics/MethodLength

  # no authorization here. yet.

  def index
    @invitations = Invitation.order(id: :desc).page(params[:page])
  end

  def show
    visitor
    @comment = Comment.new commentable: @invitation
  end

  def edit; end

  # these are our methods for people and users to edit invitations
  def confirm
    # can't confirma invitation in the past!
    render false && return unless @invitation.start_datetime > Time.current
    if @invitation.confirm && @invitation.save
      flash[:notice] = "You are confirmed for #{@invitation.start_datetime_human}, with #{@invitation.user.name}."
    else
      flash[:alert] = 'Error'
    end
    respond_to do |format|
      format.html { redirect_to calendar_path(token: @visitor.token, invitation_id: @invitation.id) }
      format.js { render text: "$('#invitationModal').modal('hide'); $('#calendar').fullCalendar( 'refetchEvents' );" }
    end
  end

  def cancel
    if @invitation.cancel
      flash[:notice] = 'Cancelled'
      @invitation.save
    else
      flash[:alert] = 'Error'
    end
    respond_to do |format|
      format.html { redirect_to calendar_path(token: @visitor.token, invitation_id: @invitation.id) }
      format.js { render text: "$('#invitationModal').modal('hide'); $('#calendar').fullCalendar( 'refetchEvents' );" }
    end
  end

  def change
    if @invitation.reschedule
      flash[:notice] = "#{@invitation.user.name} will be in touch soon to find a different time."
      @invitation.save
    else
      flash[:alert] = 'Error'
    end
    respond_to do |format|
      format.html { redirect_to calendar_path(token: @visitor.token, invitation_id: @invitation.id) }
      format.js { render text: "$('#invitationModal').modal('hide'); $('#calendar').fullCalendar( 'refetchEvents' );" }
    end
  end

  def update
    # flash a  notice here and return a js file that reloads the page
    # or calls turbolinks to reload or somesuch
    if @invitation.update(update_params)
      flash[:notice] = 'invitation updated'
    else
      flash[:error]  = 'update failed'
    end

    respond_to do |format|
      format.html { redirect_to(:back) }
    end
  end

  def destroy
    @invitation.destroy!
    respond_to do |format|
      format.html { redirect_to invitation_url }
      format.json { head :no_content }
    end
  end

  private

    def set_invitation_and_visitor
      if params[:token].present?
        @person = Person.find_by(token: params[:token])
        # if we don't have a person, see if we have a user's token.
        # thus we can provide a feed without auth1
        visitor
      end

      @invitation = Invitation.find_by(id: params[:id])
      return false unless @invitation && @invitation.owner_or_invitee?(@visitor)
      @visitor.nil? ? false : true
    end

    def visitor
      @visitor ||= @person ? @person : current_user
      PaperTrail.whodunnit = @visitor
      @visitor
    end

    # rubocop:disable Metrics/MethodLength
    def send_notifications(invitation)
      if invitation.person.preferred_contact_method == 'EMAIL'
        InvitationNotifier.notify(
          email_address: invitation.person.email_address,
          invitation: invitation
        ).deliver_later
      else
        ::InvitationSms.new(to: invitation.person, invitation: invitation).send
      end
      # notify the user
      InvitationNotifier.notify(
        email_address: invitation.user.email_address,
        invitation: invitation
      ).deliver_later
    end
    # rubocop:enable Metrics/MethodLength

    def event_params
      params.permit(:event_id)
    end

    def invitation_params
      params.require(:invitation).permit(
        :person_id,
        :research_session_id,
        :user_id,
        :aasm_event,
        :aasm_state
      )
    end

    def update_params
      params.permit(
        :id,
        :person_id,
        :time_slot_id,
        :event_id,
        :event_invitation_id,
        :user_id,
        :aasm_event,
        :aasm_state
      )
    end

    def person_params
      params.permit(:email_address, :person_id, :token)
    end

end
# rubocop:enable ClassLength
