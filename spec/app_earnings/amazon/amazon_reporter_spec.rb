require 'spec_helper'

describe AppEarnings::Amazon::Reporter do
  let(:payments_data) { AppEarnings::Amazon::Parser.new(file("amazon_payments.csv")).extract }
  let(:earnings_data) { AppEarnings::Amazon::Parser.new(file("amazon_earnings.csv")).extract }
  let(:dummy_data) { [ { merchant_currency: "USD", amount_merchant_currency: 10.0 },
                       { merchant_currency: "USD", amount_merchant_currency: 5.0 } ] }
  let(:reporter) { AppEarnings::Amazon::Reporter.new([payments_data, earnings_data]) }

  it "should return an array of report objects" do
    data = reporter.report_as('text')
    expect(data).to be_a(Array)
    expect(data.first).to be_a(AppEarnings::Amazon::AmazonReport)
  end

  it "should fail when trying to use an unsupported format" do
    expect { reporter.report_as('unknown') }.to raise_error
  end

  it "should sum refunds" do
    reporter.refunds.should eql(4.18)
  end

  it "should return total amount" do
    reporter.generate
    reporter.full_amount.should eql(10.3)
  end
end