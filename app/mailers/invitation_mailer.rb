class EventInvitationMailer < ApplicationMailer
  def invite(email_address:, invitation:, person:)
    admin_email = ENV['MAILER_SENDER']
    @email_address = email_address
    @invitation = invitation
    @person = person
    mail(to: email_address,
         from: admin_email,
         bcc: admin_email,
         subject: @invitation.title)
  end
end
