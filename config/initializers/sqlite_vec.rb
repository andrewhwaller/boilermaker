# frozen_string_literal: true

require "sqlite_vec"

# Load the sqlite-vec extension into every new SQLite database connection.
# This enables vector search via virtual tables (vec0).
# NOTE: Do NOT use the `extensions:` key in database.yml — the Rails 8
# SQLite adapter does not support it.
#
# We hook into configure_connection so the extension is available on every
# connection in the pool, including test worker connections.
ActiveSupport.on_load(:active_record) do
  ActiveRecord::ConnectionAdapters::SQLite3Adapter.prepend(
    Module.new do
      def configure_connection
        super
        raw_connection.enable_load_extension(true)
        SqliteVec.load(raw_connection)
        raw_connection.enable_load_extension(false)
      end

      # Exclude vec0 virtual tables from schema dumps.
      # Rails' virtual_tables schema dumper cannot handle vec0 because the
      # VIRTUAL_TABLE_REGEX doesn't match the multiline vec0 CREATE statement,
      # leaving `arguments` nil and crashing schema dump. We filter them out.
      def virtual_tables
        super.reject { |table_name, _options| table_name.start_with?("vec_") }
      end
    end
  )
end

# Exclude sqlite-vec shadow tables from schema dumps.
# The vec_document_chunks virtual table creates shadow tables that Rails cannot
# dump correctly. We ignore them so schema.rb remains valid Ruby.
# The virtual table itself must be created via migration (not schema:load).
ActiveSupport.on_load(:active_record) do
  ActiveRecord::SchemaDumper.ignore_tables += [
    "vec_document_chunks",
    "vec_document_chunks_chunks",
    "vec_document_chunks_info",
    "vec_document_chunks_rowids",
    "vec_document_chunks_vector_chunks00"
  ]
end
