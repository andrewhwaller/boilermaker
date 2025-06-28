module Views
  module UserMailer
    class Base < Views::Base
      include Phlex::Rails::Helpers::LinkTo

      def footer
        hr

        p do
          plain("Have questions or need help? Just reply to this email and our support team will help you sort it out.")
        end
      end
    end
  end
end
