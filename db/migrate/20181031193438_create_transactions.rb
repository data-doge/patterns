class CreateTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :transactions do |t|
      t.references :credit, index: true
      t.references :debt,  index: true
      t.integer :user_id, index: true
      t.monetize :amount
      t.timestamps
    end
  end
end
