module Fastlane
  module Actions
    class FirebaseListAction < Action
      require 'security'
      
      def self.run(params)
        manager = Firebase::Manager.new
        # Login
        api = manager.login(params[:username], params[:password])

        # List projects
        projects = api.project_list()
       
        projects.each_with_index { |p, i| 
          UI.message "#{i+1}. #{p["displayName"]} (#{p["projectNumber"]})" 
          clients = p["clientSummary"] || []
          clients.sort {|left, right| left["clientId"] <=> right["clientId"] }.each_with_index { |client, j|
            UI.message "  - #{client["clientId"]} (#{client["displayName"]})" 
          } 
        }
      end

      def self.description
        "An unofficial tool to access Firebase"
      end

      def self.authors
        ["Tomas Kohout"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "Firebase helps you list your projects, create applications, download configuration files and more..."
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
                                  env_name: "FIREBASE_PROJECT_NUMBER",
                               description: "Project number",
                                  optional: true)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Platforms.md
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
