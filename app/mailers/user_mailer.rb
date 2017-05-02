class UserMailer < ApplicationMailer
  def new_person_notify(email_address:, person:)
    admin_email = ENV['MAILER_SENDER']
    @person = person
    mail(to: email_address,
         from: admin_email,
         subject: "New Person: #{person.full_name}")
  end

  def session_reminder(user_id:, session_ids:)
    @user = User.find(user_id)
    @sessions = ResearchSession.find(session_ids)
    mail(to: @user.email_address,
        from: ENV['MAILER_SENDER'],
        subject: "Research Sessions Reminder!")
  end
end
