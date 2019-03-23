class AddSequenceToCards < ActiveRecord::Migration[5.2]
  def change
    add_column :cards, :sequence, :integer
  end
end
