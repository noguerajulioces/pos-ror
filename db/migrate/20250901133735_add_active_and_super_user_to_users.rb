class AddActiveAndSuperUserToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :active, :boolean, default: true, null: false
    add_column :users, :super_user, :boolean, default: false, null: false
  end
end
