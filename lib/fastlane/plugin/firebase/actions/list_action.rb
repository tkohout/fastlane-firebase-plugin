module Fastlane
  module Actions
    class ListAction < Action
      require 'security'
      require 'pry'


      def self.server_name
        "firebase.google.com"
      end

      def self.run(params)
        username = params[:username]

        item = Security::InternetPassword.find(server: server_name(), account: username)
        password = item.password if item

        begin 
          if !password then
            password = UI.input("Password for #{username}")
          end

          api = Firebase::Api.new(username, password)
          Security::InternetPassword.add(server_name(), username, password) unless item.password == password

          projects = api.project_list()
          projects.each_with_index { |p, i| 
            UI.message "#{i+1}. #{p["displayName"]}" 
            p["clientSummary"].each_with_index { |client, j|
              UI.message "  #{j+1}. #{client["clientId"]} (#{client["displayName"]})" 
            } 
          }
          
        rescue Firebase::Api::LoginError => e
          password = nil
          UI.error e.message
          retry
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
                                  optional: false)
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
