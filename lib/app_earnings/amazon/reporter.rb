module AppEarnings::Amazon
  # Generates a report based on the data provided
  class Reporter
    AVAILABLE_FORMATS = %w(json text)
    attr_accessor :data

    def initialize(data)
      @data = data
      @payments_data = @data.find { |r| r[:report_type] == :payments }
      @earnings_data = (@data - [@payments_data]).first
      @exchange_info = fetch_exchange_info
    end

    def fetch_exchange_info
      @payments_amount = 0.0
      @payments_data[:summary].reduce({}) do |all_info, data|
        all_info[data[:marketplace]] = data[:fx_rate]
        @payments_amount += data[:total_payment].gsub(/,/, '').to_f
        all_info
      end
    end

    def full_amount
      total = @reports.reduce(0.0) { |a, e| a + e.amount.to_f }
      total - refunds
    end

    def refunds
      @earnings_data[:summary].reduce(0.0) do |sum, marketplace|
        currency = marketplace[:marketplace]
        amount = marketplace[:refunds].gsub(/\(|\)/, '').to_f
        amount = amount * @exchange_info[currency].to_f if currency != 'USD'
        sum += amount
        sum
      end
    end

    def generate
      @reports = []
      @data.each do |raw_data|
        if raw_data[:report_type] == :earnings
          by_apps = raw_data[:details].group_by { |element| element[:app] }
                                      .sort_by { |app| app }

          by_apps.each do |key, application|
            @reports << AmazonReport.new(key, application, @exchange_info)
          end
        end
      end
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
      end
    end

    def as_text
      amount = AppEarnings::Report.formatted_amount('USD', full_amount)
      refund = AppEarnings::Report.formatted_amount('USD', refunds)
      payments = AppEarnings::Report.formatted_amount('USD', @payments_amount)
      puts @reports
      puts "Total of refunds: #{refund}"
      puts "Total of all transactions: #{amount}"
      puts "Total from Payment Report: #{payments}" if amount != payments
      @reports
    end

    def as_json
      puts JSON.generate(apps: @reports.map(&:to_json),
                         currency: 'USD',
                         total: full_amount)
    end
  end
end
