class ChangingRewardsToRewards < ActiveRecord::Migration[5.2]
  def change
    rename :gift_cards, :rewards
    rename :card_activation, :gift_cards
    add_reference :rewards, :rewardable, polymorphic: true, index: true
    rename_column :activation_calls, :card_activation_id, :gift_card_id

    Rewards.reset_column_information
    
    Rewards.find_each do |r|
      if r.card_activation_id.present?
        r.rewardable_type = 'GiftCard'
        r.rewardable_id = r.card_activation_id
        r.save
      else
        
        c = CashCard.new()
        c.reward_id = r.id
        c.notes = r.notes
        c.person_id = r.giftable_id
        c.user_id = r.user_id
        c.created_by = r.created_by
        c.legacy_attributes = r.attributes.to_json
        c.save
        
        r.rewardable_type = 'CashCard'
        r.rewardable_id = c.id
        r.save
      end
    end
    
  end
end
