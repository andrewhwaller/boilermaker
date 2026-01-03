class AddImpersonatorToSessions < ActiveRecord::Migration[8.0]
  def change
    add_reference :sessions, :impersonator, null: true, foreign_key: { to_table: :users }
  end
end
