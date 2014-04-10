require './lib/app_earnings'

RSpec.configure do |config|
  config.mock_with :rspec
  config.color_enabled = true
  config.tty = true

  config.formatter = :documentation # :progress, :html, :textmate
  config.before do
    AppEarnings::Amazon::Reporter.any_instance.stub(:puts)
    AppEarnings::GooglePlay::Reporter.any_instance.stub(:puts)
  end
end

def file(name)
  File.expand_path(File.dirname(__FILE__) + '/fixtures/' + name)
end