require 'spec_helper'

describe AppEarnings::Amazon::Parser do
  context "Validation" do
    it "should fail when an invalid csv is provided" do
      expect { AppEarnings::Amazon::Parser.new("non_existant.csv").extract }.to raise_error(Errno::ENOENT)
    end
  end

  context "Extracted data" do
    let(:extracted_data_earnings) { AppEarnings::Amazon::Parser.new(file("amazon_earnings.csv")).extract }
    let(:extracted_data_payments) { AppEarnings::Amazon::Parser.new(file("amazon_payments.csv")).extract }

    it "should retrieve data from the provided csv and find out the type" do
      expect(extracted_data_earnings[:report_type]).to eql(:earnings)
      expect(extracted_data_earnings).to_not be_empty
    end

    it "should retrieve data from the provided csv and find out the type" do
      expect(extracted_data_payments[:report_type]).to eql(:payments)
      expect(extracted_data_payments).to_not be_empty
    end
  end
end
