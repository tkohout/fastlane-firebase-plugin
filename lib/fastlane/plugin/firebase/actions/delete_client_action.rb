module Fastlane
  module Actions
    class DeleteClientAction < Action
      require 'pry'


      def self.run(params)
        manager = Firebase::Manager.new
        #Login
        api = manager.login(params[:username])

        #Select project
        project = manager.select_project(params[:project_number])

        #Select project
        client = manager.select_client(project, params[:client_id])

        #Confirm
        if !params[:force] then
          UI.error "Caution, this is a permanent action. Deleting your app will delete the corresponding Analytics data, but not your app's API keys or OAuth clients."
          UI.confirm "Are you sure to delete #{client["clientId"]} (#{client["displayName"]})?"
        end

        #Delete
        api.delete_client(project["projectNumber"], client["clientId"])

        UI.success "Successfuly deleted #{client["clientId"]}"
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
                               description: "Client ID to be deleted",
                                  optional: true),
          FastlaneCore::ConfigItem.new(key: :force,
                                  env_name: "FIREBASE_FORCE",
                               description: "Force delete",
                                  default_value: false)
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
