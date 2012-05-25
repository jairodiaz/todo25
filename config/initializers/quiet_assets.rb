# Please enable this if you don't want to see 'Served asset...' in your 'rails s' output
# Added by gato_omega (Miguel Diaz) as a convenience for developers..feel free to .gitignore it.
# http://stackoverflow.com/questions/6312448/how-to-disable-logging-of-asset-pipeline-sprockets-messages-in-rails-3-1
# Original code by choonkeat
# Modified original code to work on rails ~> 3.2 as of here:
# http://rorguide.blogspot.com/2012/01/getting-error-undefined-method.html

enable_quiet_assets=true

if enable_quiet_assets
  Rails.application.assets.logger = Logger.new('/dev/null')
  Rails::Rack::Logger.class_eval do

    def call_with_quiet_assets(env)
      previous_level = Rails.logger.level
      Rails.logger.level = Logger::ERROR if env['PATH_INFO'].index("/assets/") == 0
      call_without_quiet_assets(env).tap do
        Rails.logger.level = previous_level
      end
    end
    alias_method_chain :call, :quiet_assets
  end
end

