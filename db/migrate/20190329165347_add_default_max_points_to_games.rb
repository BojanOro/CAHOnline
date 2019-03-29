class AddDefaultMaxPointsToGames < ActiveRecord::Migration[5.2]
  def change
    change_column_default(:games, :max_points, 10)
  end
end
