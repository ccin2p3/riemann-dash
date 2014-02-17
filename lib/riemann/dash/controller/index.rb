class Riemann::Dash::App
	if config[:auth] && config[:auth][:method] == "cas"
		puts "Using CAS authentication with URI " + config[:auth][:cas][:cas_base_url]
		use Rack::Session::Cookie, :secret => config[:auth][:cookie_secret] || 'changemenot'
		helpers CasHelpers
		before do
			 set_cas_client(config[:auth][:cas])
		   process_cas_login(request, session)
		end
	end
  get '/' do
		if config[:auth] && config[:auth][:method] == "cas"
		   require_authorization(request, session) unless logged_in?(request, session)
		end
    erb :index, :layout => false
  end

  get '/config', :provides => 'json' do
    content_type "application/json"
		a = nil
		b = nil
		if config[:auth] && config[:auth][:method] == "cas"
		   require_authorization(request, session) unless logged_in?(request, session)
			 if config[:auth][:config_file_replacee]
          a = config[:auth][:config_file_replacee]
          b = session[config[:auth][:config_file_replacer]]
			 end
		end
		config.read_ws_config(a,b)
  end

  post '/config' do
		a = nil
		b = nil
		if config[:auth] && config[:auth][:method] == "cas"
		   require_authorization(request, session) unless logged_in?(request, session)
			 if config[:auth][:config_file_replacee]
          a = config[:auth][:config_file_replacee]
          b = session[config[:auth][:config_file_replacer]]
			 end
		end
    # Read update
    request.body.rewind
    config.update_ws_config(request.body.read, a, b)

    # Return current config
    content_type "application/json"
    config.read_ws_config(a,b)
  end
end
