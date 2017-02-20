class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def api_url
    "http://webapi.enduraproducts.com/api/endura"
  end

  def set_salesforce_token(request_obj)
		session[:token] = request_obj.activateToken
	end
end
