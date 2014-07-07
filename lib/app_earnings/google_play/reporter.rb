require 'yaml'
require 'json'
require 'iso4217'

module AppEarnings::GooglePlay
  # Generates a report based on the data provided
  class Reporter
    AVAILABLE_FORMATS = %w(json text csv)
    attr_accessor :raw_data

    def initialize(raw_data)
      @raw_data = raw_data
    end

    def generate
      by_apps = @raw_data.group_by { |element| element[:product_id] }
                         .sort_by { |app| app }

      @reports = []
      by_apps.each do |key, application|
        @reports << PlayReport.new(key, application)
      end
    end

    def full_amount
      total = @reports.reduce(0.0) { |a, e| a + e.amount.to_f }
      currency = @reports.first.currency
      [currency, total]
    end

    def report_as(format = 'text')
      unless AVAILABLE_FORMATS.include?(format)
        fail "#{format} Not supported. Available formats are: " +
             " #{AVAILABLE_FORMATS.join(", ")}"
      end

      generate
      render_as(format)
    end

    def render_as(format = 'text')
      case format
      when 'text'
        as_text
      when 'json'
        as_json
      when 'csv'
        as_csv
      end
    end

    def as_text
      currency, total = full_amount
      formatted_amount = AppEarnings::Report.formatted_amount(currency, total)
      puts @reports
      puts "Total of all transactions: #{formatted_amount}"
      @reports
    end

    def as_json
      currency, total = full_amount
      puts JSON.generate(apps: @reports.map(&:to_json),
                         currency: currency,
                         total: total)
    end

    def as_csv
      currency, total = full_amount
      formatted_amount = AppEarnings::Report.amount_for_csv(currency, total)
      @reports.each { |report| puts report.to_csv }
      puts %Q("Total of all transactions:", "#{formatted_amount}")
      @reports
    end
  end
end
