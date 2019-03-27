class AddMaxToGame < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :max_points, :integer
  end
end
