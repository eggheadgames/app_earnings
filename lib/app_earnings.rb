require 'app_earnings/cli'
require 'app_earnings/report'
require 'app_earnings/amazon'
require 'app_earnings/google_play'

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
end
