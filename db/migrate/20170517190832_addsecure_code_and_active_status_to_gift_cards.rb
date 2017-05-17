class AddsecureCodeAndActiveStatusToGiftCards < ActiveRecord::Migration
  def change
    add_column :gift_cards, :active, :boolean, default: false
    add_column :gift_cards, :secure_code, :string
  end
end
