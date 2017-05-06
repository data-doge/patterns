class RemoveTaggingsCountOnPerson < ActiveRecord::Migration
  def change
    remove_column :people, :taggings_count
  end
end
