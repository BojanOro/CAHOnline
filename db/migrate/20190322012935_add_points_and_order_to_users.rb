class AddPointsAndOrderToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :game_points, :integer
    add_column :users, :join_order, :integer
  end
end
