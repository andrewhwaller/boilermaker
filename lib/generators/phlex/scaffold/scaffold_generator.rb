# frozen_string_literal: true

module Phlex::Generators
  class ScaffoldGenerator < ::Rails::Generators::NamedBase
    source_root File.expand_path("templates", __dir__)

      argument :attributes, type: :array, default: [], banner: "field[:type][:index] field[:type][:index]"

      class_option :model_name, type: :string, desc: "ModelName to be used"

      def create_views
        %w[index show new edit].each do |view|
          @view_name = view
          template "#{view}.rb.erb", File.join("app/views", class_path, plural_file_name, "#{view}.rb")
        end

        # Create the form partial
        @view_name = "form"
        template "_form.rb.erb", File.join("app/views", class_path, plural_file_name, "_form.rb")
      end

      private

      def model_name
        @model_name ||= (options[:model_name] || class_name).classify
      end

      def plural_table_name
        @plural_table_name ||= model_name.tableize
      end

      def singular_table_name
        @singular_table_name ||= model_name.tableize.singularize
      end

      def instance_name
        "@#{singular_table_name}"
      end

      def plural_instance_name
        "@#{plural_table_name}"
      end

      def attributes_list
        return [] if attributes.empty?
        
        attributes.map do |attr|
          { name: attr.name, type: attr.type.to_s }
        end
      end

      def display_attributes
        return [{ name: 'name', type: 'string' }] if attributes_list.empty?
        
        # Filter out timestamps and id
        attributes_list.reject { |attr| %w[id created_at updated_at].include?(attr[:name]) }
      end

      def form_attributes
        display_attributes
      end
    end
  end 