# frozen_string_literal: true

module Views
  module Layouts
    class Mailer < Views::Base
      def view_template(&block)
        doctype

        html do
          head do
            meta("http-equiv": "Content-Type", content: "text/html; charset=utf-8")
            style { "/* Email styles need to be inline */" }
          end

          body(&block)
        end
      end
    end
  end
end
