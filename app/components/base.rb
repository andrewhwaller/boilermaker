# frozen_string_literal: true

class Components::Base < Phlex::HTML
  include Components
  include Phlex::Rails::Helpers::Routes

  if Rails.env.development?
    def before_template
      comment { "Before #{self.class.name}" }
      super
    end
  end

  protected

  def generate_id_from_name(name)
    name.to_s.gsub(/[\[\]]/, "_").gsub(/__+/, "_").chomp("_")
  end

  def filtered_attributes(*exclude_keys)
    @attributes.except(*exclude_keys, :class)
  end

  def css_classes(*class_arrays)
    [*class_arrays, @attributes[:class]].compact.flatten
  end
end
