require 'active_support/all' #bug in rubycas client requires this
require 'rubycas-client'

module CasHelpers
	
	@@cas_client = nil

	def set_cas_client(auth_cas_param)
		@@cas_client = CASClient::Client.new(auth_cas_param)
	end
	
	def cas_client()
		return @@cas_client
	end

  def need_authentication(request, session)
    if session[:cas_ticket]
      if request[:ticket] && session[:cas_ticket] != request[:ticket]
        true
      else
        false
      end
    else
      true
    end
  end

  def process_cas_login(request, session)
    if request[:ticket] && request[:ticket] != session[:ticket]

      service_url = read_service_url(request)
      st = read_ticket(request[:ticket], service_url)

      cas_client.validate_service_ticket(st)

      if st.success
        session[:cas_ticket] = st.ticket
        session[:cas_user] = st.user
        session[:cas_extra_attributes] = st.extra_attributes
        return service_url
      else
        raise "Service Ticket validation failed! #{st.failure_code} - #{st.failure_message}"
      end
    end

  end

  def logged_in?(request, session)
    session[:cas_ticket] && !session[:cas_ticket].empty?
  end

  def require_authorization(request, session)
    if !logged_in?(request, session)
      service_url = read_service_url(request)
      url = cas_client.add_service_to_login_url(service_url)
      redirect url
    end
  end

  private
  def read_ticket(ticket_str, service_url)
    return nil unless ticket_str and !ticket_str.empty?

    if ticket_str =~ /^PT-/
      CASClient::ProxyTicket.new(ticket_str, service_url)
    else
      CASClient::ServiceTicket.new(ticket_str, service_url)
    end
  end

  def read_service_url(request)
    service_url = url(request.path_info)
    if request.GET
      params = request.GET.dup
      params.delete("ticket")
      unless params.empty?
        return [service_url, Rack::Utils.build_nested_query(params)].join('?')
      end
    end
    return service_url
  end
end

