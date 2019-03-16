class AddGameToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :game_id, :integer
  end
end
