require 'spec_helper'

describe AppEarnings::Apple::Parser do
  context "Validation" do
    it "should fail when an invalid csv is provided" do
      expect { AppEarnings::Apple::Parser.new("non_existant.csv").extract }.to raise_error(Errno::ENOENT)
    end
  end

  context "Extracted data" do
    let(:apple_fx) { AppEarnings::Apple::Parser.new(file("apple_fx.txt")) }
    let(:apple_earnings) { AppEarnings::Apple::Parser.new(file("apple_earnings.txt")) }
    let(:extracted_data_earnings) { apple_earnings.extract }
    let(:extracted_data_payments) { apple_fx.extract }

    it "should retrieve data from the provided csv and find out the type" do
      expect(extracted_data_earnings[:report_type]).to eql(:earnings)
      expect(extracted_data_earnings).to_not be_empty
    end

    it "should retrieve data from the provided csv and find out the type" do
      expect(extracted_data_payments[:report_type]).to eql(:payments)
      expect(extracted_data_payments).to_not be_empty
    end

    it "should prepare the payments file for parsing" do
      expect(apple_fx.contents).to include(AppEarnings::Apple::Parser::FX_HEADER.first)
    end

    it "should prepare the earnings file for parsing" do
      expect(apple_earnings.contents).to_not include("Total_")
    end
  end
end
