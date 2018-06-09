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

  def participation_level_change(to:, person:, old_level:)
    msg = %(Hi!
    Participation level for #{person.full_name} changed from #{old_level} to #{person.participation_level}
    link: https://#{HOSTNAME}/people/#{person.id})
    admin_email = ENV['MAIL_ADMIN']
    mail(to: to,
         from: admin_email,
         subject: "Participation level Change: #{person.full_name}",
         body: msg)
  end
end
