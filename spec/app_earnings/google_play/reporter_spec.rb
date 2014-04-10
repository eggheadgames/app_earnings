require 'spec_helper'

describe AppEarnings::GooglePlay::Reporter do
  let(:extracted_data) { AppEarnings::GooglePlay::Parser.new(file("play_transactions.csv")).extract }
  let(:dummy_data) { [ { merchant_currency: "USD", amount_merchant_currency: 10.0 },
                       { merchant_currency: "USD", amount_merchant_currency: 5.0 } ] }
  let(:reporter) { AppEarnings::GooglePlay::Reporter.new(extracted_data) }

  it "should return an array of report objects" do
    data = reporter.report_as('text')
    expect(data).to be_a(Array)
    expect(data.first).to be_a(AppEarnings::GooglePlay::PlayReport)
  end

  it "should fail when trying to use an unsupported format" do
    expect { reporter.report_as('unknown') }.to raise_error
  end
end