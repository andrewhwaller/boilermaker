class AddAccountIdToSessions < ActiveRecord::Migration[8.0]
  def change
    add_reference :sessions, :account, null: true, foreign_key: true, index: true
    add_index :sessions, [ :user_id, :account_id ]
  end
end
