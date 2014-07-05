require 'app_earnings/cli'
require 'app_earnings/report'
require 'app_earnings/amazon'
require 'app_earnings/google_play'
require 'app_earnings/apple'
require 'yaml'

# Process Monthly Earnings report
# From GoogleApps or Amazon
# transaction CSV file into a report by Application and IAP
module AppEarnings
  def self.play_report(name, format = 'text')
    parsed = GooglePlay::Parser.new(name).extract
    GooglePlay::Reporter.new(parsed).report_as(format)
  end

  def self.amazon_report(payments, earnings, format = 'text')
    parsed = []
    parsed << Amazon::Parser.new(payments).extract
    parsed << Amazon::Parser.new(earnings).extract
    Amazon::Reporter.new(parsed).report_as(format)
  end

  def self.apple_report(path, format = 'text')
    apple_reports = File.join(path, '*.txt')
    parsed = []
    Dir.glob(apple_reports).each do |file|
      parsed << Apple::Parser.new(file).extract
    end

    config = YAML.load(File.read(File.join(path, 'config.yml')))
    Apple::Reporter.new(config, parsed).report_as(format)
  end
end
