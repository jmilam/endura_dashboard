class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  def api_url
    case Rails.env
    when "development"
      "http://qadnix.endura.enduraproducts.com/cgi-bin/devapi/"  
      #"http://qadprod.endura.enduraproducts.com/cgi-bin/prodapi/"
    when "production"
      "http://qadprod.endura.enduraproducts.com/cgi-bin/prodapi/"
    when "test"
      "http://qadnix.endura.enduraproducts.com/cgi-bin/testapi/"
    end
  end
end
