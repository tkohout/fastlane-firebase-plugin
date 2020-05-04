require 'base64'

module Fastlane
  module Actions
    class GoogleApiKeyAddAllowedBundleIdsAction < Action
      def self.run(params)
        manager = Firebase::Manager.new
        # Login
        api = manager.login(params[:username], params[:password])

        key_info = api.get_apikey(params[:project_number], params[:api_key_id])
        case params[:type]
        when 'ios'
          key_info['iosKeyDetails']['allowedBundleIds'] << params[:bundle_id]
          api.update_apikey(params[:project_number], params[:api_key_id], 'apiTargetKeyDetails,iosKeyDetails', key_info)
        when 'android'
          key_info['androidKeyDetails']['allowedApplications'] << {
            packageName: params[:bundle_id],
            sha1Fingerprint: Base64.strict_encode64([params[:fingerprint].gsub(':','')].pack('H*'))
          }
          api.update_apikey(params[:project_number], params[:api_key_id], 'apiTargetKeyDetails,androidKeyDetails', key_info)
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
                                  optional: false),
           FastlaneCore::ConfigItem.new(key: :bundle_id,
                               description: "ios bundle id",
                                  optional: false),
           FastlaneCore::ConfigItem.new(key: :fingerprint,
                               description: "Android SHA-1 fingerprint",
                                  optional: true)
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
