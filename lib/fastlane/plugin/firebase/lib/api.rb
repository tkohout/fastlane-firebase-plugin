module Fastlane
  module Firebase
  	
		class Api 
			class LoginError < StandardError 
			end

			class BadRequestError < StandardError
			end

			require 'mechanize'
			require 'digest/sha1'
			require 'json'
			require 'cgi'
			require 'pry'

			def initialize(email, password)
				@agent = Mechanize.new
				@base_url = "https://console.firebase.google.com"
				@sdk_url = "https://mobilesdk-pa.clients6.google.com/"
				@login_url = "https://accounts.google.com/ServiceLogin"

				login(email, password)
			end

			def login(email, password)
				UI.message "Logging in to Google account #{email}"

				page = @agent.get("#{@login_url}?passive=1209600&osid=1&continue=#{@base_url}/&followup=#{@base_url}/")
				
				#First step - email
				google_form = page.form()
				google_form.Email = email

				#Send
				page = @agent.submit(google_form, google_form.buttons.first)
				
				#Second step - password
				google_form = page.form()
				google_form.Passwd = password

				#Send
				page = @agent.submit(google_form, google_form.buttons.first)
				match = page.search("script").text.scan(/\\x22api-key\\x22:\\x22(.*?)\\x22/)
				
				if match.count == 1 then
					@api_key = match[0][0]
					@authorization_headers = create_authorization_headers()
					UI.success "Successfuly logged in"
					true
				else
					if error = page.at("#errormsg_0_Passwd") then
						message = error.text.strip
					else
						message = "Unknown error"
					end
					raise LoginError, "Login failed: #{message}"
				end 
			end

			def generate_sapisid_hash(time, sapisid, origin) 
				to_hash = time.to_s + " " + sapisid + " " + origin.to_s
				
				hash = Digest::SHA1.hexdigest(to_hash)
				sapisid_hash = time.to_s + "_" + hash

				sapisid_hash
			end

			def create_authorization_headers 
				cookie = @agent.cookie_jar.jar["google.com"]["/"]["SAPISID"]
				sapisid = cookie.value
				origin = @base_url
				time = Time.now.to_i

				sapisid_hash = generate_sapisid_hash(time, sapisid, origin)

				cookies = @agent.cookie_jar.jar["google.com"]["/"].merge(@agent.cookie_jar.jar["console.firebase.google.com"]["/"])
				cookie_header = cookies.map { |el, cookie| "#{el}=#{cookie.value}" }.join(";")

				sapisid_hash = generate_sapisid_hash(time, sapisid, origin)
				sapisid_header = "SAPISIDHASH #{sapisid_hash}"

				json_headers = {
					'Authorization' => sapisid_header,
					'Cookie' => cookie_header,
					'X-Origin' => origin
				}

				json_headers
			end

			def request_json(path, method = :get, parameters = Hash.new, headers = Hash.new)
					begin
					if method == :get then
						parameters["key"] = @api_key
						page = @agent.get("#{@sdk_url}#{path}", parameters, nil, headers.merge(@authorization_headers))
					elsif method == :post then
						headers['Content-Type'] = 'application/json'
						page = @agent.post("#{@sdk_url}#{path}?key=#{@api_key}", parameters.to_json, headers.merge(@authorization_headers))
					end

					JSON.parse(page.body)

					rescue Mechanize::ResponseCodeError => e
						if e.response_code == "400" then
							if body = JSON.parse(e.page.body) then
								raise BadRequestError, body["error"]["message"]
							end
						end
						raise
					end
			end

			def project_list
				UI.message "Retrieving project list"
				json = request_json("v1/projects")
				projects = json["project"]
				UI.success "Found #{projects.count} projects"
				projects
			end

			def add_client( project_number, bundle_id, app_name, ios_appstore_id )
				parameters = {
					"requestHeader" => { "clientVersion" => "FIREBASE" },
					"iosData" => {
							"bundleId" => bundle_id,
							"iosAppStoreId" => ios_appstore_id || ""
					},
					"displayName" => app_name || ""
				}

				json = request_json("v1/projects/#{project_number}/clients", :post, parameters)
				if client = json["client"] then
					UI.success "Successfuly added client #{bundle_id}"
					client
				else
					UI.error "Client could not be added"
				end
			end

			def upload_certificate(project_number, client_id, type, certificate_value, certificate_password)
				
				prefix = type == :development ? "debug" : "prod"

				parameters = {
					"#{prefix}ApnsCertificate" => { 
						"certificateValue" => certificate_value,
						"apnsPassword" => certificate_password 
					}
				}

				json = request_json("v1/projects/#{project_number}/clients/#{client_id}:setApnsCertificate", :post, parameters)
			end

			def client_info_plist(project_number, client_id)
				request = "[\"getArtifactRequest\",null,\"#{client_id}\",\"1\",\"#{project_number}\"]"
				url = @base_url + "/m/mobilesdk/projects/" + project_number + "/clients/" + CGI.escape(client_id) + "/artifacts/1?param=" + CGI.escape(request)
				UI.message "Downloading GoogleInfo.plist file"
				plist = @agent.get url
				UI.success "Successfuly downloaded GoogleInfo.plist file"
				plist
			end
		end
	end
end