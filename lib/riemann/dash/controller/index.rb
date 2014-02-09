class Riemann::Dash::App
	use Rack::Session::Cookie, :secret => 'changemenot'
	helpers CasHelpers
	before do
	   process_cas_login(request, session)
	end
  get '/' do
		require_authorization(request, session) unless logged_in?(request, session)
    erb :index, :layout => false
  end

  get '/config', :provides => 'json' do
		require_authorization(request, session) unless logged_in?(request, session)
    content_type "application/json"
    config.read_ws_config ({:username => session[:cas_user]})
  end

  post '/config' do
		require_authorization(request, session) unless logged_in?(request, session)
    # Read update
    request.body.rewind
    config.update_ws_config(request.body.read)

    # Return current config
    content_type "application/json"
    config.read_ws_config
  end
end
