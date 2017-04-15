module Fastlane
  module Firebase
  	
		class Manager
			def server_name
        "firebase.google.com"
      end



			def login(username)
				item = Security::InternetPassword.find(server: server_name(), account: username)
        password = item.password if item

        begin 
          password = UI.input("Password for #{username}") unless password
          
          #Api instance
          @api = Firebase::Api.new(username, password)
          
          #Store password
          Security::InternetPassword.add(server_name(), username, password) unless item.password == password

          @api
        rescue Firebase::Api::LoginError => e
          password = nil
          UI.error e.message
          retry
        end
			end

			def select_project(project_number)
				projects = @api.project_list()
				if project = projects.select {|p| p["projectNumber"] == project_number }.first then
					project
				else 
        	options = projects.map { |p| p["displayName"] }
        	index = select_index("Select project:", options)
        	projects[index]
        end
      end

      def select_client(project, client_id)
      	clients = project["clientSummary"]
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
