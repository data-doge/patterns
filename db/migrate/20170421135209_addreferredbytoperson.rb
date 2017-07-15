class Addreferredbytoperson < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :referred_by, :string
  end
end
