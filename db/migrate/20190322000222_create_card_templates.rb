class CreateCardTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :card_templates do |t|
      t.string :color
      t.string :text

      t.timestamps
    end
  end
end
