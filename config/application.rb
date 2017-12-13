require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module EnduraDashboard
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.action_mailer.smtp_settings = {
		  	:address        => 'ncmail1.enduraproducts.com',
		    :port           => '25',
		    :authentication => :login,
		    :user_name      => 'jmilam',
		    :password       => 'jm1010',
		    :domain         => 'enduraproducts.com',
		    :enable_starttls_auto => true
		}
  end
end
