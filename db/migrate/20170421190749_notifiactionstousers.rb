class Notifiactionstousers < ActiveRecord::Migration
  def change
    add_column :users, :new_person_notification, :boolean, default: false
  end
end
