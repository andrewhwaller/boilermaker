# frozen_string_literal: true

class Components::Card < Components::Base
 def initialize(title: nil, header_color: :primary, uppercase: nil, **attrs)
 @title = title
 @header_color = header_color
 @title_uppercase = uppercase
 @attrs = attrs
 end

 def view_template(&block)
 card_class = "bg-base-200 border border-base-300"
 card_class = [ card_class, @attrs.delete(:class) ].compact.join(" ")

 div(**@attrs.merge(class: card_class)) do
 if @title.present?
 div(class: header_background_class) do
 h3(class: header_title_class) { @title }
 end
 end

 content_class = @attrs.delete(:content_class) || "p-4"

 div(class: content_class) do
 yield if block_given?
 end
 end
 end

 private

 def header_background_class
 case @header_color
 when :primary
 "bg-primary/20 border-b border-primary/30 px-3 py-1"
 when :secondary
 "bg-secondary/20 border-b border-secondary/30 px-3 py-1"
 when :accent
 "bg-accent/20 border-b border-accent/30 px-3 py-1"
 else
 "bg-primary/20 border-b border-primary/30 px-3 py-1"
 end
 end

 def header_title_class
 color_class = case @header_color
 when :primary
 "text-primary"
 when :secondary
 "text-secondary"
 when :accent
 "text-accent"
 when :error
 "text-error"
 when :success
 "text-success"
 else
 "text-primary"
 end

 classes = [ "card-title", color_class, "font-bold", "" ]
 classes << "uppercase" if @title_uppercase == true
 classes << "normal-case" if @title_uppercase == false

 classes.join(" ")
 end
end
