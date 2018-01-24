class CreateJoinTableCartsPeople < ActiveRecord::Migration[5.1]
  def change
    create_join_table :carts, :people do |t|
      t.index [:cart_id, :person_id]
      t.index [:person_id, :cart_id]
    end
  end
end
