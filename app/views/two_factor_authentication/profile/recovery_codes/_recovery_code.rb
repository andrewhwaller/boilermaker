# frozen_string_literal: true

module Views
  module TwoFactorAuthentication
    module Profile
      module RecoveryCodes
        class RecoveryCode < Views::Base
          def initialize(recovery_code:)
            @recovery_code = recovery_code
          end

          def view_template
            # Using shared RecoveryCodeItem component
            RecoveryCodeItem(
              code: @recovery_code.code,
              used: @recovery_code.used?
            )
          end
        end
      end
    end
  end
end
