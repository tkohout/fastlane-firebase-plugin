module Fastlane
  module Actions
    class UploadCertificateAction < Action
      require 'security'
      
      def self.server_name
        "firebase.google.com"
      end

      def self.run(params)
        manager = Firebase::Manager.new
        
        # Login
        api = manager.login(params[:username])

        p12_path = params[:p12_path]

        #Select project
        project = manager.select_project(params[:project_number])
        project_number = project["projectNumber"]

        #Select client
        client = manager.select_client(project, params[:client_id])
        client_id = client["clientId"]

        #Select certificate type
        type = UI.select("Select type:", [:development, :production])

        #Base64 certificate
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
            return
          end
          UI.crash! e.message
        end

        UI.success "Successfully uploaded certificate"
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
                                  optional: true),
          FastlaneCore::ConfigItem.new(key: :project_number,
                                  env_name: "FIREBASE_PROJECT_NUMBER",
                               description: "Project number",
                                  optional: true),
          FastlaneCore::ConfigItem.new(key: :client_id,
                                  env_name: "FIREBASE_CLIENT_ID",
                               description: "Project client id",
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
