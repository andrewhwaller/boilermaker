class CreateDocumentChunks < ActiveRecord::Migration[8.0]
  def change
    create_table :document_chunks do |t|
      t.references :zotero_item, null: false, foreign_key: true
      t.text :content, null: false
      t.integer :position, null: false
      t.string :section_heading
      t.string :embedding_model
      t.timestamps
    end

    add_index :document_chunks, [ :zotero_item_id, :position ]
  end
end
