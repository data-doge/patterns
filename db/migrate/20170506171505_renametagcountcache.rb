class Renametagcountcache < ActiveRecord::Migration
  def change
    rename_column :people, :tag_count_cache, :taggings_count
  end
end
