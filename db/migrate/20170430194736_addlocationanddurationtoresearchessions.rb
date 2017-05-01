class Addlocationanddurationtoresearchessions < ActiveRecord::Migration
  def change
    add_column :research_sessions, :location, :string
    add_column :research_sessions, :duration, :integer, default: 60
  end
end
