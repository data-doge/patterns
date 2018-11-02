class ChangingGiftCardsToRewards < ActiveRecord::Migration[5.2]

  def change
    rename_table :gift_cards, :rewards
    rename_table :card_activations, :gift_cards
    add_reference :rewards, :rewardable, polymorphic: true, index: true
    rename_column :activation_calls, :card_activation_id, :gift_card_id    
  end
end
