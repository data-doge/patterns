# TODO: needs a spec. The acceptance
# spec 'SMS invitation to phone call' covers it,
# but a unit test would make coverage more robust
class ResearchSessionInvitationSms < ApplicationSms
  attr_reader :to, :research_session

  def initialize(to:, research_session:)
    super
    @to = to
    @research_session = research_session
  end

  # TODO: Chunk this into 160 characters and send individualls
  def body
    body = "#{research_session.sms_description}\n"
    body << "If you're free for #{research_session.duration / 60} minutes at "
    body << "#{research_session.duration_human} please"
    body << " text back 'Yes' or 'No'\n"
  end
end
