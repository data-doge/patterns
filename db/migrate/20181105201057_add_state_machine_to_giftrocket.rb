class AddStateMachineToGiftrocket < ActiveRecord::Migration[5.2]
  def change
    add_column :giftrockets, :aasm_state, :string, default: 'initialized'
    add_column :giftrockets, :external_id, :string
    add_column :giftrockets, :link, :string
    add_column :giftrockets, :order_id, :string
    add_column :giftrockets, :gift_id, :string
    add_monetize :giftrockets, :fee
  end
end
