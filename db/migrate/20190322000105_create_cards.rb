class CreateCards < ActiveRecord::Migration[5.2]
  def change
    create_table :cards do |t|
      t.integer :game_id
      t.integer :card_template_id
      t.integer :user_id
      t.string :face
      t.string :status

      t.timestamps
    end
  end
end
