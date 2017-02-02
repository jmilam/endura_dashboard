class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  def api_url
    "http://localhost:3000/api/endura"
  end
end
