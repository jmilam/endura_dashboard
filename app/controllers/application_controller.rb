class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def api_url
    "http://webapi.enduraproducts.com/api/endura"
  end
end
