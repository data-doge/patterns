class RenameGiftrocketToDigitalGift < ActiveRecord::Migration[5.2]
  def change
    rename_table :giftrockets, :digital_gifts
  end
end
