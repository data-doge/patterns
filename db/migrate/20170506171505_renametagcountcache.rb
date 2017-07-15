class Renametagcountcache < ActiveRecord::Migration[4.2]
  def change
    rename_column :people, :tag_count_cache, :taggings_count
  end
end
