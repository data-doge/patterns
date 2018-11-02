class MoveOldRewardsToNewRecords < ActiveRecord::Migration[5.2]
  def change
    Reward.reset_column_information
    Reward.find_each do |r|
      r.user_id = r.created_by
      gc = GiftCard.find_by(reward_id: r.id)
      if gc.present?
        r.rewardable_type = 'GiftCard'
        r.rewardable_id = gc.id
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
      end
      r.save
    end

  end
end
