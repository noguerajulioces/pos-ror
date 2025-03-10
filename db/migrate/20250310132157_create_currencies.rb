class CreateCurrencies < ActiveRecord::Migration[8.0]
  def change
    create_table :currencies do |t|
      t.string :name
      t.string :code
      t.string :symbol
      t.decimal :exchange_rate
      t.string :flag_url
      t.boolean :display

      t.timestamps
    end
  end
end
