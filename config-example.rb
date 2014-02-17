set :port, 4567      # HTTP server on port 6000
set :bind, "127.0.0.1" # Bind to a different interface
config[:ws_config] = "config/config-%{user}.json"
config[:auth] = { 
	:cookie_secret => "changeme",
	:method => "cas",
	:cas => {
		:cas_base_url => "https://path/to/cas/",
		:encode_extra_attributes_as => :raw,
	},
	:config_file_replacee => "%{user}",
	:config_file_replacer => "cas_user",
}

