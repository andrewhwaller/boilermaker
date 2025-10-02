class RemoveAccountIdFromUsers < ActiveRecord::Migration[8.0]
  def up
    remove_foreign_key :users, :accounts if foreign_key_exists?(:users, :accounts)
    remove_index :users, :account_id if index_exists?(:users, :account_id)
    remove_column :users, :account_id
  end

  def down
    add_reference :users, :account, foreign_key: true
  end
end
