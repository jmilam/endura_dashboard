class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  def api_url
    case Rails.env
    when "development"
      "http://qadprod.endura.enduraproducts.com/cgi-bin/prodapi/"
    when "production"
      "http://qadprod.endura.enduraproducts.com/cgi-bin/prodapi/"
    when "test"
      "http://qadprod.endura.enduraproducts.com/cgi-bin/prodapi/"
    end
  end
end
