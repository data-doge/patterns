class PersonMailer < ApplicationMailer
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

  def notify(email_address:, invitation:)
    @email_address = email_address
    @invitation = invitation

    attachments['event.ics'] = { mime_type: 'application/ics', content: generate_ical(invitation) }

    mail(to: email_address,
         from: invitation.user.email,
         bcc: bcc_or_nil(email_address, invitation),
         subject: 'Interview scheduled',
         content_type: 'multipart/mixed')
  end

  def remind(email_address:, invitations:)
    @email_address = email_address
    @invitations = invitations

    mail(to: email_address,
         from: ENV['MAILER_SENDER'],
         bcc: bcc_or_nil(email_address, invitations.first),
         subject: 'Today\'s Interview Reminders',
         content_type: 'multipart/mixed')
  end

  def cancel(email_address:, invitation:)
    @email_address = email_address
    @invitation = invitation

    mail(to: email_address,
         from: ENV['MAILER_SENDER'],
         bcc: bcc_or_nil(email_address, invitation),
         subject: "Canceled: #{invitation.start_datetime_human}",
         content_type: 'multipart/mixed')
  end

  def confirm(email_address:, invitation:)
    @email_address = email_address
    @invitation = invitation

    mail(to: email_address,
         from: ENV['MAILER_SENDER'],
         bcc: bcc_or_nil(email_address, invitation),
         subject: "Confirmed: #{invitation.start_datetime_human}",
         content_type: 'multipart/mixed')
  end

  def reschedule(email_address:, invitation:)
    @email_address = email_address
    @invitation = invitation

    mail(to: email_address,
         from: ENV['MAILER_SENDER'],
         bcc: bcc_or_nil(email_address, invitation),
         subject: "Need to Reschedule: #{invitation.start_datetime_human}",
         content_type: 'multipart/mixed')
  end

  private

    # if the email is to the user, don't bcc!
    def bcc_or_nil(email_address, invitation)
      invitation.user.email == email_address ?  nil : invitation.user.email
    end

    def generate_ical(invitation)
      cal = Icalendar::Calendar.new
      cal.add_event(invitation.to_ical)
      cal.publish
      cal.to_ical
    end
end
