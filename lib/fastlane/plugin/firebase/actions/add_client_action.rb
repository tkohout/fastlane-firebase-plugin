module Fastlane
  module Actions
    class AddClientAction < Action
      require 'pry'


      def self.run(params)
        manager = Firebase::Manager.new
        #Login
        api = manager.login(params[:username])

        #Select project
        project = manager.select_project(params[:project_number])

        # Client input
        bundle_id = UI.input("Client bundle id:")
        name = UI.input("Display name (optional):")
        ios_appstore_id = UI.input("AppStore ID (optional): ")

        # Add client
        client = api.add_client(project["projectNumber"], bundle_id, name, ios_appstore_id)
        
        if params[:download_config] then
          #Download config
          config = api.download_config_file(project["projectNumber"], client["clientId"])
          path = File.join(params[:output_path], params[:output_name] || config.filename)
          config.save(path)

          UI.success "Successfuly saved config at #{path}"
        end

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
                                  default_value: true),
          FastlaneCore::ConfigItem.new(key: :output_path,
                                  env_name: "FIREBASE_OUTPUT_PATH",
                               description: "Path for the downloaded config",
                                  optional: false,
                                  default_value: "./"),
          FastlaneCore::ConfigItem.new(key: :output_name,
                                  env_name: "FIREBASE_OUTPUT_NAME",
                               description: "Name of the downloaded file",
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
