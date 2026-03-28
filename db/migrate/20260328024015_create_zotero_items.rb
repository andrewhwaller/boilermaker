class CreateZoteroItems < ActiveRecord::Migration[8.0]
  def change
    create_table :zotero_items do |t|
      t.references :account, null: false, foreign_key: true
      t.string :zotero_key, null: false
      t.string :item_type
      t.string :title
      t.text :authors_json
      t.text :abstract
      t.string :doi
      t.string :url
      t.date :publication_date
      t.text :tags_json
      t.text :full_text
      t.string :extraction_status, default: "pending"
      t.string :embedding_status, default: "pending"
      t.integer :library_version
      t.boolean :deleted_from_zotero, default: false, null: false
      t.timestamps
    end

    add_index :zotero_items, [ :account_id, :zotero_key ], unique: true
  end
end
