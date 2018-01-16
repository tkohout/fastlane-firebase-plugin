module Fastlane
  module Actions
    class FirebaseAddTeamAction < Action
      
      def self.run(params)
        manager = Firebase::Manager.new
        #Login
        api = manager.login(params[:username])

        #Select project
        project = manager.select_project(params[:project_number])

        # Client input
        type = params[:type].to_sym

        bundle_id = params[:bundle_id]
        name = params[:name]
        appstore_id = params[:appstore_id]
        team_id = params[:team_id]

        # Add  team
        client = api.add_team(project["projectNumber"], bundle_id, team_id)

        UI.success "Successfuly added team_id of app #{bundle_id}"
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
          FastlaneCore::ConfigItem.new(key: :project_number,
                                  env_name: "FIREBASE_PROJECT_NUMBER",
                               description: "Project number",
                                  optional: true),
          FastlaneCore::ConfigItem.new(key: :download_config,
                                  env_name: "FIREBASE_DOWNLOAD_CONFIG",
                               description: "Should download config for created client",
                                  optional: false,
                                  is_string: false,
                                  default_value: true),
          FastlaneCore::ConfigItem.new(key: :type,
                                  env_name: "FIREBASE_TYPE",
                                  description: "Type of client (ios, android)",
                                  verify_block: proc do |value|
                                    types = [:ios, :android]
                                    UI.user_error!("Type must be in #{types}") unless types.include?(value.to_sym)
                                  end
                               ),
          FastlaneCore::ConfigItem.new(key: :bundle_id,
                                  env_name: "FIREBASE_BUNDLE_ID",
                               description: "Bundle ID (package name)",
                                  optional: false),
          FastlaneCore::ConfigItem.new(key: :name,
                                  env_name: "FIREBASE_BUNDLE_ID",
                               description: "Display name",
                                  optional: true),
          FastlaneCore::ConfigItem.new(key: :appstore_id,
                                  env_name: "FIREBASE_APPSTORE_ID",
                               description: "AppStore ID",
                                  optional: true),
          FastlaneCore::ConfigItem.new(key: :output_path,
                                  env_name: "FIREBASE_OUTPUT_PATH",
                               description: "Path for the downloaded config",
                                  optional: false,
                                  default_value: "./"),
          FastlaneCore::ConfigItem.new(key: :output_name,
                                  env_name: "FIREBASE_OUTPUT_NAME",
                               description: "Name of the downloaded file",
                                  optional: true),
          FastlaneCore::ConfigItem.new(key: :team_id,
                                  env_name: "FIREBASE_TEAM_ID",
                               description: "ID of the Apple Team",
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
