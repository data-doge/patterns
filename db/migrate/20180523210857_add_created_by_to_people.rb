class AddCreatedByToPeople < ActiveRecord::Migration[5.2]
  def change
    add_column :people, :created_by, :integer
  end
end
