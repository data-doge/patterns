class CreateCarts < ActiveRecord::Migration
  def change
    create_table :carts do |t|
      t.string :name, default: 'default'
      t.integer :user_id, null: false
      t.string :people_ids, default: [].to_json
      t.timestamps null: false
      t.index :user_id
    end

  end
end
