module Fastlane
  module Actions
    class FirebaseDownloadConfigAction < Action
      
      def self.run(params)
        manager = Firebase::Manager.new
        
        # Login
        api = manager.login(params[:username])

        #Select project
        project = manager.select_project(params[:project_number])
        project_number = project["projectNumber"]

        #Select client
        client = manager.select_client(project, params[:client_id])
        client_id = client["clientId"]

        #Download
        config = api.download_config_file(project_number, client_id)
        path = File.join(params[:output_path], params[:output_name] || config.filename)
        config.save(path)

        UI.success "Successfuly saved config at #{path}"
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
          FastlaneCore::ConfigItem.new(key: :client_id,
                                  env_name: "FIREBASE_CLIENT_ID",
                               description: "Project client id",
                                  optional: true),
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
