# == Schema Information
#
# Table name: reservations
#
#  id           :integer          not null, primary key
#  person_id    :integer
#  event_id     :integer
#  confirmed_at :datetime
#  created_by   :integer
#  attended_at  :datetime
#  created_at   :datetime
#  updated_at   :datetime
#  updated_by   :integer
#

require 'faker'

FactoryBot.define do
  factory :reservation, class: Invitation do
    person
    user
    event
    event_invitation
    time_slot

    before(:create) do |reservation|
      event_invitation = FactoryBot.create(:event_invitation)
      reservation.person =  event_invitation.invitees.first
      reservation.event = event_invitation.event
      reservation.user = event_invitation.user
      reservation.time_slot = FactoryBot.create(:time_slot, event: event_invitation.event)
    end
  end
end
