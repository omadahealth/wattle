# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'rr'
require 'sidekiq/testing'
require 'sidekiq/testing/inline'
require 'email_spec'
require 'capybara/rspec'
require 'capybara/rails'
require 'capybara/poltergeist'


load Rails.root.join("db", "seeds.rb")

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)
require "email_spec"

Capybara.javascript_driver = :poltergeist

RSpec.configure do |rspec|
  rspec.deprecation_stream = 'log/deprecations.log'
end

def capture_error &block
  err = nil
  begin
    yield block
  rescue
    err = $!
  end
  return err
end

require 'support/fixture_builder'
Sidekiq::Testing.fake!

RSpec.configure do |config|

  config.before(:each) do |example|
    reset_mailer

    # Clears out the jobs for tests using the fake testing
    Sidekiq::Worker.clear_all
    # Get the current example from the example_method object

    if example.metadata[:sidekiq] == :fake
      Sidekiq::Testing.fake!
    elsif example.metadata[:sidekiq] == :inline
      Sidekiq::Testing.inline!
    elsif example.metadata[:type] == :acceptance
      Sidekiq::Testing.inline!
    else
      Sidekiq::Testing.fake!
    end
  end

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  #config.before(:suite) do
  #  DatabaseCleaner.strategy = :transaction
  #end
  #
  #config.before(:each) do
  #  DatabaseCleaner.start
  #end
  #
  #config.after(:each) do
  #  DatabaseCleaner.clean
  #end

  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"


  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false
  config.global_fixtures = :all

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234



  config.order = "random"
  config.include SessionSpecHelper, type: :controller

  config.include(EmailSpec::Helpers)
  config.include(EmailSpec::Matchers)
end
