class AddTimestampsToEventEventInvitations < ActiveRecord::Migration[4.2]
  def change
    change_table(:v2_event_invitations) { |t| t.timestamps }
    change_table(:v2_events) { |t| t.timestamps }
  end
end
