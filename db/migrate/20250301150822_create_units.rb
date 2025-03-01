class CreateUnits < ActiveRecord::Migration[8.0]
  def change
    create_table :units do |t|
      t.string :name
      t.string :abbreviation
      t.text :description

      t.timestamps
    end
  end
end
