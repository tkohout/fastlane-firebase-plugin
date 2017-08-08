module Fastlane
  module Firebase
  	class Api 
			class LoginError < StandardError 
			end

			class BadRequestError < StandardError
				attr_reader :code
 				def initialize(msg, code)
			    @code = code
			    super(msg)
			  end
			end

			require 'mechanize'
			require 'digest/sha1'
			require 'json'
			require 'cgi'
		
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
				
				while page do
					if extract_api_key(page) then
						UI.success "Successfuly logged in"
						return true
					else

						if error = page.at("#errormsg_0_Passwd") then
							message = error.text.strip
						elsif page.xpath("//div[@class='captcha-img']").count > 0 then
							page = captcha_challenge(page)
							next
						elsif page.form.action.include? "/signin/challenge" then
							page = signin_challenge(page)
							next
						else 
							message = "Unknown error"
						end
						raise LoginError, "Login failed: #{message}"
					end 

					end
			end

			def extract_api_key(page) 
				#Find api key in javascript
				match = page.search("script").text.scan(/\\x22api-key\\x22:\\x22(.*?)\\x22/)
				if match.count == 1 then
					@api_key = match[0][0]
					@authorization_headers = create_authorization_headers()
					return true
				end

				return false
			end

			def captcha_challenge(page)
				if UI.confirm "To proceed you need to fill in captcha. Do you want to download captcha image?" then
					img_src = page.xpath("//div[@class='captcha-img']/img").attribute("src").value
					image = @agent.get(img_src)
					if image != nil then
						UI.success "Captcha image downloaded"
					else 
						UI.crash! "Failed to download captcha image"
					end

					file = Tempfile.new(["firebase_captcha_image", ".jpg"])
					path = file.path 
					
					image.save!(path)

					UI.success "Captcha image saved at #{path}"

					if UI.confirm "Preview image?" then 
						if system("qlmanage -p #{path} >& /dev/null &") != true && system("open #{path} 2> /dev/null") != true then
							UI.error("Unable to find program to preview the image, open it manually")
						end
					end

					captcha = UI.input "Enter captcha (case insensitive):"
					password = UI.password "Re-enter password:"

					captcha_form = page.form()

					captcha_form.logincaptcha = captcha
					captcha_form.Passwd = password

					page = @agent.submit(captcha_form, captcha_form.buttons.first)
					return page
				else 
					return nil
				end
				
			end
			
			def signin_challenge(page)
				UI.header "Sign-in challenge"

				form_id = "challenge"
				form = page.form_with(:id => form_id)
				type = (form["challengeType"] || "-1").to_i

				# Two factor verification SMS
				if type == 9 || type == 6 then
					div = page.at("##{form_id} div")
					if div != nil then 
						UI.important div.xpath("div[1]").text
						UI.important div.xpath("div[2]").text
					end
					
					prefix = type == 9 ? " G-" : ""
					code = UI.input "Enter code#{prefix}:"
					form.Pin = code
					page = @agent.submit(form, form.buttons.first)
					return page
				elsif type == 4 then 
					UI.user_error! "Google prompt is not supported as a two-step verification"
				else
					html = page.at("##{form_id}").to_html
					UI.user_error! "Unknown challenge type \n\n#{html}"
				end

				return nil
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
					elsif method == :delete then
						page = @agent.delete("#{@sdk_url}#{path}?key=#{@api_key}", parameters, headers.merge(@authorization_headers))
					end

					JSON.parse(page.body)

					rescue Mechanize::ResponseCodeError => e
						code = e.response_code.to_i
						if code >= 400 && code < 500 then
							if body = JSON.parse(e.page.body) then
								raise BadRequestError.new(body["error"]["message"], code)
							end
						end
						UI.crash! e.page.body
					end
			end

			def project_list
				UI.message "Retrieving project list"
				json = request_json("v1/projects")
				projects = json["project"] || []
				UI.success "Found #{projects.count} projects"
				projects
			end

			def add_client(project_number, type, bundle_id, app_name, ios_appstore_id )
				parameters = {
					"requestHeader" => { "clientVersion" => "FIREBASE" },
					"displayName" => app_name || ""
				}

				case type
					when :ios
						parameters["iosData"] = {
							"bundleId" => bundle_id,
							"iosAppStoreId" => ios_appstore_id || ""
						}
					when :android
						parameters["androidData"] = {
							"packageName" => bundle_id
						}
				end

				json = request_json("v1/projects/#{project_number}/clients", :post, parameters)
				if client = json["client"] then
					UI.success "Successfuly added client #{bundle_id}"
					client
				else
					UI.error "Client could not be added"
				end
			end

			def delete_client(project_number, client_id)
				json = request_json("v1/projects/#{project_number}/clients/#{client_id}", :delete)
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

			def download_config_file(project_number, client_id)
				
				request = "[\"getArtifactRequest\",null,\"#{client_id}\",\"1\",\"#{project_number}\"]"
				code = (client_id.start_with? "ios") ? "1" : "2"
				url = @base_url + "/m/mobilesdk/projects/" + project_number + "/clients/" + CGI.escape(client_id) + "/artifacts/#{code}?param=" + CGI.escape(request)
				UI.message "Downloading config file"
				begin
					config = @agent.get url
					UI.success "Successfuly downloaded #{config.filename}"
					config
				rescue Mechanize::ResponseCodeError => e
					UI.crash! e.page.body
				end
			end
		end
	end
end