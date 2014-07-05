require 'csv'

module AppEarnings::Apple
  # Converts a csv file to a hash.
  class Parser
    attr_accessor :file_name
    FX_HEADER = %W(Currency
                   Beginning\ Balance
                   Earned
                   Pre-Tax\ Subtotal
                   Withholding\ Tax
                   Input\ Tax
                   Adjustments
                   Post-Tax\ Subtotal
                   FX\ Rate
                   Payment
                   Payment\ Currency)

    def initialize(file_name)
      @file_name = file_name
      @contents = File.read(@file_name).delete(',')

      if @contents =~ /Total_Rows/
        @report_type = :earnings
        @amount = fetch_total(:amount)
      else
        @report_type = :payments
        @contents.insert(0, FX_HEADER.join(',') + "\n")
      end
      cleanup
    end

    def extract
      {
        report_type: @report_type,
        details: parse(@contents.strip),
        amount: @amount
      }
    end

    private

    def cleanup
      @contents.gsub!(/\t/, ',')
      %w(amount rows units).each do |unit|
        @contents.gsub!(/^Total_#{unit.capitalize}.+$/, '')
      end
    end

    def fetch_total(from)
      expression = /Total_#{from.capitalize}.+(?<matcher>\d+)/
      @contents.match(expression)[:matcher].to_f
    end

    def parse(content)
      return nil if content.nil?
      extracted_data = []
      options = { headers: true, header_converters: :symbol }

      CSV.parse(content, options) do |row|
        extracted_data << row.to_hash
      end
      extracted_data
    end
  end
end
