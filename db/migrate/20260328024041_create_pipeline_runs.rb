class CreatePipelineRuns < ActiveRecord::Migration[8.0]
  def change
    create_table :pipeline_runs do |t|
      t.references :account, null: false, foreign_key: true
      t.string :status, default: "pending", null: false
      t.string :current_stage
      t.integer :items_total, default: 0
      t.integer :items_processed, default: 0
      t.integer :items_failed, default: 0
      t.text :error_message
      t.datetime :started_at
      t.datetime :completed_at
      t.timestamps
    end
  end
end
