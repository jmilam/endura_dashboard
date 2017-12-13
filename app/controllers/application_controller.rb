class ApplicationController < ActionController::Base
  #protect_from_forgery with: :exception
  protect_from_forgery with: :null_session
  require 'net/http'

  def api_url
    "http://webapi.enduraproducts.com/api/endura"
  end
end
