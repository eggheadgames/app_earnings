require 'spec_helper'

describe AppEarnings::GooglePlay::Parser do
  context "Validation" do
    it "should fail when an invalid csv is provided" do
      expect { AppEarnings::GooglePlay::Parser.new("non_existant.csv").extract }.to raise_error(Errno::ENOENT)
    end
  end

  context "Extracted data" do
    let(:extracted_data) { AppEarnings::GooglePlay::Parser.new(file("play_transactions.csv")).extract }

    it "should retrieve data from the provided csv" do
      expect(extracted_data).to_not be_empty
    end
  end
end