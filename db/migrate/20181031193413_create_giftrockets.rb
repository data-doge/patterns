class CreateGiftrockets < ActiveRecord::Migration[5.2]
  def change
    create_table :giftrockets do |t|
      t.text :order_details
      t.integer :created_by, null: false
      t.integer :user_id
      t.integer :person_id
      t.integer :reward_id
      t.timestamps
    end
  end
end
