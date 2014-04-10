require 'csv'

module AppEarnings::GooglePlay
  # Converts a csv file to a hash.
  class Parser
    attr_accessor :file_name

    def initialize(file_name)
      @file_name = file_name
    end

    def extract
      @extracted_data = []
      options = { headers: true, header_converters: :symbol }

      CSV.foreach(@file_name, options) do |row|
        @extracted_data << row.to_hash
      end
      @extracted_data
    end
  end
end
