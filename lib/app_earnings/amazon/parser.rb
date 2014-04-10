require 'csv'

module AppEarnings::Amazon
  # Converts a csv file to a hash.
  class Parser
    attr_accessor :file_name

    def initialize(file_name)
      @file_name = file_name
      @contents = File.read(@file_name)
      @header, @summary, @details = @contents.split(/Summary|Detail/)

      if @header =~ /Payment Report/
        @report_type = :payments
      else
        @report_type = :earnings
      end
    end

    def extract
      {
        report_type: @report_type,
        header: @header,
        summary: parse(@summary.strip),
        details: parse((@details || '').strip)
      }
    end

    private

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
