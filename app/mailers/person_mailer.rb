class PersonMailer < ApplicationMailer

  # how to get the groovy "accept/decline" thingy...
  # http://stackoverflow.com/questions/27514552/how-to-get-rsvp-buttons-through-icalendar-gem
  # I beleive we will likely have to have inbound email for it to work
  def invite(invitation:, person:)
    Rails.logger.info("inviting #{person.full_name} to #{invitation.id}")
    @person = person
    @email_address = @person.email_address
    @invitation = invitation

    attachments['event.ics'] = { mime_type: 'application/ics',
                                 content: generate_ical(invitation) }

    mail(to: @email_address,
         subject: @invitation.title,
         content_type: 'multipart/mixed')
  end

  def remind(email_address:, invitations:)
    Rails.logger.info("reminding #{email_address} of #{invitation.id}")
    @email_address = email_address
    @invitations = invitations

    mail(to: @email_address,
         subject: 'Today\'s Interview Reminders',
         content_type: 'multipart/mixed')
  end

  def cancel(email_address:, invitation:)
    @email_address = email_address
    @invitation = invitation

    mail(to: @email_address,
         subject: "Canceled: #{invitation.start_datetime_human}",
         content_type: 'multipart/mixed')
  end

  def confirm(email_address:, invitation:)
    @email_address = email_address
    @invitation = invitation

    mail(to: email_address,
         subject: "Confirmed: #{invitation.start_datetime_human}",
         content_type: 'multipart/mixed')
  end

  private

    def generate_ical(invitation)
      cal = Icalendar::Calendar.new
      cal.add_event(invitation.to_ics)
      cal.publish
      cal.to_ical
    end
end
