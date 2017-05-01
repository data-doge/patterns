json.array!(@research_sessions) do |rsession|
  json.extract!     rsession, :id, :title, :description
  json.start        rsession.start_datetime
  json.end          rsession.end_datetime
  # this is because events have multiple time_slots
  if rsession.class.to_s == 'ResearchSession'
    json.rendering    'background'
    json.modal_url    calendar_show_event_path(id: rsession.id, token: @visitor.token)
  else # it's a time slot
    json.modal_url    calendar_show_invitation_path(id: rsession.id, token: @visitor.token)
  end
  json.type event.class.to_s.demodulize
  # json.url event_url(event, format: :html)
end
