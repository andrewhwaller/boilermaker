class AddPersonalToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :personal, :boolean, default: false, null: false
    add_index :accounts, :personal
  end
end
