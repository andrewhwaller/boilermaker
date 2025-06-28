# frozen_string_literal: true

module Components
  module TwoFactorAuthentication
    module Profile
      module RecoveryCodes
        class RecoveryCode < Components::Base
          def initialize(recovery_code:)
            @recovery_code = recovery_code
          end

          def view_template
            li do
              if @recovery_code.used?
                del { plain(@recovery_code.code) }
              else
                plain(@recovery_code.code)
              end
            end
          end
        end
      end
    end
  end
end
