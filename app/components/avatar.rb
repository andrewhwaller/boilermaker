# frozen_string_literal: true

class Components::Avatar < Components::Base
  SIZES = {
    xs: "w-6",
    sm: "w-8",
    md: "w-12", 
    lg: "w-16",
    xl: "w-20"
  }.freeze

  SHAPES = {
    circle: "rounded-full",
    square: "rounded"
  }.freeze

  def initialize(
    src: nil, 
    alt: nil,
    initials: nil, 
    size: :md, 
    shape: :circle,
    online: nil,
    placeholder: false,
    **attributes
  )
    @src = src
    @alt = alt
    @initials = initials
    @size = size
    @shape = shape
    @online = online
    @placeholder = placeholder
    @attributes = attributes
  end

  def view_template(&block)
    div(class: "avatar #{online_class}") do
      div(class: avatar_classes) do
        if @src.present?
          img(src: @src, alt: @alt || "Avatar", **@attributes)
        elsif @initials.present?
          render_initials
        elsif @placeholder
          render_placeholder
        else
          render_default_avatar
        end

        # Status indicator if online status is provided
        render_status_indicator if @online.present?
      end

      yield if block
    end
  end

  private

  def avatar_classes
    [
      SIZES[@size],
      SHAPES[@shape]
    ].join(" ")
  end

  def online_class
    case @online
    when true
      "online"
    when false  
      "offline"
    else
      ""
    end
  end

  def render_initials
    div(class: "bg-neutral text-neutral-content flex items-center justify-center") do
      span(class: "text-sm font-medium") { @initials }
    end
  end

  def render_placeholder
    div(class: "bg-neutral-focus") do
      # Empty placeholder div
    end
  end

  def render_default_avatar
    div(class: "bg-neutral text-neutral-content flex items-center justify-center") do
      svg(
        class: "w-1/2 h-1/2",
        fill: "currentColor",
        viewBox: "0 0 20 20",
        xmlns: "http://www.w3.org/2000/svg"
      ) do |s|
        s.path(
          fill_rule: "evenodd",
          d: "M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z",
          clip_rule: "evenodd"
        )
      end
    end
  end

  def render_status_indicator
    span(class: "absolute bottom-0 right-0 w-3 h-3 bg-green-400 border-2 border-white rounded-full") if @online
  end
end