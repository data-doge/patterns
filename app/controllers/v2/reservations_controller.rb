# == Schema Information
#
# Table name: v2_reservations
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

class V2::ReservationsController < ApplicationController
  skip_before_action :authenticate_user!

  def new
    @person = Person.find_by(token: person_params[:token])

    redirect_to root_url unless @person

    @event_invitation = V2::EventInvitation.find_by(v2_event_id: event_params[:event_id])
    @user = @event_invitation.user
    @event = @event_invitation.event
    @available_time_slots = @event.available_time_slots(@person)
    @reservation = V2::Reservation.new(time_slot: V2::TimeSlot.new)
  end

  # rubocop:disable Metrics/MethodLength
  # TODO: refactor
  def create
    @reservation = V2::Reservation.new(reservation_params)
    if @reservation.save
      flash[:notice] = "An interview has been booked for #{@reservation.time_slot.to_weekday_and_time}"
      send_notifications(@reservation)
    else
      flash[:error] = "No time slot was selected, couldn't create the reservation"
    end
    @available_time_slots = []
    @person = @reservation.person
    respond_to do |format|
      format.js {}
      format.html { render :new }
    end
  end
  # rubocop:enable Metrics/MethodLength

  private

    def send_notifications(reservation)
      ReservationNotifier.notify(
        email_address: reservation.person.email_address,
        reservation: reservation
      ).deliver_later
    end

    def event_params
      params.permit(:event_id)
    end

    def reservation_params
      params.require(:v2_reservation).permit(
        :person_id,
        :time_slot_id,
        :event_id,
        :event_invitation_id,
        :user_id)
    end

    def person_params
      params.permit(:email_address, :person_id, :token)
    end

end
