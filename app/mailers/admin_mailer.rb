# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  def deactivate(person:)
    admin_email = ENV['MAIL_ADMIN']
    @person = person
    mail(to: admin_email,
         from: admin_email,
         subject: "Deactivated: #{person.full_name}")
  end

  def inbound_email(from:, subject:, text:)
    mail(to: ENV['MAIL_ADMIN'],
         reply_to: from,
         subject: "from: #{from}, subj:#{subject}",
         body: text)
  end
end
