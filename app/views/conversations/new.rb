# frozen_string_literal: true

class Views::Conversations::New < Views::Base
  def view_template
    page_with_title("New Conversation") do
      div(class: "max-w-2xl mx-auto flex flex-col items-center justify-center min-h-[60vh] space-y-8") do
        div(class: "text-center space-y-2") do
          h2(class: "text-xl font-semibold text-body") { "Start a new conversation" }
          p(class: "text-sm text-muted") { "Ask a question about your library to begin." }
        end

        div(class: "w-full") do
          form_with(
            url: conversations_path,
            method: :post,
            data: { controller: "keyboard", keyboard_new_conversation_url_value: new_conversation_path }
          ) do |f|
            div(class: "flex gap-2 items-end") do
              f.text_area :content,
                name: "content",
                placeholder: "Ask a question about your library...",
                rows: 3,
                autofocus: true,
                class: "ui-input flex-1 resize-none",
                data: {
                  keyboard_target: "textarea",
                  action: "keydown->keyboard#textareaKeydown"
                }

              f.submit "Send",
                class: "ui-button ui-button-sm flex-shrink-0 self-end"
            end
          end
        end
      end
    end
  end
end
