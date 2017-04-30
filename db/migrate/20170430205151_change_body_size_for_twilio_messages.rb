class ChangeBodySizeForTwilioMessages < ActiveRecord::Migration
  def change
    change_column :twilio_messages, :body, :text
  end
end
