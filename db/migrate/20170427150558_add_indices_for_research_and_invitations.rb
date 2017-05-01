class AddIndicesForResearchAndInvitations < ActiveRecord::Migration
  def change
    add_index :invitations, :person_id
    add_index :invitations, :research_session_id
    add_index :research_sessions, :user_id
  end
end
