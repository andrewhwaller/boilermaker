# frozen_string_literal: true

# File preview component for ActiveStorage attachments
#
# Usage:
#   render Components::FilePreview.new(attachment: @user.avatar)
#   render Components::FilePreview.new(attachment: @document.file, size: :large)
#
class Components::FilePreview < Components::Base
  include Phlex::Rails::Helpers::ImageTag
  include Phlex::Rails::Helpers::LinkTo

  SIZES = {
    small: { width: 64, height: 64 },
    medium: { width: 128, height: 128 },
    large: { width: 256, height: 256 }
  }.freeze

  def initialize(attachment:, size: :medium, show_filename: true, downloadable: true)
    @attachment = attachment
    @size = size
    @show_filename = show_filename
    @downloadable = downloadable
  end

  def view_template
    return unless @attachment&.attached?

    div(class: "file-preview") do
      preview_content
      file_info if @show_filename
    end
  end

  private

  def preview_content
    if image?
      image_preview
    else
      document_preview
    end
  end

  def image_preview
    div(class: image_container_classes) do
      if @attachment.representable?
        image_tag @attachment.representation(resize_to_limit: dimensions),
                  class: "object-cover w-full h-full rounded",
                  alt: @attachment.filename.to_s
      else
        image_tag @attachment,
                  class: "object-cover w-full h-full rounded",
                  alt: @attachment.filename.to_s
      end
    end
  end

  def document_preview
    div(class: document_container_classes) do
      file_icon
    end
  end

  def file_info
    div(class: "mt-2") do
      filename_display

      if @downloadable
        download_link
      end
    end
  end

  def filename_display
    p(class: "text-sm text-body truncate", title: @attachment.filename.to_s) do
      plain @attachment.filename.to_s
    end
  end

  def download_link
    p(class: "text-xs text-muted") do
      link_to "Download",
              Rails.application.routes.url_helpers.rails_blob_path(@attachment, disposition: "attachment"),
              class: "text-accent hover:underline"
    end
  end

  def image?
    @attachment.content_type&.start_with?("image/")
  end

  def dimensions
    SIZES[@size] || SIZES[:medium]
  end

  def image_container_classes
    size = dimensions
    [
      "overflow-hidden rounded border border-border-light",
      "w-[#{size[:width]}px] h-[#{size[:height]}px]"
    ].join(" ")
  end

  def document_container_classes
    size = dimensions
    [
      "flex items-center justify-center rounded border border-border-light bg-surface-alt",
      "w-[#{size[:width]}px] h-[#{size[:height]}px]"
    ].join(" ")
  end

  def file_icon
    extension = @attachment.filename.extension_without_delimiter.upcase

    div(class: "text-center") do
      svg(
        xmlns: "http://www.w3.org/2000/svg",
        class: "h-8 w-8 mx-auto text-muted mb-2",
        fill: "none",
        viewBox: "0 0 24 24",
        stroke: "currentColor",
        stroke_width: "1"
      ) do |s|
        s.path(
          stroke_linecap: "round",
          stroke_linejoin: "round",
          d: "M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
        )
      end
      span(class: "text-xs font-medium text-muted") { extension }
    end
  end
end
