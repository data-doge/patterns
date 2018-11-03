# frozen_string_literal: true

class GiftCardEventChannel < ApplicationCable::Channel
  def subscribed
    stream_from "gift_card_event_#{current_user.id}_channel"
  end

  def unsubscribed
    stop_all_streams
  end

  def log_me
    logger.info("logging: #{current_user.id}")
  end
end
