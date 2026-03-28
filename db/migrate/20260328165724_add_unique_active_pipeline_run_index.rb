# frozen_string_literal: true

class AddUniqueActivePipelineRunIndex < ActiveRecord::Migration[8.0]
  def change
    # Prevent concurrent active pipeline runs per account at the DB level.
    # SQLite partial index: only one row per account where status is 'pending' or 'running'.
    add_index :pipeline_runs, :account_id,
              unique: true,
              where: "status IN ('pending', 'running')",
              name: "index_pipeline_runs_one_active_per_account"
  end
end
