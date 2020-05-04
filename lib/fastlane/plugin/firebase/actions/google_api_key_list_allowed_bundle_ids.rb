module Fastlane
  module Actions
    class GoogleApiKeyListAllowedBundleIdsAction < Action
      def self.run(params)
        manager = Firebase::Manager.new
        # Login
        api = manager.login(params[:username], params[:password])

        key_info = api.get_apikey(params[:project_number], params[:api_key_id])
        case params[:type]
        when 'ios'
          key_info['iosKeyDetails']['allowedBundleIds'].each do |bundle|
            UI.message bundle
          end
        when 'android'
          key_info['androidKeyDetails']['allowedApplications'].each do |app|
            UI.message app['packageName']
          end
        end
      end

      def self.description
        "An unofficial tool to access Firebase"
      end

      def self.authors
        ["Jonathan Lewis"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "Get iOS Bundle IDs allowed to access an API Key"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :username,
                                  env_name: "FIREBASE_USERNAME",
                               description: "Username for your google account",
                                  optional: false),
          FastlaneCore::ConfigItem.new(key: :password,
                                  env_name: "FIREBASE_PASSWORD",
                                 sensitive: true,
                               description: "Password to your firebase account",
                                  optional: true),
          FastlaneCore::ConfigItem.new(key: :project_number,
                                  env_name: "GOOGLE_PROJECT_NUMBER",
                               description: "Project number",
                                  optional: false),
          FastlaneCore::ConfigItem.new(key: :api_key_id,
                                  env_name: "GOOGLE_API_KEY_ID",
                               description: "API Key ID to retrieve details for",
                                  optional: false),
          FastlaneCore::ConfigItem.new(key: :type,
                               description: "ios or android",
                                  optional: false)
 
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
