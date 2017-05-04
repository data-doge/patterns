class EmailController < ApplicationController
  def inbound
    Rails.logger.info(params)
    AdminMailer.inbound_email(params).deliver_later
  end
end
