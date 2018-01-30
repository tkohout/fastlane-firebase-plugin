module Fastlane
  module Firebase
  	

		class Manager
			def server_name
        "firebase.google.com"
      end

			def login(username, password = nil)
				item = Security::InternetPassword.find(server: server_name(), account: username)
        keychain_password = item.password if item

        password = password || keychain_password
        begin 
          password = UI.password("Password for #{username}") unless password
          
          #Api instance
          @api = Firebase::Api.new(username, password)
          
          #Store password
          Security::InternetPassword.add(server_name(), username, password) unless keychain_password == password

          @api
        rescue Firebase::Api::LoginError => e
          UI.error e.message

          if UI.confirm "Do you want to re-enter your password?" then
        	  password = nil
            if keychain_password then
              puts "Removing Keychain entry for user '#{username}'...".yellow
              Security::InternetPassword.delete(server: server_name(), account: username)
            end
            keychain_password = nil
            retry
          end
        end
			end

			def select_project(project_number)
				projects = @api.project_list()
        if projects.count == 0 then
          UI.user_error! "No projects exist under the account"
          return
        end

				if project = projects.select {|p| p["projectNumber"] == project_number }.first then
					project
				else 
        	options = projects.map { |p| p["displayName"] }
        	index = select_index("Select project:", options)
        	projects[index]
        end
      end

      def select_client(project, client_id)
        if project["clientSummary"] == nil then
          UI.user_error! "Project has no clients"
          return
        end

        clients = (project["clientSummary"] || []).sort {|left, right| left["clientId"] <=> right["clientId"] }

      	if client = clients.select {|c| c["clientId"] == client_id }.first then
      		client
      	else
      		options = clients.map { |p| "#{p["clientId"]} (#{p["displayName"]})" }
      		index = select_index("Select client:", options)
      		clients[index]
	      end
      end

      def select_index(text, options)
				selected = UI.select(text, options)
				return options.index(selected)
			end 
		end
	end
end 
