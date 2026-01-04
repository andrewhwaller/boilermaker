# frozen_string_literal: true

# Drag-and-drop file upload component with progress indication
#
# Usage:
#   render Components::FileUpload.new(
#     name: "user[avatar]",
#     accept: "image/*",
#     multiple: false
#   )
#
# For direct uploads (recommended for large files):
#   render Components::FileUpload.new(
#     name: "user[documents][]",
#     multiple: true,
#     direct_upload: true
#   )
#
class Components::FileUpload < Components::Base
  def initialize(name:, accept: nil, multiple: false, direct_upload: true, label: nil)
    @name = name
    @accept = accept
    @multiple = multiple
    @direct_upload = direct_upload
    @label = label || (@multiple ? "Drop files here or click to upload" : "Drop file here or click to upload")
  end

  def view_template
    div(
      class: "file-upload",
      data: {
        controller: "upload",
        upload_multiple_value: @multiple.to_s,
        upload_accept_value: @accept
      }
    ) do
      drop_zone
      file_input
      file_list
      progress_bar
    end
  end

  private

  def drop_zone
    div(
      class: drop_zone_classes,
      data: {
        upload_target: "dropzone",
        action: "dragover->upload#dragover dragenter->upload#dragenter dragleave->upload#dragleave drop->upload#drop click->upload#click"
      }
    ) do
      upload_icon
      label_text
      hint_text
    end
  end

  def drop_zone_classes
    [
      "border-2 border-dashed border-border-light rounded-lg",
      "p-8 text-center cursor-pointer",
      "transition-colors duration-200",
      "hover:border-accent hover:bg-surface-alt",
      "data-[dragging]:border-accent data-[dragging]:bg-surface-alt"
    ].join(" ")
  end

  def file_input
    input(
      type: "file",
      name: @name,
      accept: @accept,
      multiple: @multiple,
      class: "hidden",
      data: {
        upload_target: "input",
        action: "change->upload#fileSelected",
        direct_upload_url: @direct_upload ? "/rails/active_storage/direct_uploads" : nil
      }.compact
    )
  end

  def file_list
    div(
      class: "mt-4 space-y-2 hidden",
      data: { upload_target: "fileList" }
    )
  end

  def progress_bar
    div(
      class: "mt-4 hidden",
      data: { upload_target: "progress" }
    ) do
      div(class: "flex items-center justify-between text-sm text-muted mb-1") do
        span(data: { upload_target: "progressText" }) { "Uploading..." }
        span(data: { upload_target: "progressPercent" }) { "0%" }
      end
      div(class: "h-2 bg-surface-alt rounded-full overflow-hidden") do
        div(
          class: "h-full bg-accent transition-all duration-300",
          style: "width: 0%",
          data: { upload_target: "progressBar" }
        )
      end
    end
  end

  def upload_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      class: "h-12 w-12 mx-auto text-muted mb-4",
      fill: "none",
      viewBox: "0 0 24 24",
      stroke: "currentColor",
      stroke_width: "1"
    ) do |s|
      s.path(
        stroke_linecap: "round",
        stroke_linejoin: "round",
        d: "M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"
      )
    end
  end

  def label_text
    p(class: "text-body font-medium mb-1") { @label }
  end

  def hint_text
    p(class: "text-sm text-muted") do
      if @accept
        plain "Accepts: #{@accept}"
      else
        plain "Any file type"
      end
    end
  end
end
