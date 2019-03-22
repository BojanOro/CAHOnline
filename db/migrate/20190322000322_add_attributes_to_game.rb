class AddAttributesToGame < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :state, :string
    add_column :games, :card_tzar_id, :integer
  end
end
