module Fastlane
  module Actions
    class UploadCertificateAction < Action
      require 'security'
      require 'pry'
      require 'openssl'

      def self.server_name
        "firebase.google.com"
      end

      def self.run(params)
        username = params[:username]
        p12_path = params[:p12_path]

        item = Security::InternetPassword.find(server: server_name(), account: username)
        password = item.password if item

        begin 
          if !password then
            password = UI.input("Password for #{username}")
          end

          api = Firebase::Api.new(username, password)

          projects = api.project_list()
          options = projects.map { |p| p["displayName"] }
          project_name = UI.select("Select project", options)
          project = projects.select { |p| p["displayName"] == project_name }.first
          project_number = project["projectNumber"]

          clients = project["clientSummary"]
          options = clients.map { |p| p["displayName"] }
          client_name = UI.select("Select project", options)
          client = clients.select { |p| p["displayName"] == client_name }.first
          client_id = client["clientId"]

          type = UI.select("Select type:", [:development, :production])

          Security::InternetPassword.add(server_name(), username, password) unless item.password == password
          certificate_value = Base64.encode64(File.open(p12_path, "rb").read).delete!("\n")

          UI.message "Uploading certificate ..."
          cert_password = params[:p12_password]

          begin 
            api.upload_certificate(project_number, client_id, type, certificate_value, cert_password)
          rescue Firebase::Api::BadRequestError => e
            if e.message.start_with? "3000" then
              UI.error e.message
              cert_password = UI.password("Password for certificate")
              retry
            elsif e.message.start_with? "3003" then
              UI.user_error! "The Bundle ID in the certificate does not match the Bundle ID you entered."
            end
            UI.crash! e.message
          end


          UI.success "Successfully uploaded certificate"

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
                                  optional: false),
          FastlaneCore::ConfigItem.new(key: :p12_path,
                                  env_name: "FIREBASE_P12PATH",
                               description: "Path to certificate",
                                  optional: false),
          FastlaneCore::ConfigItem.new(key: :p12_password,
                                  env_name: "FIREBASE_PASSWORD",
                               description: "Password to the certicate",
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
