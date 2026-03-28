class CreateMessageSources < ActiveRecord::Migration[8.0]
  def change
    create_table :message_sources do |t|
      t.references :message, null: false, foreign_key: true
      t.references :document_chunk, null: false, foreign_key: true
      t.float :relevance_score
      t.timestamps
    end

    add_index :message_sources, [ :message_id, :document_chunk_id ], unique: true
  end
end
