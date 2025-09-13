class CreateAccountMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :account_memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true

      # Uniform schema across adapters: JSON column for roles
      # On Postgres this is `json` (not `jsonb`); on SQLite this maps to TEXT with JSON1 helpers.
      t.json :roles, null: false, default: {}

      t.timestamps
    end

    add_index :account_memberships, [ :user_id, :account_id ], unique: true
  end
end
