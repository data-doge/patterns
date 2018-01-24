class CreateJoinTableCartsUser < ActiveRecord::Migration[5.1]
  def change
    create_join_table :carts, :users do |t|
      t.index [:cart_id, :user_id]
      t.index [:user_id, :cart_id]
    end
  end
end
