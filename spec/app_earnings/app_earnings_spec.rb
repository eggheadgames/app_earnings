require 'spec_helper'

describe AppEarnings do
  it "should generate a report by application based on a provided csv file for googple play" do
    expect_any_instance_of(AppEarnings::GooglePlay::Parser).to receive(:extract)
    expect_any_instance_of(AppEarnings::GooglePlay::Reporter).to receive(:report_as).with('text')

    AppEarnings.play_report(file("play_transactions.csv"))
  end

  it "should generate a report by application based on a provided csv file for amazon" do
    expect_any_instance_of(AppEarnings::Amazon::Reporter).to receive(:report_as).with('text')
    AppEarnings.amazon_report(file("amazon_earnings.csv"), file("amazon_payments.csv"))
  end
end
