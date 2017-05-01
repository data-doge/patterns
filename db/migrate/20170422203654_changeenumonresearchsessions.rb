class Changeenumonresearchsessions < ActiveRecord::Migration
  def change
    rename_column :research_sessions, :type, :session_type
  end
end
