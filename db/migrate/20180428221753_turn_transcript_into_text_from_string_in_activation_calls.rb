class TurnTranscriptIntoTextFromStringInActivationCalls < ActiveRecord::Migration[5.2]
  def change
    change_column :activation_calls, :transcript, :text
  end
end
