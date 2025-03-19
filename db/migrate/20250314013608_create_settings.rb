class CreateSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :settings do |t|
      t.string :var
      t.text :value

      t.timestamps
    end
  end
end
