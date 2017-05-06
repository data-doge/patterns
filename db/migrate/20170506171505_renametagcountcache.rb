class Renametagcountcache < ActiveRecord::Migration
  def change
    rename_table :person, :tag_count_cache, :taggings_count
  end
end
