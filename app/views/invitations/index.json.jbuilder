json.array!(@invitations) do |invitation|
  json.extract! invitation, :person_id, :research_session_id, :aasm_state, :user_id
  json.url invitation_url(invitation, format: :json)
end
