class UserMailer < ApplicationMailer
  def new_person_notify(email_address:, person:)
    admin_email = ENV['MAILER_SENDER']
    @person = person
    mail(to: email_address,
         from: admin_email,
         subject: "New Person: #{person.full_name}")
  end
end
