require './lib/app_earnings'

RSpec.configure do |config|
  config.mock_with :rspec
  config.color = true
  config.tty = true

  config.formatter = :documentation # :progress, :html, :textmate
  config.before do
    allow_any_instance_of(AppEarnings::Amazon::Reporter).to receive(:puts)
    allow_any_instance_of(AppEarnings::GooglePlay::Reporter).to receive(:puts)
  end
end

def file(name)
  File.expand_path(File.dirname(__FILE__) + '/fixtures/' + name)
end