class RemoveTaggingsCountOnPerson < ActiveRecord::Migration[4.2]
  def change
    remove_column :people, :taggings_count
  end
end
