class AdminMailer < ApplicationMailer
  def deactivate(person:)
    admin_email = ENV['MAILER_SENDER']
    @person = person
    mail(to: admin_email,
         from: admin_email,
         subject: "Deactivated: #{person.full_name}")
  end
end