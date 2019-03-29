class AddTotalPointsToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :total_points, :integer, default: 0
    change_column_default(:users, :game_points, 0)
  end
end
