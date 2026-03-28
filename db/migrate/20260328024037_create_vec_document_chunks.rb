class CreateVecDocumentChunks < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL
      CREATE VIRTUAL TABLE vec_document_chunks USING vec0(
        document_chunk_id integer primary key,
        embedding float[1536] distance_metric=cosine
      )
    SQL
  end

  def down
    execute "DROP TABLE IF EXISTS vec_document_chunks"
  end
end
