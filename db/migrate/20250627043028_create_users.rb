class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.boolean :verified, default: false
      t.boolean :otp_required_for_sign_in, default: false
      t.string :otp_secret
      t.references :account, null: false, foreign_key: true

      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
