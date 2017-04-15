module Fastlane
  module Helper
    class FirebaseHelper
      # class methods that you define here become available in your action
      # as `Helper::FirebaseHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the firebase plugin helper!")
      end
    end
  end
end
