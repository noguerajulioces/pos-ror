class AddChoiceGroupToComboItems < ActiveRecord::Migration[8.0]
  def change
    add_reference :combo_items, :choice_group, null: true, foreign_key: { to_table: :modifier_groups }
  end
end
