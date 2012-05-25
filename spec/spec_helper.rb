require 'rubygems'
require 'spork'
require 'cover_me'

#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

# Add I18n helper method anywhere
def t(*args)
  I18n.t(*args)
end

Spork.prefork do
  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/autorun'
  require 'rspec/rails'
  require 'capybara/rspec'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  # Capybara
  Capybara.default_host = "http://127.0.0.1"
  Capybara.javascript_driver = :webkit

  RSpec.configure do |config|
    # ## Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    config.mock_with :rspec

    # Factory girl
    config.include FactoryGirl::Syntax::Methods

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = false # IMPORTANT when using Capybara js driver assign false

    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.filter_run :focus => true
    config.run_all_when_everything_filtered = true

    config.before(:suite) do
      DatabaseCleaner.strategy = :truncation
      DatabaseCleaner.start
      DatabaseCleaner.clean
    end

    # Clean db in before hook, best if stopped examples at the middle of execution
    config.before(:each, :clean_db => true) do |example|
      DatabaseCleaner.start
      DatabaseCleaner.clean
    end

    config.before(:each, :clean_mail => true) do |example|
      # Clear deliveries so that indexes match for isolated examples
      ActionMailer::Base.deliveries.clear
    end

    config.after(:suite) do
    end

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    #config.fixture_path = "#{::Rails.root}/spec/fixtures"

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false
  end

end

Spork.each_run do
  # Please reload routes
  load "#{Rails.root}/config/routes.rb"
end
