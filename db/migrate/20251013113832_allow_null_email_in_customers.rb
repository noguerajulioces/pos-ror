class AllowNullEmailInCustomers < ActiveRecord::Migration[8.0]
  def change
    change_column_null :customers, :email, true
  end
end
