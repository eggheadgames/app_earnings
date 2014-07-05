require 'spec_helper'
require 'yaml'

describe AppEarnings::Apple::Reporter do
  let(:payments_data) { AppEarnings::Apple::Parser.new(file("apple_fx.txt")).extract }
  let(:earnings_data) { AppEarnings::Apple::Parser.new(file("apple_earnings.txt")).extract }
  let(:config) { YAML.load(File.read(file("apple_config.yml"))) }
  let(:reporter) { AppEarnings::Apple::Reporter.new(config, [payments_data, earnings_data]) }

  it "should return an array of report objects" do
    data = reporter.report_as('text')
    expect(data).to be_a(Array)
    expect(data.first).to be_a(AppEarnings::Apple::AppleReport)
  end

  it "should fail when trying to use an unsupported format" do
    expect { reporter.report_as('unknown') }.to raise_error
  end

  it "should return total amount" do
    reporter.generate
    expect(reporter.full_amount).to eql(1.38)
  end
end