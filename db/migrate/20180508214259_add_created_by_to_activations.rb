class AddCreatedByToActivations < ActiveRecord::Migration[5.2]
  def change
    add_column :card_activations, :created_by, :integer
  end
end
